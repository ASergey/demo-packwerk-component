# frozen_string_literal: true

FactoryBot.define do
  factory :atc_workflow, class: 'LeadWorkflows::ATCWorkflow' do
    lead_id { 10_100 }
    type { 'LeadWorkflows::ATCWorkflow' }
    status { LeadWorkflows::ATCWorkflow.statuses[:created] }
    resume_at { Time.current }
    context { { 'step' => 0 } }
  end
end
