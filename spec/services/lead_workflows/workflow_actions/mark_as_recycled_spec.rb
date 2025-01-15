# frozen_string_literal: true

RSpec.describe LeadWorkflows::WorkflowActions::MarkAsRecycled, :freeze_time do
  subject(:execute_workflow) { described_class.new(lead).() }

  let(:lead) { create(:workflow_lead) }

  before do
    allow(Leads).to receive(:mark_recycled!)
  end

  it 'calls leads public api and update context' do
    execute_workflow
    expect(Leads).to have_received(:mark_recycled!).with(lead.id)
    expect(lead.reload.context).to include('recycled_at' => Time.current)
  end

  [Leads::AlreadyRecycledError, Leads::NotMostRecentLead, Leads::PersonalContactError].each do |err|
    context "with error #{err}" do
      before { allow(Leads).to receive(:mark_recycled!).and_raise(err) }

      it 'raises error' do
        expect { execute_workflow }.to raise_error(LeadWorkflows::WorkflowStale)
        expect(lead.reload.context).not_to include('recycled_at')
      end
    end
  end
end
