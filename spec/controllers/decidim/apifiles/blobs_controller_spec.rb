# frozen_string_literal: true

require "spec_helper"

describe Decidim::Apifiles::BlobsController, type: :controller do
  routes { Decidim::Apifiles::Engine.routes }

  let(:organization) { create(:organization) }
  let(:file) do
    Rack::Test::UploadedFile.new(
      Decidim::Dev.test_file("city.jpeg", "image/jpeg"),
      "image/jpeg"
    )
  end
  let(:params) { { file: file } }

  before do
    request.env["decidim.current_organization"] = organization
  end

  context "when the user is not authenticated" do
    before do
      post :create, params: params
    end

    it "responds with HTTP code 401" do
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context "when the user is authenticated" do
    before do
      sign_in current_user

      post :create, params: params
    end

    context "and the user is a regular user" do
      let(:current_user) { create(:user, :confirmed, organization: organization) }

      it "responds with HTTP code 403" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "and the user is an admin" do
      let(:current_user) { create(:user, :confirmed, :admin, organization: organization) }

      it "allows uploading a file" do
        expect(response).to have_http_status(:ok)
      end

      context "with invalid params" do
        let(:params) { { file: "foobar" } }

        it "responds with HTTP code 422" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)).to eq({ "error" => "file_not_provided" })
        end
      end

      context "with unallowed file extension" do
        let(:file) do
          Rack::Test::UploadedFile.new(
            Decidim::Dev.test_file("assemblies.json", "application/json"),
            "application/json"
          )
        end

        it "does not allow uploading a file" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)).to eq({ "error" => "unallowed_file_extension" })
        end
      end

      context "with unallowed content type" do
        let(:file) do
          Rack::Test::UploadedFile.new(
            Decidim::Dev.test_file("city.jpeg", "image/jpeg"),
            "application/zip"
          )
        end

        it "does not allow uploading a file" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)).to eq({ "error" => "unallowed_content_type" })
        end
      end

      context "with file name in Windows-1252 encoding" do
        let(:file) do
          Decidim::Dev.test_file("Exampledocument.pdf", "application/pdf").tap do |f|
            # In case we stored a file with such name in the "fixtures" folder,
            # this would not work because `rack-test` fails to generate the
            # `Rack::Test::UploadedFile` due to the weird name. We need to force
            # the name on the instance in order to replicate the bug with
            # storing file names with this encoding. There is no other way to
            # change the "original_filename" of the instance.
            f.instance_variable_set(:@original_filename, "êxämplö®'.pdf".encode("WINDOWS-1252"))
          end
        end

        it "allows uploading a file" do
          expect(response).to have_http_status(:ok)
        end
      end
    end
  end
end
