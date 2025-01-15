# frozen_string_literal: true

RSpec.describe LeadWorkflows::PlansChangedWorkflow do
  it_behaves_like 'a triggerable lead workflow', [LeadWorkflows::PlansChangedWorkflow::LEAD_LABEL_PLANS_CHANGED]
  it_behaves_like 'a resumable lead workflow', :plans_changed_workflow,
    [LeadWorkflows::PlansChangedWorkflow::LEAD_LABEL_PLANS_CHANGED]
end
