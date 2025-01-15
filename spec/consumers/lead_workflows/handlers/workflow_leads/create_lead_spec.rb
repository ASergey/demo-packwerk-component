# frozen_string_literal: true

RSpec.describe LeadWorkflows::Handlers::WorkflowLeads::CreateLead do
  subject(:handle) { described_class.new.(msg) }

  let(:msg) { Events::Message.new(type: 'Leads::LeadCreated', data:) }
  let(:data) { { lead_id: 123, contact_id: 321 } }

  before { allow(LeadWorkflows::LeadsRepository).to receive(:create) }

  it 'creates lead' do
    handle

    expect(LeadWorkflows::LeadsRepository).to have_received(:create).with(123)
  end

  context 'with existing another most recent lead' do
    let!(:most_recent_lead) { create(:workflow_lead, most_recent: true, lead_id: 123, contact_id: 321) }

    it 'updates most recent flag for existing lead' do
      handle
      expect(most_recent_lead.reload.most_recent).to be false
      expect(LeadWorkflows::LeadsRepository).to have_received(:create).with(123)
    end

    context 'when contact_id does not match' do
      let(:data) { { lead_id: 123, contact_id: 123 } }

      it 'does not update most recent flag' do
        handle
        expect(most_recent_lead.reload.most_recent).to be true
        expect(LeadWorkflows::LeadsRepository).to have_received(:create).with(123)
      end
    end

    context 'when existing lead is not most recent' do
      let!(:most_recent_lead) { create(:workflow_lead, most_recent: false, lead_id: 123, contact_id: 321) }

      it 'does not update most recent flag' do
        handle
        expect(most_recent_lead.reload.most_recent).to be false
        expect(LeadWorkflows::LeadsRepository).to have_received(:create).with(123)
      end
    end
  end
end
