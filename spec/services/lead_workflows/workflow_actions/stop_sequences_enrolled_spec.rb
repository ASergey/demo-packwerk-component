# frozen_string_literal: true

RSpec.describe LeadWorkflows::WorkflowActions::StopSequencesEnrolled do
  subject(:execute_workflow) { described_class.new(lead).() }

  let(:lead) { build(:workflow_lead) }

  before do
    allow(Contacts).to receive(:unenroll_sequence!)
  end

  it 'assigns label to lead' do
    execute_workflow
    expect(Contacts).to have_received(:unenroll_sequence!).with(lead.contact_id)
  end
end
