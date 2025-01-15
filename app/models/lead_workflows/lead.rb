# frozen_string_literal: true

module LeadWorkflows
  class Lead < ApplicationRecord
    self.table_name = 'lead_workflow_leads'
    self.primary_key = :lead_id

    store_accessor :context, :label, :departure, :arrival, :departure_city, :arrival_city, :departure_date,
      :contact_email, :contact_firstname, :contact_lastname, :owner_id

    # TODO: should use namae gem
    def contact_fullname = [context['contact_firstname'], context['contact_lastname']].compact_blank.join(' ')
    def last_enrollment_was = context['enrollment_date']
    def last_unreached_call_was = context['unreached_call_attempt_was']
    def recycled? = context['recycled_at'].present?
    def quote_was_signed? = context['quote_signed_at'].present?
  end
end
