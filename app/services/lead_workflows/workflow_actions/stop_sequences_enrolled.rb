# frozen_string_literal: true

module LeadWorkflows
  module WorkflowActions
    class StopSequencesEnrolled
      extend Dry::Initializer

      param :lead, Types::Instance(LeadWorkflows::Lead)

      def call
        Contacts.unenroll_sequence!(lead.contact_id)
      end
    end
  end
end
