# frozen_string_literal: true

RSpec.describe LeadWorkflows::Handlers::WorkflowLeads::DeleteLead do
  subject(:handle) { described_class.new.(msg) }

  let(:msg) { Events::Message.new(type: 'Leads::LeadDeleted', data:) }

  let(:lead) { create(:workflow_lead) }

  let(:data) { { lead_id: lead.id } }

  it 'deletes lead' do
    expect { handle }.not_to change(LeadWorkflows::LeadWorkflow, :count)

    expect(LeadWorkflows::Lead).not_to exist(lead.id)
  end

  context 'when lead with workflow' do
    let!(:workflow) { create(:new_quote_workflow, lead_id: lead.id) }

    it 'deletes lead with workflow' do
      handle

      expect(LeadWorkflows::Lead).not_to exist(lead.id)
      expect(LeadWorkflows::LeadWorkflow).not_to exist(workflow.id)
    end
  end

  context 'when lead does not exist' do
    let(:data) { { lead_id: 111_111 } }

    it 'does nothing' do
      expect { handle }.not_to raise_error
    end
  end
end
