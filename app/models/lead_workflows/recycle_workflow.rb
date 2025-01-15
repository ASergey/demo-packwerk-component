# frozen_string_literal: true

module LeadWorkflows
  class RecycleWorkflow < LeadWorkflow
    CONFIG_PATH = 'components/lead_workflows/config/lead_workflows/recycle.yml'
    TRIGGER_LABELS = ['no response', 'low budget', 'own miles', 'plans changed', 'competitor'].freeze

    class << self
      private

      def triggerable?(msg_data)
        super && !returning_lead?(msg_data)
      end

      def returning_lead?(msg_data) = LeadsRepository.fetch(msg_data[:lead_id]).returning?

      def workflow_context(msg_data) = { step: 0, triggered_label: msg_data[:label] }
    end

    def resumable? = TRIGGER_LABELS.include?(lead.label.downcase)
    def workflow_config = @workflow_config ||= YAML.load_file(CONFIG_PATH)
  end
end
