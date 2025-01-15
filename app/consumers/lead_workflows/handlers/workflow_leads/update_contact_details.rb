# frozen_string_literal: true

module LeadWorkflows
  module Handlers
    module WorkflowLeads
      # :reek:InstanceVariableAssumption
      class UpdateContactDetails
        def call(msg)
          data = msg.data
          leads = Lead.where(contact_id: data.delete(:contact_id))
          return if leads.empty?

          update_leads(leads, data)
        end

        private

        def update_leads(leads, data)
          contact_details = data.transform_keys! { |key| "contact_#{key}" }
          leads.each do |lead|
            lead.context.merge!(**contact_details)
            lead.save!
          end
        end
      end
    end
  end
end
