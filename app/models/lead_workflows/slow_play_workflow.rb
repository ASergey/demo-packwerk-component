# frozen_string_literal: true

module LeadWorkflows
  class SlowPlayWorkflow < LeadWorkflow
    CONFIG_PATH = 'components/lead_workflows/config/lead_workflows/slow_play.yml'
    LEAD_LABEL_SLOW_PLAY = 'slow play'
    TRIGGER_LABELS = [LEAD_LABEL_SLOW_PLAY].freeze

    def resumable? = lead.label.downcase == LEAD_LABEL_SLOW_PLAY
  end
end
