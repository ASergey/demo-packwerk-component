# frozen_string_literal: true

module LeadWorkflows
  class WorkflowLeadsProcessor
    FILTER_SUBJECTS = %w[
      leads.*.created
      leads.*.accepted
      leads.*.deleted
      leads.*.details_updated
      leads.*.label_assigned
      leads.*.reassigned
      leads.*.manually_assigned
      contacts.*.details_updated
      commissions.*.created
      quotes.*.updated
    ].freeze

    HANDLERS = {
      'Commissions::CommissionCreated' => [Handlers::WorkflowLeads::UpdateReturningLeads.new],
      'Contacts::ContactDetailsUpdated' => [Handlers::WorkflowLeads::UpdateContactDetails.new],
      'Leads::LeadAccepted' => [Handlers::WorkflowLeads::UpdateLeadOwner.new],
      'Leads::LeadCreated' => [Handlers::WorkflowLeads::CreateLead.new],
      'Leads::LeadLabelAssigned' => [Handlers::WorkflowLeads::UpdateLeadLabel.new],
      'Leads::LeadDeleted' => [Handlers::WorkflowLeads::DeleteLead.new],
      'Leads::LeadDetailsUpdated' => [Handlers::WorkflowLeads::UpdateLeadDetails.new],
      'Leads::LeadManuallyAssigned' => [Handlers::WorkflowLeads::UpdateLeadOwner.new],
      'Leads::LeadReassigned' => [Handlers::WorkflowLeads::UpdateLeadOwner.new],
      'Quotes::QuoteUpdated' => [Handlers::WorkflowLeads::UpdateLeadQuoteSigned.new]
    }.freeze

    def initialize(handler_list_cls: Events::HandlerList)
      @handlers = handler_list_cls.new(HANDLERS)
    end

    def process_message(msg)
      @handlers.handle(msg)
    end

    def filter_subjects = FILTER_SUBJECTS
  end
end
