# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

describe Decidim::Core::AttachmentType do
  include_context "with a graphql class type"

  let(:model) { create(:attachment) }

  describe "id" do
    let(:query) { "{ id }" }

    it "returns the id" do
      expect(response).to include("id" => model.id.to_s)
    end
  end

  describe "fileBlob" do
    let(:query) { "{ fileBlob { id } }" }

    it "does not return the blob for unauthorized users" do
      expect(response["fileBlob"]).to be_nil
    end

    context "when signed in as an admin" do
      let!(:current_user) { create(:user, :confirmed, :admin, organization: current_organization) }

      it "returns the blob's id" do
        blob = response["fileBlob"]
        expect(blob).to include("id" => model.file.blob.id.to_s)
      end
    end
  end

  describe "collection" do
    let(:query) { "{ collection { id } }" }

    let(:model) { create(:attachment, attached_to: result, attachment_collection: collection) }
    let(:collection) { create(:attachment_collection, collection_for: result) }
    let(:result) { create(:result) }

    it "returns the collection id" do
      col = response["collection"]
      expect(col).to include("id" => collection.id.to_s)
    end
  end
end
