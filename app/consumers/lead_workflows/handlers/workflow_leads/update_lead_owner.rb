# frozen_string_literal: true

module LeadWorkflows
  module Handlers
    module WorkflowLeads
      class UpdateLeadOwner < Base
        private

        def update_lead(lead, msg) = lead.context['owner_id'] = owner_id(msg.data)

        def owner_id(data) = data[:account_id] || data.dig(:reassigned_to, :account_id)
      end
    end
  end
end
