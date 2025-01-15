# frozen_string_literal: true

module LeadWorkflows
  class MessageTransformer
    def initialize(msg) = @message = msg

    def transform
      return @message if @message.type != 'Calls::DispositionCreated'

      fetch_leads.filter_map do |lead|
        next unless lead.label == 'Accepted'

        @message.copy(data: @message.data.merge(lead_id: lead.lead_id))
      end
    end

    private

    def fetch_leads = Lead.where(phone:)
    def phone = @message.data.dig(:contact, :phone)
  end
end
