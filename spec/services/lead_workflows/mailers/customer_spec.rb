# frozen_string_literal: true

RSpec.describe LeadWorkflows::Mailers::Customer do
  subject(:customer_mailer) { service.(**options) }

  let(:service) { described_class.new(activity:, sendgrid:, factory:) }
  let(:activity) { class_double(Mailers::ActivityJob, perform_async: nil) }
  let(:sendgrid) { class_double(Mailers::SendgridJob, perform_async: nil) }

  let(:factory) { class_double(LeadWorkflows::EmailData::CustomerEmail, new: factory_instance) }
  let(:factory_instance) { instance_double(LeadWorkflows::EmailData::CustomerEmail, create: email_data) }
  let(:email_data) { build_stubbed(:email_data) }

  let(:account) { build(:account_dto) }
  let(:lead) { build(:lead_dto) }
  let(:contact) { build(:contact_dto) }

  let(:options) do
    {
      email_subject: 'email subject',
      template_path: 'lead_workflows_mailer/workflow_name',
      template_name: 'email_1',
      lead:,
      contact:,
      account:
    }
  end

  it 'sends email' do
    customer_mailer

    expect(activity).to have_received(:perform_async).with(email_data.id)
    expect(sendgrid).not_to have_received(:perform_async)
    expect(factory).to have_received(:new).with(**options)
    expect(factory_instance).to have_received(:create)
  end
end
