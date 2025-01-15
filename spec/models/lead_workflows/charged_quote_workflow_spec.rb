# frozen_string_literal: true

RSpec.describe LeadWorkflows::ChargedQuoteWorkflow do
  describe '.maybe_trigger' do
    subject(:maybe_trigger) { described_class.maybe_trigger(msg) }

    let(:msg) { Events::Message.new(type: 'Quotes::UpdatedCreated', data:) }
    let(:data) { attributes_for(:quote_updated_event, lead_id:, status:) }
    let(:status) { 'charged' }
    let(:lead_id) { 10_100 }

    it 'creates new workflow', :freeze_time do
      workflow = maybe_trigger
      expect(workflow).to be_a(described_class)
      expect(workflow.lead_id).to eq(lead_id)
      expect(workflow.context).to include('quote_id' => data[:quote_id], 'status' => status, 'step' => 0)
      expect(workflow).to be_created
      expect(workflow.resume_at).to eq Time.current
    end

    context 'when the quote updated is without lead' do
      let(:data) { attributes_for(:quote_updated_event, lead_id: nil, status:) }

      it 'does not trigger workflow' do
        expect { maybe_trigger }.not_to change(described_class, :count)
        expect(maybe_trigger).to be_nil
      end
    end

    context "when quote event with not 'charged' status" do
      let(:status) { 'booked' }

      it 'does not trigger workflow' do
        expect { maybe_trigger }.not_to change(described_class, :count)
        expect(maybe_trigger).to be_nil
      end
    end
  end
end
