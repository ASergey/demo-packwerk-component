# frozen_string_literal: true

module LeadWorkflows
  module Handlers
    module WorkflowLeads
      class UpdateLeadLabel < Base
        private

        def fetch_lead(msg) = LeadsRepository.fetch(msg.data[:lead_id])

        def update_lead(lead, msg) = lead.context['label'] = msg.data[:label]
      end
    end
  end
end
