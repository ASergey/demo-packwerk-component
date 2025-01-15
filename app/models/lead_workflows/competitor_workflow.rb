# frozen_string_literal: true

module LeadWorkflows
  class CompetitorWorkflow < LeadWorkflow
    CONFIG_PATH = 'components/lead_workflows/config/lead_workflows/competitor.yml'
    LEAD_LABEL_COMPETITOR = 'competitor'
    TRIGGER_LABELS = [LEAD_LABEL_COMPETITOR].freeze

    def resumable? = lead.label.downcase == LEAD_LABEL_COMPETITOR
  end
end
