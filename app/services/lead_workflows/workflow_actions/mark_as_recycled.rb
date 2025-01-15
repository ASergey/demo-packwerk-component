# frozen_string_literal: true

module LeadWorkflows
  module WorkflowActions
    class MarkAsRecycled
      extend Dry::Initializer

      param :lead, Types::Instance(LeadWorkflows::Lead)

      def call
        Leads.mark_recycled!(lead.id)
        update_lead(lead)
      rescue Leads::AlreadyRecycledError, Leads::NotMostRecentLead, Leads::PersonalContactError => e
        raise WorkflowStale, e.message
      end

      private

      def update_lead(lead)
        lead.context['recycled_at'] = Time.current
        lead.save!
      end
    end
  end
end
