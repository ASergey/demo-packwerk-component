# frozen_string_literal: true

module LeadWorkflows
  module EmailData
    class Base < ::EmailData::Factories::Base
      attribute :email_subject, Types::StrippedString
      attribute :template_path, Types::StrippedString
      attribute :template_name, Types::StrippedString

      attribute :lead, Types::Instance(LeadWorkflows::Lead)
      attribute :account, Types::Instance(Accounts::AccountDTO)

      delegate :id, to: :lead, prefix: true
      delegate :contact_id, to: :lead

      def custom_args = { mail_type: 'lead_workflow', external_id:, lead_id: }
      def body_html = Premailer::Rails::Hook.perform(mail).html_part.body.to_s

      alias subject email_subject

      private

      def mail
        @mail ||= LeadWorkflows::Mailer.mail_message(**mail_options)
      end

      def mail_options
        @mail_options ||= {
          from:,
          to:,
          subject: email_subject,
          template_path:,
          template_name:,
          template_vars:
        }
      end
    end
  end
end
