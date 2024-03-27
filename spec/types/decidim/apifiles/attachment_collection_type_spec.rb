# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

describe Decidim::Apifiles::AttachmentCollectionType do
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

    it "returns the key" do
      expect(response).to include("slug" => model.key)
    end
  end

  describe "name" do
    let(:query) { '{ name { translation(locale:"en")}}' }

    it "returns the name" do
      expect(response["name"]["translation"]).to eq(model.name["en"])
    end
  end

  describe "description" do
    let(:query) { '{ description { translation(locale:"en")}}' }

    it "returns the description" do
      expect(response["description"]["translation"]).to eq(model.description["en"])
    end
  end
end
