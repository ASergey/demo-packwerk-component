# frozen_string_literal: true

RSpec.describe LeadWorkflows::Handlers::WorkflowLeads::UpdateEnrollmentDate, :freeze_time do
  subject(:handle) { described_class.new.(msg) }

  let(:msg) { Events::Message.new(type: 'Sequences::ContactEnrolled', time:, data:) }
  let(:time) { Time.current }

  let(:data) do
    {
      sequence_id: 111,
      lead_id: 123,
      contact_id: 321
    }
  end

  let!(:lead) { create(:workflow_lead, lead_id: 123) }

  it 'updates lead' do
    handle

    expect(lead.reload.context).to include('enrollment_date' => Time.current)
  end

  context 'when lead missing' do
    let(:data) { super().merge(lead_id: 333) }

    it 'does nothing' do
      expect(handle).to be_nil
    end
  end
end
