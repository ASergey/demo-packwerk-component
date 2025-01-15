# frozen_string_literal: true

module LeadWorkflows
  module Handlers
    module WorkflowLeads
      class UpdateUnreachedCallDate
        CALL_UNREACHED_DISPOSITION = 'Call Unreached'

        def call(msg)
          return if skip?(msg)

          leads = fetch_leads(msg)
          leads.update_all(update_statement(msg.data[:date_started]))
        end

        private

        def skip?(msg) = msg.data[:disposition] != CALL_UNREACHED_DISPOSITION

        def fetch_leads(msg) = Lead.where(phone: phone(msg.data))

        def phone(data) = data.dig(:contact, :phone)

        def update_statement(date)
          <<~SQL
            context = jsonb_set(context, '{unreached_call_attempt_was}', '"#{date}"')
          SQL
        end
      end
    end
  end
end
