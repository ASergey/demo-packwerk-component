# frozen_string_literal: true

RSpec.describe LeadWorkflows::WorkflowProcessor do
  describe '#filter_subjects' do
    subject(:processor) { described_class.new }

    it 'returns supported filter subjects' do
      expect(processor.filter_subjects).to eq %w[
        sequences.*.contact_enrolled
        quotes.*.created
        quotes.*.updated
        leads.*.created
        leads.*.label_assigned
        calls.*.disposition_created
      ]
    end
  end

  describe '#process_message' do
    subject(:process) { described_class.new(execute_workflow:).process_message(:msg) }

    let(:workflow) { build_stubbed(:new_quote_workflow) }
    let(:execute_workflow) { class_double(LeadWorkflows::ExecuteWorkflowJob, perform_at: nil) }
    let(:instance) { instance_double(LeadWorkflows::MessageTransformer, transform: :msg) }

    before do
      stub_const('LeadWorkflows::WorkflowProcessor::WORKFLOWS', ['LeadWorkflows::NewQuoteWorkflow'])
      allow(LeadWorkflows::NewQuoteWorkflow).to receive_messages(maybe_trigger: workflow)
      allow(LeadWorkflows::MessageTransformer).to receive_messages(new: instance)
    end

    it 'passes message to each workflow' do
      process

      described_class::WORKFLOWS.each do |workflow_handler|
        expect(workflow_handler.constantize).to have_received(:maybe_trigger).with(:msg)
      end
      expect(execute_workflow).to have_received(:perform_at).with(
        workflow.resume_at, workflow.id, workflow.updated_at.to_i
      )
    end

    context 'when no any workflow is triggered' do
      let(:workflow) { nil }

      it 'does nothing' do
        expect { process }.not_to raise_error
        expect(execute_workflow).not_to have_received(:perform_at)
      end
    end
  end
end
