# frozen_string_literal: true

RSpec.describe LeadWorkflows::WorkflowActions::AssignLabelToLead do
  subject(:execute_workflow) { described_class.new(lead, label: 'label').() }

  let(:lead) { build(:workflow_lead) }

  before do
    allow(Leads).to receive(:assign_label!)
  end

  it 'assigns label to lead' do
    execute_workflow
    expect(Leads).to have_received(:assign_label!).with(lead.id, 'label')
  end
end
