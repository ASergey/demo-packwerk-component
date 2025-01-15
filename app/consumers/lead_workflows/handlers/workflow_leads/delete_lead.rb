# frozen_string_literal: true

module LeadWorkflows
  module Handlers
    module WorkflowLeads
      class DeleteLead
        def call(msg)
          lead_id = msg.data[:lead_id]

          Lead.destroy_by(lead_id: lead_id)
          LeadWorkflow.destroy_by(lead_id: lead_id)
        end
      end
    end
  end
end
