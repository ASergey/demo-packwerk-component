# frozen_string_literal: true

module LeadWorkflows
  module Handlers
    module WorkflowLeads
      class Base
        def call(msg)
          lead = fetch_lead(msg)
          return unless lead

          update_lead(lead, msg)

          lead.save!
        end

        private

        def fetch_lead(msg) = LeadsRepository.get(lead_id: msg.data[:lead_id])
        def update_lead(_lead, _msg) = raise NotImplementedError
      end
    end
  end
end
