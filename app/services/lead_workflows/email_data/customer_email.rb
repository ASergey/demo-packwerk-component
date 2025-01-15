# frozen_string_literal: true

module LeadWorkflows
  module EmailData
    class CustomerEmail < Base
      def from = EmailAddress.new(address: account.email)
      def to = [EmailAddress.new(address: lead.contact_email, name: lead.contact_firstname)]

      private

      def template_vars
        {
          lead:,
          account:,
          signature: Accounts.email_signature(account.id)
        }
      end
    end
  end
end
