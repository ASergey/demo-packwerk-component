# frozen_string_literal: true

module LeadWorkflows
  module EmailData
    class AgentEmail < Base
      def from = EmailAddress.new(address: SYSTEM_EMAIL_ADDRESS)
      def to = [EmailAddress.new(address: account.email, name: account.name)]

      private

      def template_vars
        {
          lead:,
          lead_url:
        }
      end

      def lead_url = HOST + "/admin/leads/show/#{lead.id}"
    end
  end
end
