# frozen_string_literal: true

module LeadWorkflows
  class ExecuteResumableWorkflowsJob
    include Sidekiq::Worker
    include DI[
      ready_to_resume: 'queries.ready_to_resume',
      execute_workflow: 'workers.execute_workflow'
    ]

    def perform
      ready_to_resume.().find_each do |workflow|
        execute_workflow.perform_at(workflow.resume_at, workflow.id, workflow.updated_at.to_i)
      end
    end
  end
end
