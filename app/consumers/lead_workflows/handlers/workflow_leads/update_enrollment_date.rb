# frozen_string_literal: true

module LeadWorkflows
  module Handlers
    module WorkflowLeads
      class UpdateEnrollmentDate < Base
        private

        def update_lead(lead, msg) = lead.context['enrollment_date'] = msg.time
      end
    end
  end
end
