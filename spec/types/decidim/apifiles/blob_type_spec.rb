# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

describe Decidim::Apifiles::BlobType do
  include_context "with a graphql class type"

  let(:model) do
    ActiveStorage::Blob.create_and_upload!(
      io: File.open(Decidim::Dev.asset("city.jpeg")),
      filename: "city.jpeg",
      content_type: "image/jpeg"
    )
  end

  context "with a visitor" do
    let!(:current_user) { nil }
    let(:query) { "{ id }" }

    it "cannot access the blobs" do
      expect(response).to be_nil
    end
  end

  context "with a participant" do
    let(:query) { "{ id }" }

    it "cannot access the blobs" do
      expect(response).to be_nil
    end
  end

  context "with an admin user" do
    let!(:current_user) { create(:user, :confirmed, :admin, organization: current_organization) }

    describe "id" do
      let(:query) { "{ id }" }

      it "returns the id" do
        expect(response).to include("id" => model.id.to_s)
      end
    end

    describe "key" do
      let(:query) { "{ key }" }

      it "returns the key" do
        expect(response).to include("key" => model.key)
      end
    end

    describe "signedId" do
      let(:query) { "{ signedId }" }

      it "returns the signedId" do
        expect(response).to include("signedId" => model.signed_id)
      end
    end

    describe "filename" do
      let(:query) { "{ filename }" }

      it "returns the filename" do
        expect(response).to include("filename" => model.filename)
      end
    end

    describe "contentType" do
      let(:query) { "{ contentType }" }

      it "returns the contentType" do
        expect(response).to include("contentType" => model.content_type)
      end
    end

    describe "metadata" do
      let(:query) { "{ metadata }" }

      it "returns the metadata" do
        expect(response).to include("metadata" => model.metadata)
      end
    end

    describe "byteSize" do
      let(:query) { "{ byteSize }" }

      it "returns the byteSize" do
        expect(response).to include("byteSize" => model.byte_size)
      end
    end

    describe "checksum" do
      let(:query) { "{ checksum }" }

      it "returns the checksum" do
        expect(response).to include("checksum" => model.checksum)
      end
    end

    describe "createdAt" do
      let(:query) { "{ createdAt }" }

      it "returns the createdAt" do
        expect(response).to include("createdAt" => model.created_at.to_time.iso8601)
      end
    end

    describe "serviceName" do
      let(:query) { "{ serviceName }" }

      it "returns the serviceName" do
        expect(response).to include("serviceName" => model.service_name)
      end
    end

    describe "src" do
      let(:query) { "{ src }" }

      let(:host) { "http://#{current_organization.host}:#{Capybara.server_port}" }

      it "returns the src" do
        expect(response).to include("src" => "#{host}/rails/active_storage/blobs/redirect/#{model.signed_id}/#{model.filename}")
      end
    end
  end
end
