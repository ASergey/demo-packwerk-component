# frozen_string_literal: true

module LeadWorkflows
  class EventsConsumer < Events::BaseConsumer
    CONFIG = {
      stream_name: 'lead_workflows',
      durable_name: 'lead_workflows',
      deliver_policy: 'new'
    }.freeze

    attr_reader :config

    def initialize(*, processors: [WorkflowLeadsProcessor.new, WorkflowProcessor.new])
      @processors = processors
      @config = CONFIG.merge(filter_subjects:)

      super(*)
    end

    def process_message(msg)
      ActiveRecord::Base.transaction do
        @processors.each do |processor|
          processor.process_message(msg)
        end
      end
    end

    private

    def filter_subjects
      @processors.each_with_object([]) do |processor, subjects|
        subjects.concat(processor.filter_subjects)
      end.uniq
    end
  end
end
