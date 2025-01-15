# frozen_string_literal: true

module LeadWorkflows
  class ExecuteWorkflowJob
    include Sidekiq::Worker
    include DI['services.execute_workflow']

    def perform(workflow_id, updated_at_timestamp)
      workflow = LeadWorkflow.find_by(id: workflow_id)
      return unless workflow

      workflow.with_lock do
        raise ActiveRecord::Rollback if workflow.updated_at.to_i != updated_at_timestamp

        execute_workflow.(workflow)
      end
    end
  end
end
