# frozen_string_literal: true

RSpec.describe LeadWorkflows::Mailer do
  subject(:mail_body) { mail.html_part.body.raw_source }

  let(:mail) { described_class.mail_message(**options) }
  let(:options) do
    {
      subject: 'Email subject',
      from: 'from@mail.com',
      to: 'to@mail.com',
      template_vars:,
      template_path: 'lead_workflows_mailer/quoted_mia',
      template_name: 'email_1'
    }
  end

  let(:template_vars) do
    {
      lead: build(:workflow_lead, context: { 'contact_firstname' => 'firstname' }),
      signature:
    }
  end

  let(:signature) { double }

  before { allow(signature).to receive(:html).and_return('signature') }

  it 'renders email content' do
    expect(mail_body).to include('Hi firstname,')
    expect(mail_body).to include('signature')
    expect(mail.subject).to eq 'Email subject'
    expect(mail.from).to eq ['from@mail.com']
    expect(mail.to).to eq ['to@mail.com']
  end
end
