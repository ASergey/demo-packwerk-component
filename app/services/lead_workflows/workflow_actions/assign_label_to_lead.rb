# frozen_string_literal: true

module LeadWorkflows
  module WorkflowActions
    class AssignLabelToLead
      extend Dry::Initializer

      param :lead, Types::Instance(LeadWorkflows::Lead)
      option :label, Types::String

      def call
        Leads.assign_label!(lead.id, label)
      end
    end
  end
end
