# frozen_string_literal: true

require "spec_helper"

describe Decidim::AttachmentCollection do
  subject { attachment_collection }

  let(:attachment_collection) { build(:attachment_collection, collection_for: model) }
  let(:model) { create(:result) }

  it { is_expected.to be_valid }

  context "with slug" do
    let(:attachment_collection) { build(:attachment_collection, collection_for: model, slug: "testing") }

    it { is_expected.to be_valid }

    context "when another record uses the same slug" do
      let(:other_collection) { build(:attachment_collection, slug: "testing") }

      it { is_expected.to be_valid }
    end

    context "when duplicate" do
      let!(:other_collection) { create(:attachment_collection, slug: "testing", collection_for: model) }

      it { is_expected.not_to be_valid }

      it "adds an error" do
        subject.valid?
        expect(subject.errors[:slug]).to eq ["has already been taken"]
      end
    end
  end
end
