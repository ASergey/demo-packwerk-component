# frozen_string_literal: true

#  rubocop:disable RSpec/NestedGroups
RSpec.describe LeadWorkflows::LeadWorkflow do
  it 'defines enums for status' do
    expect(described_class.new).to(
      define_enum_for(:status).with_values(
        {
          created: 'created',
          in_progress: 'in_progress',
          finished: 'finished'
        }
      ).backed_by_column_of_type(:string)
    )
  end

  describe '.first_resume_at', :freeze_time do
    subject(:first_resume_at) { described_class.first_resume_at }

    let(:workflow_config) { [{ 'some_action' => '' }] }

    before do
      allow(described_class).to receive(:workflow_config).and_return(workflow_config)
    end

    it { is_expected.to eq(Time.current) }

    context 'with delayed workflow param' do
      let(:workflow_config) { [{ 'delay' => 'P1D' }] }

      it { is_expected.to eq(24.hours.from_now) }
    end
  end

  describe '#lead' do
    subject(:workflow_lead) { workflow.lead }

    let(:workflow) { create(:new_quote_workflow, lead_id: lead.id) }
    let(:lead) { create(:workflow_lead) }

    before do
      allow(Leads).to receive_messages(find: build(:lead_dto))
      allow(Contacts).to receive_messages(find: build(:contact_dto))
    end

    it { is_expected.to eq(lead) }
  end

  describe '#finish_workflow!' do
    subject(:finish_workflow) { workflow.finish_workflow!(error) }

    let(:workflow) { create(:new_quote_workflow) }
    let(:error) { nil }

    before do
      allow(EventLogger).to receive(:info)
    end

    it 'fininshes the workflow' do
      expect { finish_workflow }.to change { workflow.reload.status }.from('created').to('finished')
      expect(EventLogger).to have_received(:info).with(
        event: 'lead_workflows.workflow_finished',
        type: workflow.type,
        workflow_id: workflow.id,
        error: nil
      )
    end

    context 'with error' do
      let(:error) { 'some error message' }

      it 'updates status to finished with error message' do
        expect { finish_workflow }.to change { workflow.reload.status }.from('created').to('finished')
        expect(workflow.error).to eq(error)
        expect(EventLogger).to have_received(:info).with(
          event: 'lead_workflows.workflow_finished',
          type: workflow.type,
          workflow_id: workflow.id,
          error:
        )
      end
    end
  end

  describe '#current_step_params' do
    subject(:current_step_params) { workflow.current_step_params }

    let(:workflow) { create(:new_quote_workflow, context: { 'step' => 1 }) }
    let(:workflow_config) { [{ 'first_step' => { 'key' => 'value' } }, { 'second_step' => { 'key' => 'value' } }] }

    before do
      allow(workflow).to receive(:workflow_config).and_return(workflow_config)
    end

    it 'returns current step params' do
      expect(current_step_params).to eq({ second_step: { key: 'value' } })
    end
  end

  describe '#complete_step!' do
    subject(:complete_step) { workflow.complete_step! }

    let(:context) { { 'step' => 0 } }
    let(:workflow) { create(:quoted_mia_workflow, lead_id:, context:) }
    let(:lead_id) { lead.id }
    let(:lead) { build_stubbed(:workflow_lead) }
    let(:workflow_config) { [{ 'some_action' => '' }] }

    before do
      allow(workflow).to receive_messages(workflow_config:, lead_returning?: false, lead_was_quoted_mia?: false)
    end

    it { expect { complete_step }.to change { workflow.reload.status }.from('created').to('finished') }

    context 'when the step is not the last one', :freeze_time do
      let(:workflow_config) { [{ 'some_action' => '' }, { 'delay' => 'P1D' }] }
      let(:context) { { 'step' => 0, 'key' => 'value' } }

      it 'updates step number and schedules the next step' do
        complete_step
        expect(workflow.reload.context).to eq({ 'step' => 1, 'key' => 'value' })
        expect(workflow).to be_in_progress
        expect(workflow.resume_at).to eq 24.hours.from_now
      end
    end

    context 'with invalid next step params' do
      let(:workflow_config) { [{ 'some_action' => '' }, { 'invalid' => true }] }

      it 'raises error' do
        expect { complete_step }.to raise_error(LeadWorkflows::InvalidConfiguration)
      end
    end

    context "with 'if' conditions", :freeze_time do
      let(:workflow_config) do
        [
          { 'first_action' => '' },
          { 'if' => [{ 'lead_returning?' => false }, { 'lead_was_quoted_mia?' => false }], 'delay' => 'P2D' }
        ]
      end

      it 'schedules the next step' do
        complete_step
        expect(workflow).to be_in_progress
        expect(workflow.resume_at).to eq 48.hours.from_now
      end

      context 'when not all conditions match' do
        before do
          allow(workflow).to receive(:lead_was_quoted_mia?).and_return(true)
        end

        it { expect { complete_step }.to change { workflow.reload.status }.from('created').to('finished') }
      end

      context 'without matching conditions with not the last step' do
        let(:workflow_config) do
          [
            { 'first_action' => '' },
            { 'if' => [{ 'lead_returning?' => false }, { 'lead_was_quoted_mia?' => true }], 'delay' => 'P2D' },
            { 'delay' => 'P1D' }
          ]
        end

        it 'schedules the next available step' do
          complete_step
          expect(workflow.reload).to be_in_progress
          expect(workflow.context).to eq({ 'step' => 2 })
          expect(workflow.resume_at).to eq 24.hours.from_now
        end
      end

      context 'with at least one matching condition requirement' do
        let(:workflow_config) do
          [
            { 'first_action' => '' },
            { 'if' => [{ 'lead_returning?' => false, 'lead_was_quoted_mia?' => true }], 'delay' => 'P2D' }
          ]
        end

        it 'schedules the next available step' do
          complete_step
          expect(workflow.reload).to be_in_progress
          expect(workflow.context).to eq({ 'step' => 1 })
          expect(workflow.resume_at).to eq 48.hours.from_now
        end
      end

      context 'with no one matching condition with the requirement to match at least one' do
        let(:workflow_config) do
          [
            { 'first_action' => '' },
            { 'if' => [{ 'lead_returning?' => true, 'lead_was_quoted_mia?' => true }], 'delay' => 'P2D' }
          ]
        end

        it { expect { complete_step }.to change { workflow.reload.status }.from('created').to('finished') }
      end

      context 'when the condition is not implemented' do
        let(:workflow_config) do
          [
            { 'first_action' => '' },
            { 'if' => [{ 'lead_returning?' => false }, { 'not_implemented' => false }], 'delay' => 'P2D' }
          ]
        end

        it { expect { complete_step }.to raise_error(LeadWorkflows::InvalidConfiguration) }
      end
    end
  end

  describe '#lead_returning?' do
    subject(:lead_returning?) { workflow.lead_returning? }

    let(:workflow) { build(:quoted_mia_workflow, lead_id: lead.id) }
    let(:lead) { build_stubbed(:workflow_lead, returning:) }
    let(:returning) { true }

    before { allow(workflow).to receive(:lead).and_return(lead) }

    it { is_expected.to be true }

    context 'when returning is false' do
      let(:returning) { false }

      it { is_expected.to be false }
    end
  end

  describe '#most_recent?' do
    subject(:lead_most_recent?) { workflow.lead_most_recent? }

    let(:workflow) { build(:quoted_mia_workflow, lead_id: lead.id) }
    let(:lead) { build_stubbed(:workflow_lead, most_recent:) }
    let(:most_recent) { true }

    before { allow(workflow).to receive(:lead).and_return(lead) }

    it { is_expected.to be true }

    context 'when most_recent is false' do
      let(:most_recent) { false }

      it { is_expected.to be false }
    end
  end
end
#  rubocop:enable RSpec/NestedGroups
