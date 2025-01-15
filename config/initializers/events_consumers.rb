# frozen_string_literal: true

Rails.application.reloader.to_prepare do
  Events::ConsumersRegistry.add(LeadWorkflows::EventsConsumer)
end
