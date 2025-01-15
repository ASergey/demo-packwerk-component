# frozen_string_literal: true

module LeadWorkflows
  class PlansChangedWorkflow < LeadWorkflow
    CONFIG_PATH = 'components/lead_workflows/config/lead_workflows/plans_changed.yml'
    LEAD_LABEL_PLANS_CHANGED = 'plans changed'
    TRIGGER_LABELS = [LEAD_LABEL_PLANS_CHANGED].freeze

    def resumable? = lead.label.downcase == LEAD_LABEL_PLANS_CHANGED
  end
end
