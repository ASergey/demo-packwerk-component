# frozen_string_literal: true

module LeadWorkflows
  # :reek:MissingSafeMethod
  class NotReadyWorkflow < LeadWorkflow
    CONFIG_PATH = 'components/lead_workflows/config/lead_workflows/not_ready.yml'
    LEAD_LABEL_NOT_READY = 'not ready (e)'
    TRIGGER_LABELS = [LEAD_LABEL_NOT_READY].freeze

    class << self
      def triggerable?(msg_data)
        trigger_label?(msg_data[:label]) && departure_date_exists?(msg_data[:lead_id])
      end

      private

      def departure_date_exists?(lead_id)
        lead = LeadsRepository.fetch(lead_id)
        lead.departure_date.present?
      end
    end

    def resumable? = lead.label.downcase == LEAD_LABEL_NOT_READY

    private

    def step_resume_time(params)
      case params
      in delay_before_departure:
        step_datetime(delay_before_departure)
      in delay:
        ActiveSupport::Duration.parse(delay).from_now
      else
        raise LeadWorkflows::InvalidConfiguration
      end
    end

    def matches_step_conditions?(params)
      return false unless super
      return true unless params.key?(:delay_before_departure)

      before_departure?(params[:delay_before_departure])
    end

    def before_departure?(delay_before_departure)
      step_datetime(delay_before_departure) >= Time.zone.today
    end

    def step_datetime(delay_before_departure)
      delay_before_departure = ActiveSupport::Duration.parse(delay_before_departure)
      delay_before_departure.before(lead.departure_date.to_datetime).beginning_of_day
    end
  end
end
