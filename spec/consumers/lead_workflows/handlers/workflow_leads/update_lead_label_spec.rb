# frozen_string_literal: true

RSpec.describe LeadWorkflows::Handlers::WorkflowLeads::UpdateLeadLabel, :freeze_time do
  subject(:handle) { described_class.new.(msg) }

  let(:msg) { Events::Message.new(type: 'Leads::LeadLabelAssigned', data:) }

  let(:lead) { create(:workflow_lead, context: { 'label' => 'Accepted' }) }

  let(:data) do
    {
      lead_id: lead.lead_id,
      label: 'Quoted'
    }
  end

  before do
    allow(Leads).to receive_messages(find: build(:lead_dto))
    allow(Contacts).to receive_messages(find: build(:contact_dto))
  end

  it 'updates lead' do
    handle

    expect(lead.reload.context).to include('label' => 'Quoted')
  end

  context 'when lead missing' do
    let(:data) { super().merge(lead_id: 333) }

    before do
      allow(LeadWorkflows::LeadsRepository).to receive(:fetch).and_return(lead)
    end

    it 'creates lead and updates info' do
      handle

      expect(lead.reload.context).to include('label' => 'Quoted')
    end
  end
end
