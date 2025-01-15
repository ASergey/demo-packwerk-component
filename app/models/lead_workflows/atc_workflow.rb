# frozen_string_literal: true

module LeadWorkflows
  class ATCWorkflow < LeadWorkflow
    CONFIG_PATH = 'components/lead_workflows/config/lead_workflows/atc.yml'
    CALL_UNREACHED_DISPOSITION = 'Call Unreached'
    LABEL_STEP_MAPPING = {
      1 => 'attempt to contact 1',
      2 => 'attempt to contact 2',
      3 => 'attempt to contact 3',
      4 => 'attempt to contact 3'
    }.freeze

    class << self
      def triggerable?(msg_data)
        unreached_call_made?(msg_data) || enrolled_in_sequence?(msg_data)
      end

      def enrolled_in_sequence?(msg_data) = msg_data[:sequence_id].present?
      def unreached_call_made?(msg_data) = msg_data[:disposition] == CALL_UNREACHED_DISPOSITION
    end

    def resumable?
      case current_step
      when 0
        true
      else
        lead.label.downcase == LABEL_STEP_MAPPING[current_step]
      end
    end
  end
end
