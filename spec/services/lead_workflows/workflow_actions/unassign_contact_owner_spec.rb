# frozen_string_literal: true

RSpec.describe LeadWorkflows::WorkflowActions::UnassignContactOwner do
  subject(:execute_workflow) { described_class.new(lead).() }

  let(:lead) { build(:workflow_lead) }

  before do
    allow(Contacts).to receive(:unassign_owner!)
  end

  it 'unassigns contact owner' do
    execute_workflow
    expect(Contacts).to have_received(:unassign_owner!).with(lead.contact_id)
  end
end
