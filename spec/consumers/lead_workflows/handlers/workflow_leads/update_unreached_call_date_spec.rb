# frozen_string_literal: true

RSpec.describe LeadWorkflows::Handlers::WorkflowLeads::UpdateUnreachedCallDate, :freeze_time do
  subject(:handle) { described_class.new.(msg) }

  let(:msg) { Events::Message.new(type: 'Calls::DispositionCreated', data:) }
  let(:time) { Time.current }

  let(:data) do
    {
      date_started: time,
      disposition:,
      contact: {
        phone:
      }
    }
  end
  let(:phone) { '+123456789' }

  let(:disposition) { 'Call Unreached' }

  let!(:lead1) { create(:workflow_lead, phone:, id: 123, created_at: Time.current) }
  let!(:lead2) { create(:workflow_lead, phone:, id: 122, created_at: 10.days.ago) }

  it 'updates all founded leads' do
    handle

    expect(lead1.reload.context).to include('unreached_call_attempt_was' => Time.current)
    expect(lead2.reload.context).to include('unreached_call_attempt_was' => Time.current)
  end

  context 'when disposition not supported' do
    let(:data) { super().merge(disposition:) }

    let(:disposition) { 'Contacted' }

    it 'does nothing' do
      handle

      expect(lead1.reload.context).not_to include('unreached_call_attempt_was' => Time.current)
      expect(lead2.reload.context).not_to include('unreached_call_attempt_was' => Time.current)
    end
  end

  context 'when lead not found' do
    let(:data) { super().merge(contact: { phone: 'invalid' }) }

    it 'does nothing' do
      expect(handle).to eq 0
    end
  end
end
