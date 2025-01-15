# frozen_string_literal: true

module LeadWorkflows
  class BonusWorkflow < LeadWorkflow
    CONFIG_PATH = 'components/lead_workflows/config/lead_workflows/bonus.yml'
    LEAD_LABEL_BONUS = 'bonus leads'
    TRIGGER_LABELS = [LEAD_LABEL_BONUS].freeze

    def resumable? = lead.label.downcase == LEAD_LABEL_BONUS
  end
end
