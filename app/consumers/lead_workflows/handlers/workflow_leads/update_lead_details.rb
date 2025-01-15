# frozen_string_literal: true

module LeadWorkflows
  module Handlers
    module WorkflowLeads
      class UpdateLeadDetails < Base
        SUPPORTED_DETAILS = %i[arrival departure].freeze

        private

        def update_lead(lead, msg)
          lead.context.merge!(**msg.data.slice(*SUPPORTED_DETAILS), **resolve_cities(msg))
        end

        def resolve_cities(msg)
          data = msg.data
          {
            departure_city: Airports.resolve_city(data[:departure]),
            arrival_city: Airports.resolve_city(data[:arrival])
          }
        end
      end
    end
  end
end
