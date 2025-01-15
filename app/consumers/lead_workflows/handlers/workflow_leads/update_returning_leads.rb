# frozen_string_literal: true

module LeadWorkflows
  module Handlers
    module WorkflowLeads
      # When the contact receives at least one charged quote (the charge commission is created),
      # all its leads become returning
      class UpdateReturningLeads
        def call(msg)
          data = msg.data
          return unless data[:quote_id].present? && data[:source_action] == 'charge'

          mark_contact_leads_returning(data[:contact_id])
        end

        private

        def mark_contact_leads_returning(contact_id)
          Lead.where(contact_id:)&.update_all(returning: true)
        end
      end
    end
  end
end
