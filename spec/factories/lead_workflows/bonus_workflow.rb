# frozen_string_literal: true

FactoryBot.define do
  factory :bonus_workflow, class: 'LeadWorkflows::BonusWorkflow' do
    lead_id { 10_100 }
    type { 'LeadWorkflows::BonusWorkflow' }
    status { :created }
    resume_at { Time.current }
    context { { 'step' => 0 } }
  end
end
