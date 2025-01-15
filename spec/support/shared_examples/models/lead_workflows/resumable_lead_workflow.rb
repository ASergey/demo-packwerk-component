# frozen_string_literal: true

RSpec.shared_examples 'a resumable lead workflow' do |workflow_name, labels|
  describe '#resumable?' do
    subject(:resumable?) { workflow.resumable? }

    let(:workflow) { build(workflow_name.to_sym, lead_id: lead.id) }

    before do
      allow(Leads).to receive_messages(find: build(:lead_dto))
      allow(Contacts).to receive_messages(find: build(:contact_dto))
    end

    labels.each do |label|
      context "with #{label} label" do
        let(:lead) { create(:workflow_lead, context: { 'label' => label }) }

        it { is_expected.to be true }
      end
    end

    context 'with any other label' do
      let(:lead) { create(:workflow_lead, context: { 'label' => 'other' }) }

      it { is_expected.to be false }
    end
  end
end
