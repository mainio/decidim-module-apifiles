# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

describe Decidim::Apifiles::AttachableCollectionsMutationsInterface do
  include_context "with a graphql class type"
  include_context "with apifiles graphql mutation"

  let(:type_class) do
    interface_klass = described_class

    Class.new(Decidim::Api::Types::BaseObject) do
      graphql_name "TestRecord"
      implements interface_klass

      field :id, GraphQL::Types::ID, "The id of this record", null: false
    end
  end

  let(:model) { create(:result) }
  let!(:current_user) { create(:user, :confirmed, :admin, organization: model.organization) }

  describe "createAttachmentCollection" do
    let(:name) { generate_localized_title }
    let(:description) { generate_localized_title }
    let(:weight) { 123 }
    let(:key) { "testing" }
    let(:query) do
      %(
        {
          createAttachmentCollection(
            attributes: {
              weight: #{weight},
              key: "#{key}",
              name: #{convert_value(name)},
              description: #{convert_value(description)}
            }
          ) { id }
        }
      )
    end

    it_behaves_like "when the user does not have permissions"

    it "creates an attachment collection" do
      expect { response }.to change(Decidim::AttachmentCollection, :count).by(1)
    end

    it "creates an action log record" do
      expect { response }.to change(Decidim::ActionLog, :count).by(1)
    end

    it "sets all the attributes for the created attachment collection" do
      ac = Decidim::AttachmentCollection.find(response["createAttachmentCollection"]["id"])
      expect(ac.name).to eq(name)
      expect(ac.key).to eq(key)
      expect(ac.description).to eq(description)
      expect(ac.weight).to eq(weight)
      expect(ac.collection_for).to eq(model)
    end

    context "when the key is provided as 'slug'" do
      let(:query) do
        %(
          {
            createAttachmentCollection(
              attributes: {
                weight: #{weight},
                slug: "#{key}",
                name: #{convert_value(name)},
                description: #{convert_value(description)}
              }
            ) { id }
          }
        )
      end

      it "sets all the attributes for the created attachment collection" do
        ac = Decidim::AttachmentCollection.find(response["createAttachmentCollection"]["id"])
        expect(ac.name).to eq(name)
        expect(ac.key).to eq(key)
        expect(ac.description).to eq(description)
        expect(ac.weight).to eq(weight)
        expect(ac.collection_for).to eq(model)
      end
    end

    context "when weight is not provided" do
      let(:query) do
        %(
          {
            createAttachmentCollection(
              attributes: {
                key: "#{key}",
                name: #{convert_value(name)},
                description: #{convert_value(description)}
              }
            ) { id }
          }
        )
      end

      it "sets it to zero" do
        ac = Decidim::AttachmentCollection.find(response["createAttachmentCollection"]["id"])
        expect(ac.weight).to eq(0)
      end
    end

    context "when description is not provided" do
      let(:query) do
        %(
          {
            createAttachmentCollection(
              attributes: {
                key: "#{key}",
                name: #{convert_value(name)}
              }
            ) { id }
          }
        )
      end

      it "sets it to empty" do
        ac = Decidim::AttachmentCollection.find(response["createAttachmentCollection"]["id"])
        expect(ac.description).to be_empty
      end
    end

    context "when key is not provided" do
      let(:query) do
        %(
          {
            createAttachmentCollection(
              attributes: {
                name: #{convert_value(name)}
              }
            ) { id }
          }
        )
      end

      it "sets it to nil" do
        ac = Decidim::AttachmentCollection.find(response["createAttachmentCollection"]["id"])
        expect(ac.key).to be_nil
      end
    end
  end

  describe "updateAttachmentCollection" do
    let(:collection) { create(:attachment_collection, collection_for: model, weight: 999, key: "orig") }

    let(:name) { generate_localized_title }
    let(:description) { generate_localized_title }
    let(:weight) { 123 }
    let(:key) { "testing" }
    let(:query) do
      %(
        {
          updateAttachmentCollection(
            id: "#{collection.id}",
            attributes: {
              weight: #{weight},
              key: "#{key}",
              name: #{convert_value(name)},
              description: #{convert_value(description)}
            }
          ) { id }
        }
      )
    end

    it_behaves_like "when the user does not have permissions"

    it "creates an action log record" do
      expect { response }.to change(Decidim::ActionLog, :count).by(1)
    end

    it "updates all the attributes for the created attachment collection" do
      response
      collection.reload
      expect(collection.name.except("machine_translations")).to eq(name)
      expect(collection.description.except("machine_translations")).to eq(description)
      expect(collection.key).to eq(key)
      expect(collection.weight).to eq(weight)
      expect(collection.collection_for).to eq(model)
    end

    context "when the key is provided as 'slug'" do
      let(:query) do
        %(
          {
            updateAttachmentCollection(
              id: "#{collection.id}",
              attributes: {
                weight: #{weight},
                slug: "#{key}",
                name: #{convert_value(name)},
                description: #{convert_value(description)}
              }
            ) { id }
          }
        )
      end

      it "sets all the attributes for the created attachment collection" do
        response
        collection.reload
        expect(collection.name.except("machine_translations")).to eq(name)
        expect(collection.description.except("machine_translations")).to eq(description)
        expect(collection.key).to eq(key)
        expect(collection.weight).to eq(weight)
        expect(collection.collection_for).to eq(model)
      end
    end

    context "when weight is not provided" do
      let(:query) do
        %(
          {
            updateAttachmentCollection(
              id: "#{collection.id}",
              attributes: {
                key: "#{key}",
                name: #{convert_value(name)},
                description: #{convert_value(description)}
              }
            ) { id }
          }
        )
      end

      it "sets it to zero" do
        response
        collection.reload
        expect(collection.weight).to eq(0)
      end
    end

    context "when description is not provided" do
      let(:query) do
        %(
          {
            updateAttachmentCollection(
              id: "#{collection.id}",
              attributes: {
                key: "#{key}",
                name: #{convert_value(name)}
              }
            ) { id }
          }
        )
      end

      it "keeps the original description" do
        original_description = collection.description
        response
        collection.reload
        expect(collection.description).to eq(original_description)
      end
    end

    context "when key is not provided" do
      let(:query) do
        %(
          {
            updateAttachmentCollection(
              id: "#{collection.id}",
              attributes: {
                name: #{convert_value(name)}
              }
            ) { id }
          }
        )
      end

      it "keeps the original key" do
        original_key = collection.key
        response
        collection.reload
        expect(collection.key).not_to be_empty
        expect(collection.key).to eq(original_key)
      end
    end
  end

  describe "deleteAttachmentCollection" do
    let!(:collection) { create(:attachment_collection, collection_for: model) }
    let(:query) do
      %({ deleteAttachmentCollection(id: "#{collection.id}") { id } })
    end

    it_behaves_like "when the user does not have permissions"

    it "creates an action log record" do
      expect { response }.to change(Decidim::ActionLog, :count).by(1)
    end

    it "deletes the collection" do
      expect { response }.to change(Decidim::AttachmentCollection, :count).by(-1)
    end
  end
end
