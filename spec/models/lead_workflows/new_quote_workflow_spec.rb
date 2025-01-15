# frozen_string_literal: true

RSpec.describe LeadWorkflows::NewQuoteWorkflow do
  describe '.maybe_trigger' do
    subject(:maybe_trigger) { described_class.maybe_trigger(msg) }

    let(:msg) { Events::Message.new(type: 'Quotes::QuoteCreated', data:) }
    let(:data) { attributes_for(:quote_created_event, lead_id:) }
    let(:lead_id) { 10_100 }

    it 'creates new workflow', :freeze_time do
      workflow = maybe_trigger
      expect(workflow).to be_a(described_class)
      expect(workflow.lead_id).to eq(lead_id)
      expect(workflow.context).to include('quote_id' => data[:quote_id], 'status' => data[:status], 'step' => 0)
      expect(workflow).to be_created
      expect(workflow.resume_at).to eq Time.current
    end

    context 'when the quote created is without lead' do
      let(:data) { attributes_for(:quote_created_event, lead_id: nil) }

      it 'does not trigger workflow' do
        expect { maybe_trigger }.not_to change(described_class, :count)
        expect(maybe_trigger).to be_nil
      end
    end

    context "when quote event with not 'new' status" do
      let(:data) { attributes_for(:quote_created_event, :exchange) }

      it 'does not trigger workflow' do
        expect { maybe_trigger }.not_to change(described_class, :count)
        expect(maybe_trigger).to be_nil
      end
    end
  end
end
