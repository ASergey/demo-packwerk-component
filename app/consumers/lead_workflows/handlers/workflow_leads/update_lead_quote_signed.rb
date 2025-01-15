# frozen_string_literal: true

module LeadWorkflows
  module Handlers
    module WorkflowLeads
      class UpdateLeadQuoteSigned < Base
        QUOTE_STATUS_SIGNED = 'signed'

        def call(msg)
          return unless msg.data[:status] == QUOTE_STATUS_SIGNED

          super
        end

        private

        def update_lead(lead, _msg) = lead.context['quote_signed_at'] = Time.current
      end
    end
  end
end
