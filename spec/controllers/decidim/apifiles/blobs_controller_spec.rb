# frozen_string_literal: true

require "spec_helper"

describe Decidim::Apifiles::BlobsController do
  routes { Decidim::Apifiles::Engine.routes }

  let(:organization) { create(:organization) }
  let(:file) do
    Rack::Test::UploadedFile.new(
      Decidim::Dev.test_file("city.jpeg", "image/jpeg"),
      "image/jpeg"
    )
  end
  let(:params) { { file: } }

  before do
    request.env["decidim.current_organization"] = organization
  end

  context "when the user is not authenticated" do
    before do
      post :create, params:
    end

    it "responds with HTTP code 401" do
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context "when the user is authenticated" do
    before do
      sign_in current_user

      post :create, params:
    end

    context "and the user is a regular user" do
      let(:current_user) { create(:user, :confirmed, organization:) }

      it "responds with HTTP code 403" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "and the user is an admin" do
      let(:current_user) { create(:user, :confirmed, :admin, organization:) }

      it "allows uploading a file" do
        expect(response).to have_http_status(:ok)
      end

      context "with invalid params" do
        let(:params) { { file: "foobar" } }

        it "responds with HTTP code 422" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body).to eq({ "error" => "file_not_provided" })
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
          expect(response.parsed_body).to eq({ "error" => "unallowed_file_extension" })
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
          expect(response.parsed_body).to eq({ "error" => "unallowed_content_type" })
        end
      end
    end
  end
end
