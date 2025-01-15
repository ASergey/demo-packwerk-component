# frozen_string_literal: true

module LeadWorkflows
  class FindFlightWorkflow < LeadWorkflow
    CONFIG_PATH = 'components/lead_workflows/config/lead_workflows/find_flight.yml'
    LEAD_LABEL_FIND_FLIGHT = 'find flight'
    TRIGGER_LABELS = [LEAD_LABEL_FIND_FLIGHT].freeze

    def resumable? = lead.label.downcase == LEAD_LABEL_FIND_FLIGHT
  end
end
