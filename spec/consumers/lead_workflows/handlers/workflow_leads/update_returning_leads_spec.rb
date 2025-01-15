# frozen_string_literal: true

RSpec.describe LeadWorkflows::Handlers::WorkflowLeads::UpdateReturningLeads do
  subject(:handle) { described_class.new.(msg) }

  let(:msg) { Events::Message.new(type: 'Commissions::CommissionCreated', data:) }
  let(:lead) { create(:workflow_lead, returning: false) }
  let(:data) do
    {
      quote_id:,
      contact_id:,
      source_action:
    }
  end

  let(:quote_id) { 123 }
  let(:contact_id) { lead.contact_id }
  let(:source_action) { 'charge' }

  it 'updates lead returning flag' do
    handle

    expect(lead.reload.returning).to be true
  end

  context "when lead's contact_id does not match" do
    let(:contact_id) { 333 }

    it 'does not update lead retunring flag' do
      handle

      expect(lead.reload.returning).to be false
    end
  end

  context 'with empty quote_id' do
    let(:quote_id) { nil }

    it 'does not update lead retunring flag' do
      handle

      expect(lead.reload.returning).to be false
    end
  end

  context 'without quote_id' do
    let(:data) do
      {
        contact_id:,
        source_action:
      }
    end

    it 'does not update lead retunring flag' do
      handle

      expect(lead.reload.returning).to be false
    end
  end

  context 'when the source_action is not charge' do
    let(:source_action) { 'exchange' }

    it 'does not update lead retunring flag' do
      handle

      expect(lead.reload.returning).to be false
    end
  end
end
