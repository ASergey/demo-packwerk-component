# frozen_string_literal: true

module LeadWorkflows
  class WorkflowProcessor
    include DI[execute_workflow: 'workers.execute_workflow']

    WORKFLOWS = [
      'LeadWorkflows::ATCWorkflow',
      'LeadWorkflows::BadNumberWorkflow',
      'LeadWorkflows::BonusWorkflow',
      'LeadWorkflows::CompetitorWorkflow',
      'LeadWorkflows::ChargedQuoteWorkflow',
      'LeadWorkflows::DomesticWorkflow',
      'LeadWorkflows::FindFlightWorkflow',
      'LeadWorkflows::NewLeadWorkflow',
      'LeadWorkflows::NewQuoteWorkflow',
      'LeadWorkflows::NotReadyWorkflow',
      'LeadWorkflows::PlansChangedWorkflow',
      'LeadWorkflows::QuotedMIAWorkflow',
      'LeadWorkflows::RecycleWorkflow',
      'LeadWorkflows::SlowPlayWorkflow'
    ].freeze

    FILTER_SUBJECTS = %w[
      sequences.*.contact_enrolled
      quotes.*.created
      quotes.*.updated
      leads.*.created
      leads.*.label_assigned
      calls.*.disposition_created
    ].freeze

    def process_message(msg)
      messages = Array.wrap(MessageTransformer.new(msg).transform)

      messages.each { |message| process(message) }
    end

    def filter_subjects = FILTER_SUBJECTS

    private

    def process(msg)
      WORKFLOWS.each do |workflow_handler|
        workflow = workflow_handler.constantize.maybe_trigger(msg)
        next unless workflow

        execute_workflow.perform_at(workflow.resume_at, workflow.id, workflow.updated_at.to_i)
      end
    end
  end
end
