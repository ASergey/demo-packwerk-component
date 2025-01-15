# frozen_string_literal: true

FactoryBot.define do
  factory :workflow_lead, class: 'LeadWorkflows::Lead' do
    sequence(:lead_id) { |n| 10_100 + n }
    contact_id { 11_100 }
    phone { '+111111111111' }
    email { 'test@mail.com' }

    context { {} }
  end
end
