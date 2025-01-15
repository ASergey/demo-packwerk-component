# frozen_string_literal: true

RSpec.describe LeadWorkflows::Handlers::WorkflowLeads::UpdateLeadQuoteSigned do
  subject(:handle) { described_class.new.(msg) }

  let(:msg) { Events::Message.new(type: 'Quotes::QuoteUpdated', data:) }

  let(:lead) { create(:workflow_lead) }

  let(:data) do
    {
      quote_id: 123,
      lead_id: lead.lead_id,
      status: 'signed'
    }
  end

  it 'updates the lead', :freeze_time do
    handle

    expect(lead.reload.context).to include('quote_signed_at' => Time.current)
  end

  context 'when the lead is missing' do
    let(:data) { super().merge(lead_id: 333) }

    it 'does nothing' do
      expect(handle).to be_nil
    end
  end
end
