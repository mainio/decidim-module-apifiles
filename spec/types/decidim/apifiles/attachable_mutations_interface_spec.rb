# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

describe Decidim::Apifiles::AttachableMutationsInterface do
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

  describe "createAttachment" do
    let(:title) { generate_localized_title }
    let(:description) { generate_localized_title }
    let(:weight) { 123 }
    let(:query) do
      %(
        {
          createAttachment(
            attributes: {
              weight: #{weight},
              title: #{convert_value(title)},
              description: #{convert_value(description)},
              file: { blobId: #{blob.id} }
            }
          ) { id }
        }
      )
    end
    let(:blob) do
      ActiveStorage::Blob.create_and_upload!(
        io: File.open(Decidim::Dev.asset("city.jpeg")),
        filename: "city.jpeg",
        content_type: "image/jpeg"
      )
    end

    it_behaves_like "when the user does not have permissions"

    it "creates an attachment" do
      expect { response }.to change(Decidim::Attachment, :count).by(1)
    end

    it "creates an action log record" do
      expect { response }.to change(Decidim::ActionLog, :count).by(1)
    end

    it "sets all the attributes for the created attachment" do
      attachment = Decidim::Attachment.find(response["createAttachment"]["id"])
      expect(attachment.title).to eq(title)
      expect(attachment.description).to eq(description)
      expect(attachment.weight).to eq(weight)
      expect(attachment.file.blob).to eq(blob)
      expect(attachment.attached_to).to eq(model)
      expect(attachment.attachment_collection).to be_nil
    end

    context "when weight is not provided" do
      let(:query) do
        %(
          {
            createAttachment(
              attributes: {
                title: #{convert_value(title)},
                description: #{convert_value(description)},
                file: { blobId: #{blob.id} }
              }
            ) { id }
          }
        )
      end

      it "sets it to zero" do
        attachment = Decidim::Attachment.find(response["createAttachment"]["id"])
        expect(attachment.weight).to eq(0)
      end
    end

    context "when description is not provided" do
      let(:query) do
        %(
          {
            createAttachment(
              attributes: {
                title: #{convert_value(title)},
                file: { blobId: #{blob.id} }
              }
            ) { id }
          }
        )
      end

      it "sets it to empty" do
        attachment = Decidim::Attachment.find(response["createAttachment"]["id"])
        expect(attachment.description).to be_empty
      end
    end

    context "when collection is provided using ID" do
      let(:query) do
        %(
          {
            createAttachment(
              attributes: {
                title: #{convert_value(title)},
                file: { blobId: #{blob.id} },
                collection: { id: "#{collection.id}" }
              }
            ) { id }
          }
        )
      end

      let(:collection) { create(:attachment_collection, collection_for: model) }

      it "sets the collection" do
        attachment = Decidim::Attachment.find(response["createAttachment"]["id"])
        expect(attachment.attachment_collection).to eq(collection)
      end

      context "and the collection belongs to another object" do
        let(:collection) { create(:attachment_collection, collection_for: other, slug: "testing") }
        let(:other) { create(:result) }

        it "does not create the attachment" do
          expect { response }.to raise_error(StandardError)
        end
      end

      context "and the ID is not set" do
        let(:query) do
          %(
            {
              createAttachment(
                attributes: {
                  title: #{convert_value(title)},
                  file: { blobId: #{blob.id} },
                  collection: { id: null }
                }
              ) { id }
            }
          )
        end

        it "does not create the attachment" do
          expect { response }.to raise_error(StandardError)
        end
      end
    end

    context "when collection is provided using slug" do
      let(:query) do
        %(
          {
            createAttachment(
              attributes: {
                title: #{convert_value(title)},
                file: { blobId: #{blob.id} },
                collection: { slug: "#{collection.slug}" }
              }
            ) { id }
          }
        )
      end

      let!(:collection) { create(:attachment_collection, collection_for: model, slug: "testing") }

      it "sets the collection" do
        attachment = Decidim::Attachment.find(response["createAttachment"]["id"])
        expect(attachment.attachment_collection).to eq(collection)
      end

      context "and the slug is not found" do
        let(:query) do
          %(
            {
              createAttachment(
                attributes: {
                  title: #{convert_value(title)},
                  file: { blobId: #{blob.id} },
                  collection: { slug: "foobar" }
                }
              ) { id }
            }
          )
        end

        it "does not create the attachment" do
          expect { response }.to raise_error(StandardError)
        end
      end

      context "and the collection belongs to another object" do
        let!(:collection) { create(:attachment_collection, collection_for: other, slug: "testing") }
        let(:other) { create(:result) }

        it "does not create the attachment" do
          expect { response }.to raise_error(StandardError)
        end
      end

      context "and the slug is empty" do
        let(:query) do
          %(
            {
              createAttachment(
                attributes: {
                  title: #{convert_value(title)},
                  file: { blobId: #{blob.id} },
                  collection: { slug: "" }
                }
              ) { id }
            }
          )
        end

        it "does not create the attachment" do
          expect { response }.to raise_error(StandardError)
        end
      end

      context "and the slug is not set" do
        let(:query) do
          %(
            {
              createAttachment(
                attributes: {
                  title: #{convert_value(title)},
                  file: { blobId: #{blob.id} },
                  collection: { slug: null }
                }
              ) { id }
            }
          )
        end

        it "does not create the attachment" do
          expect { response }.to raise_error(StandardError)
        end
      end
    end
  end

  describe "updateAttachment" do
    let(:attachment) { create(:attachment, attached_to: model, weight: 999) }

    let(:title) { generate_localized_title }
    let(:description) { generate_localized_title }
    let(:weight) { 123 }
    let(:query) do
      %(
        {
          updateAttachment(
            id: "#{attachment.id}",
            attributes: {
              weight: #{weight},
              title: #{convert_value(title)},
              description: #{convert_value(description)},
              file: { blobId: #{blob.id} }
            }
          ) { id }
        }
      )
    end
    let(:blob) do
      ActiveStorage::Blob.create_and_upload!(
        io: File.open(Decidim::Dev.asset("city.jpeg")),
        filename: "city.jpeg",
        content_type: "image/jpeg"
      )
    end

    it_behaves_like "when the user does not have permissions"

    it "updates the existing attachment" do
      orig_updated_at = attachment.updated_at
      response
      expect(attachment.reload.updated_at).to be > orig_updated_at
    end

    it "creates an action log record" do
      expect { response }.to change(Decidim::ActionLog, :count).by(1)
    end

    it "updates all the attributes for the attachment" do
      response
      attachment.reload
      expect(attachment.title.except("machine_translations")).to eq(title)
      expect(attachment.description.except("machine_translations")).to eq(description)
      expect(attachment.weight).to eq(weight)
      expect(attachment.file.blob).to eq(blob)
      expect(attachment.attachment_collection).to be_nil
    end

    context "when weight is not provided" do
      let(:query) do
        %(
          {
            updateAttachment(
              id: "#{attachment.id}",
              attributes: {
                title: #{convert_value(title)},
                description: #{convert_value(description)},
                file: { blobId: #{blob.id} }
              }
            ) { id }
          }
        )
      end

      it "sets it to zero" do
        response
        attachment.reload
        expect(attachment.weight).to eq(0)
      end
    end

    context "when description is not provided" do
      let(:query) do
        %(
          {
            updateAttachment(
              id: "#{attachment.id}",
              attributes: {
                title: #{convert_value(title)},
                file: { blobId: #{blob.id} }
              }
            ) { id }
          }
        )
      end

      it "keeps the original description" do
        original_description = attachment.description
        response
        attachment.reload
        expect(attachment.description).to eq(original_description)
      end
    end

    context "when collection is provided using ID" do
      let(:query) do
        %(
          {
            updateAttachment(
              id: "#{attachment.id}",
              attributes: {
                title: #{convert_value(title)},
                file: { blobId: #{blob.id} },
                collection: { id: "#{collection.id}" }
              }
            ) { id }
          }
        )
      end

      let(:collection) { create(:attachment_collection, collection_for: model) }

      it "sets the collection" do
        response
        attachment.reload
        expect(attachment.attachment_collection).to eq(collection)
      end

      context "and the collection belongs to another object" do
        let(:collection) { create(:attachment_collection, collection_for: other, slug: "testing") }
        let(:other) { create(:result) }

        it "does not update the attachment" do
          expect { response }.to raise_error(StandardError)
        end
      end

      context "and the ID is not set" do
        let(:query) do
          %(
            {
              updateAttachment(
                id: "#{attachment.id}",
                attributes: {
                  title: #{convert_value(title)},
                  file: { blobId: #{blob.id} },
                  collection: { id: null }
                }
              ) { id }
            }
          )
        end

        it "does not create the attachment" do
          expect { response }.to raise_error(StandardError)
        end
      end
    end

    context "when collection is provided using slug" do
      let(:query) do
        %(
          {
            updateAttachment(
              id: "#{attachment.id}",
              attributes: {
                title: #{convert_value(title)},
                file: { blobId: #{blob.id} },
                collection: { slug: "#{collection.slug}" }
              }
            ) { id }
          }
        )
      end

      let!(:collection) { create(:attachment_collection, collection_for: model, slug: "testing") }

      it "sets the collection" do
        response
        attachment.reload
        expect(attachment.attachment_collection).to eq(collection)
      end

      context "and the slug is not found" do
        let(:query) do
          %(
            {
              updateAttachment(
                id: "#{attachment.id}",
                attributes: {
                  title: #{convert_value(title)},
                  file: { blobId: #{blob.id} },
                  collection: { slug: "foobar" }
                }
              ) { id }
            }
          )
        end

        it "does not update the attachment" do
          expect { response }.to raise_error(StandardError)
        end
      end

      context "and the collection belongs to another object" do
        let!(:collection) { create(:attachment_collection, collection_for: other, slug: "testing") }
        let(:other) { create(:result) }

        it "does not update the attachment" do
          expect { response }.to raise_error(StandardError)
        end
      end

      context "and the slug is empty" do
        let(:query) do
          %(
            {
              updateAttachment(
                id: "#{attachment.id}",
                attributes: {
                  title: #{convert_value(title)},
                  file: { blobId: #{blob.id} },
                  collection: { slug: "" }
                }
              ) { id }
            }
          )
        end

        it "does not update the attachment" do
          expect { response }.to raise_error(StandardError)
        end
      end

      context "and the slug is not set" do
        let(:query) do
          %(
            {
              updateAttachment(
                id: "#{attachment.id}",
                attributes: {
                  title: #{convert_value(title)},
                  file: { blobId: #{blob.id} },
                  collection: { slug: null }
                }
              ) { id }
            }
          )
        end

        it "does not update the attachment" do
          expect { response }.to raise_error(StandardError)
        end
      end
    end
  end

  describe "deleteAttachment" do
    let!(:attachment) { create(:attachment, attached_to: model) }
    let(:query) { %({ deleteAttachment(id: "#{attachment.id}") { id } }) }

    it_behaves_like "when the user does not have permissions"

    it "deletes the existing attachment" do
      expect { response }.to change(Decidim::Attachment, :count).by(-1)
    end

    it "creates an action log record" do
      expect { response }.to change(Decidim::ActionLog, :count).by(1)
    end
  end
end
