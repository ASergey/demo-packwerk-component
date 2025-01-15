# frozen_string_literal: true

module LeadWorkflows
  # :reek:MissingSafeMethod
  # :reek:TooManyMethods
  class LeadWorkflow < ApplicationRecord
    TRIGGER_LABELS = [].freeze

    enum :status, {
      created: 'created',
      in_progress: 'in_progress',
      finished: 'finished'
    }

    class << self
      def maybe_trigger(msg)
        data = msg.data
        return unless triggerable?(data)

        workflow = create!(lead_id: data[:lead_id], context: workflow_context(data), resume_at: first_resume_at)
        EventLogger.info(event: 'lead_workflows.workflow_created', type: sti_name, workflow_id: workflow.id)
        workflow
      end

      def triggerable?(msg_data) = trigger_label?(msg_data[:label])

      def first_resume_at
        case workflow_config.first&.deep_symbolize_keys!
        in delay:
          ActiveSupport::Duration.parse(delay).from_now
        else
          Time.current
        end
      end

      def workflow_config = YAML.load_file(self::CONFIG_PATH) || [{}]

      private

      def trigger_label?(label) = label&.downcase.in?(self::TRIGGER_LABELS)
      def workflow_context(_msg_data) = { step: 0 }
    end

    delegate :returning?, to: :lead, prefix: true
    delegate :recycled?, to: :lead, prefix: true
    delegate :most_recent?, to: :lead, prefix: true

    def finish_workflow!(error = nil)
      update!(status: :finished, error:)
      EventLogger.info(
        event: 'lead_workflows.workflow_finished',
        type: type,
        workflow_id: id,
        error:
      )
    end

    # TODO: this is a temporary solution. Should be refactored with association.
    # This need because after release we still can have workflow related to quotes
    # and without lead in workflow component.
    def lead = @lead ||= LeadsRepository.fetch(lead_id)
    def resumable? = true
    def current_step_params = workflow_config[current_step]&.deep_symbolize_keys!
    def complete_step! = last_step? ? finish_workflow! : next_step!

    private

    def next_step!
      step_params = next_step_params
      return finish_workflow! unless step_params

      resume_at = step_resume_time(step_params)
      update!(resume_params(resume_at))
    end

    def step_resume_time(params)
      case params
      in delay:
        ActiveSupport::Duration.parse(delay).from_now
      else
        raise LeadWorkflows::InvalidConfiguration
      end
    end

    def resume_params(resume_at)
      {
        resume_at:,
        status: :in_progress,
        context: context.merge({ step: current_step + 1 })
      }
    end

    def workflow_config = @workflow_config ||= self.class.workflow_config
    def last_step? = current_step >= workflow_config.size - 1
    def current_step = @current_step ||= (context && context['step']).try(:to_i) || 0

    def next_step_params
      return if last_step?

      params = workflow_config[current_step + 1]&.deep_symbolize_keys!
      return params if matches_step_conditions?(params)

      @current_step += 1
      next_step_params
    end

    def matches_step_conditions?(params)
      conditions = params[:if]
      return true unless conditions

      conditions.is_a?(Array) ? meets_all_conditions?(conditions) : meets_any_condition?(conditions)
    end

    def meets_all_conditions?(conditions) = conditions.all? { |condition| meets_any_condition?(condition) }

    # :reek:ManualDispatch
    def meets_any_condition?(conditions)
      conditions.any? do |condition, required_value|
        unless respond_to?(condition)
          raise LeadWorkflows::InvalidConfiguration,
            "Unknown 'if' condition: #{condition}"
        end

        send(:"#{condition}") == required_value
      end
    end
  end
end
