# frozen_string_literal: true

RSpec.describe LeadWorkflows::WorkflowLeadsProcessor do
  describe '#filter_subjects' do
    subject(:processor) { described_class.new }

    it 'returns supported filter subjects' do
      expect(processor.filter_subjects).to eq %w[
        leads.*.created
        leads.*.accepted
        leads.*.deleted
        leads.*.details_updated
        leads.*.label_assigned
        leads.*.reassigned
        leads.*.manually_assigned
        contacts.*.details_updated
        commissions.*.created
        quotes.*.updated
      ]
    end
  end

  describe '#process_message' do
    subject(:process) { described_class.new(handler_list_cls:).process_message(msg) }

    let(:handler_list_cls) { class_double(Events::HandlerList, new: handler_list) }
    let(:handler_list) { instance_double(Events::HandlerList, handle: nil) }

    let(:msg) { 'msg' }

    it 'passes message to handlers' do
      process

      expect(handler_list).to have_received(:handle).with(msg)
    end
  end
end
