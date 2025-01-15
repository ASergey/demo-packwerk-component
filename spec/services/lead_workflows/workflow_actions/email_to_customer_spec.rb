# frozen_string_literal: true

RSpec.describe LeadWorkflows::WorkflowActions::EmailToCustomer do
  subject(:send_customer_email) do
    described_class.new(lead, subject: email_subject, template_path:, template_name:, customer_mailer:).()
  end

  let(:customer_mailer) { instance_double(LeadWorkflows::Mailers::Customer, call: true) }
  let(:email_subject) { 'subject for %<contact_firstname>s | %<arrival_city>s' }
  let(:template_path) { 'path' }
  let(:template_name) { 'name' }
  let(:lead) do
    build(:workflow_lead, context: { contact_firstname: 'John', owner_id: account.id, arrival_city: 'city' })
  end
  let(:account) { build(:account_dto) }

  before do
    allow(Accounts).to receive(:find).and_return(account)
  end

  it 'sends email to customer' do
    send_customer_email
    expect(customer_mailer).to have_received(:call).with(
      email_subject: 'subject for John | city',
      template_path: 'path',
      template_name: 'name',
      lead:, account:
    )
  end

  context 'when account is not found' do
    before { allow(Accounts).to receive(:find).and_raise(ActiveRecord::RecordNotFound) }

    it 'raises error' do
      expect { send_customer_email }.to raise_error(LeadWorkflows::RecordNotFound)
    end
  end
end
