# frozen_string_literal: true

module LeadWorkflows
  class NewLeadWorkflow < LeadWorkflow
    CONFIG_PATH = 'components/lead_workflows/config/lead_workflows/new_lead.yml'
    LEAD_LABEL_NONE = 'none'
    TRIGGER_LABELS = [LEAD_LABEL_NONE].freeze

    class << self
      def maybe_trigger(msg)
        data = msg.data
        return unless triggerable?(msg)

        create!(lead_id: data[:lead_id], context: workflow_context(data), resume_at: first_resume_at)
      end

      def triggerable?(msg)
        msg.type == 'Leads::LeadCreated' && trigger_label?(msg.data[:label])
      end
    end

    def resumable? = lead.label.downcase == LEAD_LABEL_NONE
  end
end
