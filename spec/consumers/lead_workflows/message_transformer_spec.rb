# frozen_string_literal: true

RSpec.describe LeadWorkflows::MessageTransformer do
  describe '#transform' do
    subject(:transform) { described_class.new(msg).transform }

    let(:msg) { Events::Message.new(type: 'Calls::DispositionCreated', data:) }
    let(:data) { { contact: { phone: '+123456789' } } }

    it 'returns empty array' do
      expect(transform).to be_empty
    end

    context 'with leads' do
      before do
        create(:workflow_lead, phone: '+123456789', id: 102, context: { label: 'Accepted' })
        create(:workflow_lead, phone: '+123456789', id: 103, context: { label: 'Accepted' })
        create(:workflow_lead, phone: '+123456789', id: 104, context: { label: 'Lost' })
      end

      it 'returns message copies feeded with lead_id' do
        expect(transform.size).to eq 2
        expect(transform).to contain_exactly(
          have_attributes(type: 'Calls::DispositionCreated', data: data.merge(lead_id: 102)),
          have_attributes(type: 'Calls::DispositionCreated', data: data.merge(lead_id: 103))
        )
      end
    end
  end
end
