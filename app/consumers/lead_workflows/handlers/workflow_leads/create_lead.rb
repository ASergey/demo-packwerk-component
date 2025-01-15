# frozen_string_literal: true

module LeadWorkflows
  module Handlers
    module WorkflowLeads
      class CreateLead
        def call(msg)
          data = msg.data
          update_most_recent_lead(data[:contact_id])
          LeadsRepository.create(data[:lead_id])
        end

        private

        def update_most_recent_lead(contact_id)
          most_recent_lead(contact_id)&.update!(most_recent: false)
        end

        def most_recent_lead(contact_id) = Lead.find_by(most_recent: true, contact_id:)
      end
    end
  end
end
