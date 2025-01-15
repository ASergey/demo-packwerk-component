# frozen_string_literal: true

module LeadWorkflows
  module WorkflowActions
    class EmailToCustomer
      extend Dry::Initializer
      include DI[customer_mailer: 'services.mailers.customer']

      param :lead, Types::Instance(LeadWorkflows::Lead)
      option :subject, Types::String
      option :template_path, Types::String
      option :template_name, Types::String

      def call
        email_subject = format(subject, subject_context)
        customer_mailer.(email_subject:, template_path:, template_name:, lead:, account:)
      rescue ActiveRecord::RecordNotFound => e
        raise LeadWorkflows::RecordNotFound, e.message
      end

      private

      def subject_context
        {
          contact_firstname: lead.contact_firstname,
          arrival_city: lead.arrival_city
        }
      end

      def account = @account ||= Accounts.find(lead.owner_id)
    end
  end
end
