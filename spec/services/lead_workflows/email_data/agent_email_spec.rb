# frozen_string_literal: true

RSpec.describe LeadWorkflows::EmailData::AgentEmail do
  subject(:email_data) do
    described_class.new(
      email_subject:,
      template_path:,
      template_name:,
      lead:,
      account:
    )
  end

  let(:email_subject) { 'Slow Play' }
  let(:template_path) { 'lead_workflows_mailer/slow_play' }
  let(:template_name) { 'agent_email' }

  let(:account) { build(:account_dto) }
  let(:lead) { build(:workflow_lead) }

  it 'returns initialized class', :aggregate_failures do
    expect(email_data.subject).to eq(email_subject)

    expect(email_data.from).to eq(EmailAddress.new(address: LeadWorkflows::SYSTEM_EMAIL_ADDRESS))
    expect(email_data.to).to contain_exactly(EmailAddress.new(address: account.email, name: account.name))
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
    end

    it 'renders email content' do
      expect(body_html).to include("/admin/leads/show/#{lead.id}")
      expect(LeadWorkflows::Mailer).to have_received(:mail_message).with(
        from: EmailAddress.new(address: LeadWorkflows::SYSTEM_EMAIL_ADDRESS),
        to: [EmailAddress.new(address: account.email, name: account.name)],
        subject: email_subject,
        template_path:,
        template_name:,
        template_vars: {
          lead:,
          lead_url: LeadWorkflows::HOST + "/admin/leads/show/#{lead.id}"
        }
      )
    end
  end
end
