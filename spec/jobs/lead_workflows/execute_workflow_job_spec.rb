# frozen_string_literal: true

RSpec.describe LeadWorkflows::ExecuteWorkflowJob do
  subject(:job) { described_class.new.perform(workflow_id, updated_at) }

  let(:new_quote_workflow) { create(:new_quote_workflow) }

  let(:workflow_id) { new_quote_workflow.id }
  let(:updated_at) { new_quote_workflow.updated_at.to_i }
  let(:execute_workflow) { instance_double(LeadWorkflows::ExecuteWorkflow, call: true) }

  before do
    allow(LeadWorkflows::ExecuteWorkflow).to receive(:new).and_return(execute_workflow)
  end

  context 'when NewQuoteWorkflow exists' do
    before do
      allow(LeadWorkflows::LeadWorkflow).to receive(:find_by).with(id: workflow_id).and_return(new_quote_workflow)
    end

    it 'executes the workflow' do
      job
      expect(execute_workflow).to have_received(:call).with(new_quote_workflow)
    end

    context 'when NewQuoteWorkflow was updated before' do
      let(:updated_at) { new_quote_workflow.updated_at.to_i + 1 }

      it 'does nothing' do
        job
        expect(execute_workflow).not_to have_received(:call)
      end
    end
  end

  context 'when NewQuoteWorkflow does not exist' do
    let(:workflow_id) { 'missing' }

    it 'does nothing' do
      job
      expect(execute_workflow).not_to have_received(:call)
    end
  end
end
