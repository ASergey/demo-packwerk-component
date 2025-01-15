# frozen_string_literal: true

RSpec.describe LeadWorkflows::ExecuteResumableWorkflowsJob do
  subject(:job) { described_class.new(ready_to_resume:, execute_workflow:).perform }

  let(:execute_workflow) { class_double(LeadWorkflows::ExecuteWorkflowJob, perform_at: nil) }
  let(:resume_workflows) { double }
  let(:ready_to_resume) { instance_double(LeadWorkflows::ReadyToResumeQuery, call: resume_workflows) }

  before do
    allow(resume_workflows).to receive(:find_each).and_return(:nil)
  end

  it 'does not enqueue any jobs' do
    job
    expect(execute_workflow).not_to have_received(:perform_at)
  end

  context 'with ready to resume workflows' do
    let(:workflow) { create(:new_quote_workflow, resume_at: 10.minutes.from_now) }

    before do
      allow(resume_workflows).to receive(:find_each).and_yield(workflow)
    end

    it 'enqueues lead workflows to be resumed at resume_at time' do
      job
      expect(execute_workflow).to have_received(:perform_at).with(
        workflow.resume_at,
        workflow.id,
        workflow.updated_at.to_i
      )
    end
  end
end
