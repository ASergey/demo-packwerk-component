# frozen_string_literal: true

RSpec.describe LeadWorkflows::SlowPlayWorkflow do
  it_behaves_like 'a triggerable lead workflow', [LeadWorkflows::SlowPlayWorkflow::LEAD_LABEL_SLOW_PLAY]
  it_behaves_like 'a resumable lead workflow', :slow_play_workflow,
    [LeadWorkflows::SlowPlayWorkflow::LEAD_LABEL_SLOW_PLAY]
end
