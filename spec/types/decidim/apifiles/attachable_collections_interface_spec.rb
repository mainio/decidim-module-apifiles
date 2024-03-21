# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

describe Decidim::Apifiles::AttachableCollectionsInterface do
  include_context "with a graphql class type"

  let(:type_class) do
    interface_klass = described_class

    Class.new(Decidim::Api::Types::BaseObject) do
      graphql_name "TestRecord"
      implements interface_klass

      field :id, GraphQL::Types::ID, "The id of this record", null: false
    end
  end

  let(:model) { create(:result) }
  let!(:attachment_collections) { create_list(:attachment_collection, 3, collection_for: model) }

  describe "attachments" do
    let(:query) { "{ attachmentCollections { id } }" }

    it "includes the attachment ids" do
      collection_ids = response["attachmentCollections"].map { |c| c["id"] }
      expect(collection_ids).to include(*attachment_collections.map { |c| c.id.to_s })
    end
  end
end
