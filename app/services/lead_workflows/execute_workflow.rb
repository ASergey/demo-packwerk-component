# frozen_string_literal: true

module LeadWorkflows
  class ExecuteWorkflow
    WORKFLOW_ACTIONS = {
      assign_label_to_lead: 'LeadWorkflows::WorkflowActions::AssignLabelToLead',
      email_to_agent: 'LeadWorkflows::WorkflowActions::EmailToAgent',
      email_to_customer: 'LeadWorkflows::WorkflowActions::EmailToCustomer',
      stop_sequences_enrolled: 'LeadWorkflows::WorkflowActions::StopSequencesEnrolled',
      unassign_contact_owner: 'LeadWorkflows::WorkflowActions::UnassignContactOwner',
      mark_recycled: 'LeadWorkflows::WorkflowActions::MarkAsRecycled'
    }.freeze

    # :reek:TooManyStatements
    def call(workflow)
      log('execute_workflow', type: workflow.type, workflow_id: workflow.id)
      return workflow.finish_workflow!(I18n.t('errors.lead_workflows.no_more_resumable')) unless workflow.resumable?

      ApplicationRecord.transaction(requires_new: true) do
        process_workflow(workflow)
      end
    rescue WorkflowStale, RecordNotFound => e
      workflow.finish_workflow!(e.message)
    end

    private

    def process_workflow(workflow)
      process_step(
        workflow.lead,
        workflow.current_step_params,
        workflow.context.deep_symbolize_keys
      )

      workflow.complete_step!
    end

    # :reek:TooManyStatements
    def process_step(lead, step_params, context)
      return if step_params.blank?

      step_params.each do |action, params|
        next unless WORKFLOW_ACTIONS.key?(action)

        params ||= {}
        WORKFLOW_ACTIONS[action].constantize.new(lead, **params, **context).()
        log('execute_action', action:, params:, context:)
      end
    end

    def log(action, **) = EventLogger.info(event: "lead_workflows.#{action}", **)
  end
end
