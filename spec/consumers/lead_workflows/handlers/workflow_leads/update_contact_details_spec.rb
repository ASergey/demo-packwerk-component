# frozen_string_literal: true

RSpec.describe LeadWorkflows::Handlers::WorkflowLeads::UpdateContactDetails do
  subject(:handle) { described_class.new.(msg) }

  let(:msg) { Events::Message.new(type: 'Contacts::ContactDetailsUpdated', data:) }

  let!(:lead) { create(:workflow_lead, contact_id: 1212, context: { 'contact_firstname' => 'OldName' }) }
  let(:data) do
    {
      contact_id: 1212,
      firstname: 'NewName'
    }
  end

  it 'updates lead' do
    handle

    expect(lead.reload.context).to include('contact_firstname' => 'NewName')
  end

  context 'when contact_id does not match' do
    let(:data) do
      {
        contact_id: 1313,
        firstname: 'NewName'
      }
    end

    it 'does nothing' do
      expect(handle).to be_nil
    end
  end
end
