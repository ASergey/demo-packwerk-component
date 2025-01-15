# frozen_string_literal: true

module LeadWorkflows
  class NewQuoteWorkflow < LeadWorkflow
    CONFIG_PATH = 'components/lead_workflows/config/lead_workflows/new_quote.yml'
    QUOTE_STATUS_NEW = 'new'

    class << self
      private

      def triggerable?(msg_data)
        with_lead_id?(msg_data) && new_quote?(msg_data)
      end

      def new_quote?(data) = data[:status] == QUOTE_STATUS_NEW
      def workflow_context(msg_data) = super.merge(msg_data.slice(:quote_id, :status))
      def with_lead_id?(data) = data[:lead_id].present?
    end
  end
end
