# frozen_string_literal: true

RSpec.describe LeadWorkflows::ReadyToResumeQuery, :freeze_time do
  subject(:query) { described_class.new.() }

  let!(:workflow) { create(:new_quote_workflow, resume_at:, status:) }
  let(:resume_at) { Time.current }
  let(:status) { LeadWorkflows::NewQuoteWorkflow.statuses[:created] }

  it 'returns ready to resume workflows' do
    expect(query).to contain_exactly(workflow)
  end

  context 'when workflow is in progress' do
    let(:status) { LeadWorkflows::NewQuoteWorkflow.statuses[:in_progress] }

    it { is_expected.to contain_exactly(workflow) }
  end

  context 'when workflow is finished' do
    let(:status) { LeadWorkflows::NewQuoteWorkflow.statuses[:finished] }

    it { is_expected.to be_empty }
  end

  context 'when workflow resume_at is in future within 15 minutes gap' do
    let(:resume_at) { 10.minutes.from_now }

    it { is_expected.to contain_exactly(workflow) }
  end

  context 'when workflow resume_at is later than 15 minutes from now' do
    let(:resume_at) { 20.minutes.from_now }

    it { is_expected.to be_empty }
  end

  context 'when workflow resume_at is in the past' do
    let(:resume_at) { 10.minutes.ago }

    it { is_expected.to contain_exactly(workflow) }
  end
end
