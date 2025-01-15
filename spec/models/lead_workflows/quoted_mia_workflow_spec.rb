# frozen_string_literal: true

RSpec.describe LeadWorkflows::QuotedMIAWorkflow do
  before do
    allow(Leads).to receive_messages(find: build(:lead_dto))
    allow(Contacts).to receive_messages(find: build(:contact_dto))
  end

  it_behaves_like 'a triggerable lead workflow', [LeadWorkflows::QuotedMIAWorkflow::LEAD_LABEL_QUOTED]

  context "with the lead's quote signed" do
    subject(:resumable?) { workflow.resumable? }

    let(:workflow) { build(:quoted_mia_workflow, lead_id: lead.id) }
    let(:lead) { create(:workflow_lead, context: { 'quote_signed_at' => Time.current }) }

    it { is_expected.to be false }
  end

  describe '#lead_was_quoted_mia?' do
    subject(:lead_was_quoted_mia?) { workflow.lead_was_quoted_mia? }

    let(:workflow) { create(:quoted_mia_workflow, lead_id: lead.id) }
    let(:lead) { create(:workflow_lead) }

    it { is_expected.to be false }

    context 'with existing finished quoted mia workflow' do
      before { create(:quoted_mia_workflow, lead_id: lead.id, status: :finished) }

      it { is_expected.to be true }
    end

    context 'with existing not finished quoted mia workflow' do
      before { create(:quoted_mia_workflow, lead_id: lead.id, status: :in_progress) }

      it { is_expected.to be false }
    end
  end

  describe '#complete_step!' do
    subject(:complete_step) { workflow.complete_step! }

    let(:workflow) { create(:quoted_mia_workflow, lead_id: lead.id, context: { 'step' => 3 }) }
    let(:lead) { create(:workflow_lead, returning:, most_recent:) }
    let(:returning) { false }
    let(:most_recent) { true }

    it 'sets next step params' do
      complete_step
      expect(workflow.context).to eq({ 'step' => 4 })
    end

    context 'with returning lead' do
      let(:returning) { true }

      it 'sets another next step params' do
        complete_step
        expect(workflow.context).to eq({ 'step' => 5 })
      end
    end

    context 'with existsing finished quoted mia workflow' do
      let(:workflow) { create(:quoted_mia_workflow, lead_id: lead.id, context: { 'step' => 3 }) }

      before do
        create(:quoted_mia_workflow, lead_id: lead.id, status: :finished)
      end

      it 'sets another next step params' do
        complete_step
        expect(workflow.context).to eq({ 'step' => 5 })
      end
    end

    context 'with not the most recent lead' do
      let(:most_recent) { false }

      it 'sets another next step params' do
        complete_step
        expect(workflow.context).to eq({ 'step' => 5 })
      end
    end
  end

  describe '#resumable?' do
    subject(:resumable?) { workflow.resumable? }

    let(:workflow) do
      build(:quoted_mia_workflow, lead_id: lead.lead_id, context: { 'step' => step })
    end
    let(:lead) { create(:workflow_lead, context: { 'label' => label }) }

    context 'when step is 0' do
      let(:step) { 0 }
      let(:label) { 'Quoted' }

      it { is_expected.to be true }
    end

    context 'when other step' do
      let(:step) { 3 }
      let(:label) { 'Quoted (MIA)' }

      it { is_expected.to be true }

      context 'when label different' do # rubocop:disable RSpec/NestedGroups
        let(:label) { 'Quoted' }

        it { is_expected.to be false }
      end
    end
  end
end
