# frozen_string_literal: true

FactoryBot.define do
  factory :recycle_workflow, class: 'LeadWorkflows::RecycleWorkflow' do
    lead_id { 10_100 }
    type { 'LeadWorkflows::RecycleWorkflow' }
    status { LeadWorkflows::RecycleWorkflow.statuses[:created] }
    resume_at { Time.current }
    context { { 'step' => 0, 'triggered_label' => 'No response' } }
  end
end
