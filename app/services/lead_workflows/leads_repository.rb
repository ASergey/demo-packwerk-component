# frozen_string_literal: true

module LeadWorkflows
  class LeadsRepository
    def self.fetch(lead_id)
      Lead
        .create_with(**lead_params(lead_id))
        .find_or_create_by!(lead_id:)
    end

    def self.get(**) = Lead.find_by(**)

    def self.create(lead_id)
      Lead
        .create_with(**lead_params(lead_id))
        .create_or_find_by!(lead_id:)
    end

    def self.lead_params(lead_id)
      lead_dto = Leads.find(lead_id)
      contact_id = lead_dto.contact_id
      contact_dto = Contacts.find(contact_id)

      {
        lead_id: lead_dto.id, contact_id:,
        phone: lead_dto.phone, email: lead_dto.email,
        returning: lead_dto.returning, most_recent: lead_dto.most_recent,
        context: context(lead_dto, contact_dto)
      }
    end

    def self.context(lead_dto, contact_dto)
      {
        label: lead_dto.label,
        departure_date: lead_dto.departure_date,
        owner_id: lead_dto.agent_id,
        **contact_context(contact_dto),
        **lead_destinations(lead_dto)
      }
    end

    def self.contact_context(contact_dto)
      {
        contact_email: contact_dto.email,
        contact_firstname: contact_dto.firstname,
        contact_lastname: contact_dto.lastname
      }
    end

    def self.lead_destinations(lead_dto)
      departure = lead_dto.departure
      arrival = lead_dto.arrival

      {
        departure:,
        arrival:,
        departure_city: Airports.resolve_city(departure),
        arrival_city: Airports.resolve_city(arrival)
      }
    end

    private_class_method :lead_params, :context
  end
end
