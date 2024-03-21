# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

describe Decidim::Core::AttachableInterface do
  include_context "with a graphql class type"

  let(:type_class) do
    interface_klass = described_class

    Class.new(Decidim::Api::Types::BaseObject) do
      graphql_name "DummyResource"
      implements interface_klass

      field :id, GraphQL::Types::ID, "The id of this record", null: false
    end
  end

  let(:model) { create(:dummy_resource) }
  let!(:attachments) { create_list(:attachment, 3, attached_to: model) }

  describe "attachments" do
    let(:query) { "{ attachments { id } }" }

    it "includes the attachment ids" do
      attachment_ids = response["attachments"].map { |a| a["id"] }
      expect(attachment_ids).to include(*attachments.map { |a| a.id.to_s })
    end
  end
end
