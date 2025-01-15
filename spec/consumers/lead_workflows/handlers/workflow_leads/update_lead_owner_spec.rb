# frozen_string_literal: true

RSpec.describe LeadWorkflows::Handlers::WorkflowLeads::UpdateLeadOwner, :freeze_time do
  subject(:handle) { described_class.new.(msg) }

  let(:msg) { Events::Message.new(type: 'Leads::LeadAccepted', data:) }

  let(:lead) { create(:workflow_lead, context: { 'owner_id' => 1221 }) }

  let(:data) do
    {
      lead_id: lead.lead_id,
      account_id: 100
    }
  end

  it 'updates lead' do
    handle

    expect(lead.reload.context).to include('owner_id' => 100)
  end

  context 'with another event data' do
    let(:msg) { Events::Message.new(type: 'Leads::LeadReassigned', data:) }
    let(:data) do
      {
        lead_id: lead.lead_id,
        reassigned_to: {
          account_id: 100
        }
      }
    end

    it 'updates lead' do
      handle

      expect(lead.reload.context).to include('owner_id' => 100)
    end
  end

  context 'when lead missing' do
    let(:data) { super().merge(lead_id: 333) }

    it 'does nothing' do
      expect(handle).to be_nil
    end
  end
end
