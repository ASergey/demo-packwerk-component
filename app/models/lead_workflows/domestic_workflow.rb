# frozen_string_literal: true

module LeadWorkflows
  class DomesticWorkflow < LeadWorkflow
    CONFIG_PATH = 'components/lead_workflows/config/lead_workflows/domestic.yml'
    LEAD_LABEL_DOMESTIC = 'domestic'
    TRIGGER_LABELS = [LEAD_LABEL_DOMESTIC].freeze

    def resumable? = lead.label.downcase == LEAD_LABEL_DOMESTIC
  end
end
