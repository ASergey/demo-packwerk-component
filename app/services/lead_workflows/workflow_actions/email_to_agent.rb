# frozen_string_literal: true

module LeadWorkflows
  module WorkflowActions
    class EmailToAgent
      extend Dry::Initializer
      include DI[agent_mailer: 'services.mailers.agent']

      param :lead, Types::Instance(LeadWorkflows::Lead)
      option :subject, Types::String
      option :template_path, Types::String
      option :template_name, Types::String

      def call
        email_subject = format(subject, subject_context)
        agent_mailer.(email_subject:, template_path:, template_name:, lead:, account:)
      rescue ActiveRecord::RecordNotFound => e
        raise LeadWorkflows::RecordNotFound, e.message
      end

      private

      def subject_context
        {
          contact_fullname: lead.contact_fullname,
          lead_from: lead.departure,
          lead_to: lead.arrival
        }
      end

      def account = @account ||= Accounts.find(lead.owner_id)
    end
  end
end
