# frozen_string_literal: true

module LeadWorkflows
  class ReadyToResumeQuery
    # Must correlate with `LeadWorkflows::ExecuteResumableWorkflowsJob` schedule
    RESUME_AT_GAP = 15.minutes

    def call
      LeadWorkflow.not_finished.where('resume_at <= :time', time: RESUME_AT_GAP.from_now)
    end
  end
end
