# frozen_string_literal: true

RSpec.describe LeadWorkflows::LeadsRepository do
  describe '.get' do
    subject(:get) { described_class.get(**params) }

    let!(:lead) { create(:workflow_lead) }

    let(:params) { { lead_id: lead.id } }

    before { create(:workflow_lead) }

    it 'searches by privided params' do
      expect(get).to eq(lead)
    end
  end

  describe '.fetch' do
    subject(:fetch) { described_class.fetch(lead_id) }

    let(:lead) { create(:workflow_lead) }
    let(:lead_id) { lead.id }

    let(:lead_dto) { build(:lead_dto, id: 132) }
    let(:contact_dto) { build(:contact_dto) }

    before do
      allow(Leads).to receive_messages(find: lead_dto)
      allow(Contacts).to receive_messages(find: contact_dto)
    end

    it 'returns a lead' do
      expect(fetch).to eq lead
    end

    context 'when lead is missing' do
      let(:lead_id) { 132 }

      it 'returns newly created lead' do
        fetch

        expect(fetch.lead_id).to eq lead_id
      end
    end
  end

  describe '.create' do
    subject(:fetch) { described_class.create(lead_id) }

    let(:lead_dto) { build(:lead_dto, id: 132) }
    let(:contact_dto) { build(:contact_dto) }

    let(:lead_id) { 132 }

    before do
      allow(Leads).to receive_messages(find: lead_dto)
      allow(Contacts).to receive_messages(find: contact_dto)
    end

    it 'returns newly created lead' do
      fetch

      expect(fetch.lead_id).to eq lead_id
    end
  end
end
