# frozen_string_literal: true

# rubocop:disable RSpec/NestedGroups
RSpec.describe LeadWorkflows::ATCWorkflow do
  describe '.maybe_trigger' do
    subject(:maybe_trigger) { described_class.maybe_trigger(msg) }

    let(:lead_id) { 10_100 }

    context 'with unattempted call' do
      let(:msg) { Events::Message.new(type: 'Calls::DispositionCreated', data: { disposition:, lead_id: }) }

      context 'with required disposition' do
        let(:disposition) { 'Call Unreached' }

        it 'creates a new workflow', :freeze_time do
          workflow = maybe_trigger
          expect(workflow).to be_a(described_class)
          expect(workflow.lead_id).to eq(lead_id)
          expect(workflow.context).to include('step' => 0)
          expect(workflow).to be_created
          expect(workflow.resume_at).to eq Time.current
        end
      end

      context 'with other disposition' do
        let(:disposition) { 'Call Reached' }

        it 'does not trigger workflow' do
          expect { maybe_trigger }.not_to change(described_class, :count)
          expect(maybe_trigger).to be_nil
        end
      end
    end

    context 'with enrolled siquence' do
      let(:msg) { Events::Message.new(type: 'Contacts::ContactEnrolled', data: { sequence_id: 1, lead_id: }) }

      it 'creates a new workflow', :freeze_time do
        workflow = maybe_trigger
        expect(workflow).to be_a(described_class)
        expect(workflow.lead_id).to eq(lead_id)
        expect(workflow.context).to include('step' => 0)
        expect(workflow).to be_created
        expect(workflow.resume_at).to eq Time.current
      end
    end

    context 'with other event' do
      let(:msg) { Events::Message.new(type: 'Leads::LeadLabelAssigned', data:) }
      let(:data) { attributes_for(:lead_label_assigned_event, lead_id:, label: 'Accepted') }

      it 'does not trigger workflow' do
        expect { maybe_trigger }.not_to change(described_class, :count)
        expect(maybe_trigger).to be_nil
      end
    end
  end

  describe '#resumable?' do
    subject(:resumable?) { workflow.resumable? }

    let(:workflow) do
      build(:atc_workflow, lead_id: lead.lead_id, context: { 'step' => step }, created_at: 10.minutes.ago)
    end
    let(:lead) { create(:workflow_lead, context: { 'label' => label }) }
    let(:rest_context) { {} }

    before do
      allow(Leads).to receive_messages(find: build(:lead_dto))
      allow(Contacts).to receive_messages(find: build(:contact_dto))
    end

    context 'when step is 0' do
      let(:step) { 0 }
      let(:label) { 'Any label' }

      it { is_expected.to be true }
    end

    context 'when step is 1' do
      let(:step) { 1 }
      let(:label) { 'Attempt to contact 1' }

      it { is_expected.to be true }

      context 'when label different' do
        let(:label) { 'Lost' }

        it { is_expected.to be false }
      end
    end

    context 'when step is 2' do
      let(:step) { 2 }
      let(:label) { 'Attempt to contact 2' }

      it { is_expected.to be true }

      context 'when label different' do
        let(:label) { 'Lost' }

        it { is_expected.to be false }
      end
    end

    context 'when step is 3' do
      let(:step) { 3 }
      let(:label) { 'Attempt to contact 3' }

      it { is_expected.to be true }

      context 'when label different' do
        let(:label) { 'Lost' }

        it { is_expected.to be false }
      end
    end

    context 'when step is 4' do
      let(:step) { 4 }
      let(:label) { 'Attempt to contact 3' }

      it { is_expected.to be true }

      context 'when label different' do
        let(:label) { 'Lost' }

        it { is_expected.to be false }
      end
    end
  end
end
# rubocop:enable RSpec/NestedGroups
