# frozen_string_literal: true

module LeadWorkflows
  class BadNumberWorkflow < LeadWorkflow
    CONFIG_PATH = 'components/lead_workflows/config/lead_workflows/bad_number.yml'
    LEAD_LABEL_BAD_NUMBER = 'bad number'
    TRIGGER_LABELS = [LEAD_LABEL_BAD_NUMBER].freeze

    def resumable? = lead.label.downcase == LEAD_LABEL_BAD_NUMBER
  end
end
