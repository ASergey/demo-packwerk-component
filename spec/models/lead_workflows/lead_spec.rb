# frozen_string_literal: true

RSpec.describe LeadWorkflows::Lead do
  describe '#contact_fullname' do
    subject(:contact_fullname) { lead.contact_fullname }

    let(:lead) { build(:workflow_lead, context: { contact_firstname: 'John', contact_lastname: 'Doe' }) }

    it { is_expected.to eq 'John Doe' }
  end

  describe '#recycled?' do
    subject { lead.recycled? }

    let(:lead) { build(:workflow_lead, context:) }
    let(:context) { { 'recycled_at' => Time.current } }

    it { is_expected.to be true }

    context 'when no value' do
      let(:context) { {} }

      it { is_expected.to be false }
    end
  end

  describe '#quote_was_signed?' do
    subject { lead.quote_was_signed? }

    let(:lead) { build(:workflow_lead, context:) }
    let(:context) { { 'quote_signed_at' => Time.current } }

    it { is_expected.to be true }

    context 'when no value' do
      let(:context) { {} }

      it { is_expected.to be false }
    end
  end
end
