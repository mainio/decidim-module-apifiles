# frozen_string_literal: true

require "spec_helper"

describe "API file upload", type: :request do
  let!(:organization) { create(:organization) }
  let!(:user) { create(:user, :confirmed, :admin, organization: organization) }

  let(:file) { Decidim::Dev.asset("city.jpeg") }
  let(:uploaded_file) { Rack::Test::UploadedFile.new(file, "image/jpeg") }

  context "when authenticated" do
    context "and the user is a regular user" do
      let!(:user) { create(:user, :confirmed, organization: organization) }

      it "does not allow uploading a file" do
        expect do
          upload_file(authenticate)
          expect(response.code).to eq("403")
        end.not_to change(ActiveStorage::Blob, :count)
      end
    end

    context "and the user is an admin" do
      it "allows uploading files" do
        expect do
          upload_file(authenticate)
          expect(response.code).to eq("200")
        end.to change(ActiveStorage::Blob, :count).by(1)

        response_json = JSON.parse(response.body)
        expect(response_json["contentType"]).to eq("image/jpeg")
        expect(response_json["filename"]).to eq("city.jpeg")
        expect(response_json["byteSize"]).to eq(File.size(file))

        blob = ActiveStorage::Blob.order(:id).last
        expect(response_json["id"]).to eq(blob.id)
        expect(response_json["checksum"]).to eq(blob.checksum)
        expect(response_json["signedId"]).to eq(blob.signed_id)
      end
    end

    def authenticate
      post(
        "/api/sign_in",
        params: { user: { email: user.email, password: "decidim123456789" } },
        headers: { "HOST" => organization.host }
      )
      expect(response.code).to eq("200")
      response.headers["Authorization"]
    end
  end

  context "when unauthenticated" do
    it "does not allow uploading a file" do
      expect do
        upload_file("Bearer abcdef123456789")
        expect(response.code).to eq("401")
      end.not_to change(ActiveStorage::Blob, :count)
    end
  end

  def upload_file(authorization)
    post(
      "/api/blobs",
      params: { file: uploaded_file },
      headers: { "HOST" => organization.host, "Authorization" => authorization }
    )
  end
end
