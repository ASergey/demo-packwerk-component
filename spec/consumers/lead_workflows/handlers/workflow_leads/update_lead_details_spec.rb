# frozen_string_literal: true

RSpec.describe LeadWorkflows::Handlers::WorkflowLeads::UpdateLeadDetails do
  subject(:handle) { described_class.new.(msg) }

  let(:msg) { Events::Message.new(type: 'Leads::LeadDetailsUpdated', data:) }

  let(:lead) { create(:workflow_lead, context: { 'departure' => 'DME' }) }

  let(:data) do
    {
      lead_id: lead.lead_id,
      departure: 'Domodedovo'
    }
  end

  before do
    allow(Airports).to receive(:resolve_city).and_return('Moscow')
  end

  it 'updates lead' do
    handle

    expect(lead.reload.context).to include('departure' => 'Domodedovo')
    expect(lead.context).to include('departure_city' => 'Moscow')
  end

  context 'when lead missing' do
    let(:data) { super().merge(lead_id: 333) }

    it 'does nothing' do
      expect(handle).to be_nil
    end
  end
end
