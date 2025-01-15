# frozen_string_literal: true

RSpec.describe LeadWorkflows::CompetitorWorkflow do
  it_behaves_like 'a triggerable lead workflow', [LeadWorkflows::CompetitorWorkflow::LEAD_LABEL_COMPETITOR]
  it_behaves_like 'a resumable lead workflow', :competitor_workflow,
    [LeadWorkflows::CompetitorWorkflow::LEAD_LABEL_COMPETITOR]
end
