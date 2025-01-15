# frozen_string_literal: true

RSpec.describe LeadWorkflows::RecycleWorkflow, :freeze_time do
  let(:lead_id) { 10_100 }
  let(:returning) { false }

  before do
    create(:workflow_lead, lead_id:, returning:)
  end

  it_behaves_like 'a triggerable lead workflow', LeadWorkflows::RecycleWorkflow::TRIGGER_LABELS
  it_behaves_like 'a resumable lead workflow', :recycle_workflow, LeadWorkflows::RecycleWorkflow::TRIGGER_LABELS

  context 'when returning' do
    subject(:maybe_trigger) { described_class.maybe_trigger(msg) }

    let(:msg) { Events::Message.new(type: 'Leads::LeadLabelAssigned', data:) }
    let(:data) { attributes_for(:lead_label_assigned_event, lead_id:, label:) }
    let(:label) { 'No response' }
    let(:returning) { true }

    before do
      allow(Leads).to receive_messages(find: build(:lead_dto))
      allow(Contacts).to receive_messages(find: build(:contact_dto))
    end

    it 'does not trigger workflow' do
      expect { maybe_trigger }.not_to change(described_class, :count)
      expect(maybe_trigger).to be_nil
    end
  end
end
