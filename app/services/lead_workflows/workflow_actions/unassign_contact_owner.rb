# frozen_string_literal: true

module LeadWorkflows
  module WorkflowActions
    class UnassignContactOwner
      extend Dry::Initializer

      param :lead, Types::Instance(LeadWorkflows::Lead)

      def call
        Contacts.unassign_owner!(lead.contact_id)
      end
    end
  end
end
