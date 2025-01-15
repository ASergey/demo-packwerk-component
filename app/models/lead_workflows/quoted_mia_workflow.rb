# frozen_string_literal: true

module LeadWorkflows
  class QuotedMIAWorkflow < LeadWorkflow
    CONFIG_PATH = 'components/lead_workflows/config/lead_workflows/quoted_mia.yml'
    LEAD_LABEL_QUOTED = 'quoted'
    LEAD_LABEL_QUOTED_MIA = 'quoted (mia)'
    TRIGGER_LABELS = [LEAD_LABEL_QUOTED].freeze

    def resumable? = !lead.quote_was_signed? && required_status?
    def lead_was_quoted_mia? = self.class.finished.exists?(lead_id: lead.id)

    private

    def required_status?
      required_label = first_step? ? LEAD_LABEL_QUOTED : LEAD_LABEL_QUOTED_MIA

      lead.label.downcase == required_label
    end

    def first_step? = current_step.zero?
  end
end
