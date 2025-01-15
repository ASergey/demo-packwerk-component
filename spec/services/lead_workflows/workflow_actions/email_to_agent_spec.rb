# frozen_string_literal: true

RSpec.describe LeadWorkflows::WorkflowActions::EmailToAgent do
  subject(:send_agent_email) do
    described_class.new(lead, subject: email_subject, template_path:, template_name:, agent_mailer:).()
  end

  let(:agent_mailer) { instance_double(LeadWorkflows::Mailers::Agent, call: true) }
  let(:email_subject) { 'subject' }
  let(:template_path) { 'path' }
  let(:template_name) { 'name' }
  let(:lead) do
    build(
      :workflow_lead,
      context: { contact_firstname: 'John', contact_lastname: 'Doe', departure: 'LAX', arrival: 'SFO' }
    )
  end
  let(:account) { build(:account_dto) }

  before do
    allow(Accounts).to receive(:find).and_return(account)
  end

  it 'sends email to agent' do
    send_agent_email
    expect(agent_mailer).to have_received(:call).with(
      email_subject: 'subject',
      template_path: 'path',
      template_name: 'name',
      lead:, account:
    )
  end

  context 'when subject with interpolations' do
    let(:email_subject) { 'subject for %<contact_fullname>s | %<lead_from>s - %<lead_to>s' }

    it 'sends interpolates contact full name to subject' do
      send_agent_email
      expect(agent_mailer).to have_received(:call).with(
        include(email_subject: 'subject for John Doe | LAX - SFO')
      )
    end
  end

  context 'when account is not found' do
    before { allow(Accounts).to receive(:find).and_raise(ActiveRecord::RecordNotFound) }

    it 'raises error' do
      expect { send_agent_email }.to raise_error(LeadWorkflows::RecordNotFound)
    end
  end
end
