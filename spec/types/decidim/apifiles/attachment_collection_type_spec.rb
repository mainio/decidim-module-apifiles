# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Core
    describe AttachmentCollectionType do
      include_context "with a graphql class type"

      let(:model) { create(:attachment_collection, key: "testing") }

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the id" do
          expect(response).to include("id" => model.id.to_s)
        end
      end

      describe "weight" do
        let(:query) { "{ weight }" }

        it "returns the weight" do
          expect(response).to include("weight" => model.weight)
        end
      end

      describe "key" do
        let(:query) { "{ key }" }

        it "returns the key" do
          expect(response).to include("key" => model.key)
        end
      end

      describe "slug" do
        let(:query) { "{ slug }" }

        it "returns the key through the deprecated slug field" do
          expect(response).to include("slug" => model.key)
        end
      end
    end
  end
end
