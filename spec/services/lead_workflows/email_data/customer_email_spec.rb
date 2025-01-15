# frozen_string_literal: true

RSpec.describe LeadWorkflows::EmailData::CustomerEmail do
  subject(:email_data) do
    described_class.new(
      email_subject:,
      template_path:,
      template_name:,
      lead:,
      account:
    )
  end

  let(:email_subject) { 'email subject' }
  let(:template_path) { 'lead_workflows_mailer/quoted_mia' }
  let(:template_name) { 'email_1' }

  let(:account) { build(:account_dto, email: 'agent@email.com') }
  let(:lead) { build(:workflow_lead, context: { contact_email: 'foo@bar.com', contact_firstname: 'foo' }) }

  it 'returns initialized class', :aggregate_failures do
    expect(email_data.subject).to eq(email_subject)

    expect(email_data.from).to eq(EmailAddress.new(address: 'agent@email.com'))
    expect(email_data.to).to contain_exactly(EmailAddress.new(address: 'foo@bar.com', name: 'foo'))
    expect(email_data.external_id).not_to be_nil
    expect(email_data.custom_args).to match(
      mail_type: 'lead_workflow',
      external_id: kind_of(String),
      lead_id: lead.id
    )
  end

  describe '#body_html' do
    subject(:body_html) { email_data.body_html }

    let(:signature) { double }

    before do
      allow(LeadWorkflows::Mailer).to receive(:mail_message).and_call_original
      allow(Accounts).to receive(:email_signature).and_return(signature)
      allow(signature).to receive(:html).and_return('signature')
    end

    it 'renders email content' do
      expect(body_html).to include('Hi foo,')
      expect(LeadWorkflows::Mailer).to have_received(:mail_message).with(
        from: EmailAddress.new(address: account.email),
        to: [EmailAddress.new(address: lead.contact_email, name: lead.contact_firstname)],
        subject: email_subject,
        template_path:,
        template_name:,
        template_vars: {
          account:,
          lead:,
          signature:
        }
      )
    end
  end
end
