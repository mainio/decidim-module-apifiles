# frozen_string_literal: true

module Decidim
  module Apifiles
    # This controller provides the file upload capabilities for the API. The
    # file blobs can be uploaded through the `/api/blobs` endpoint and managed
    # (e.g. destroyed) through the normal GraphQL API.
    #
    # The upload can be done in chunks improving the file upload performance
    # and the response for a successful upload contains the blob ID that can be
    # attached to any record where blobs can be attached to. The purpose of this
    # endpoint is to provide a stable (i.e. unchanging) and performant API for
    # uploading the files as that would be difficult to do through the normal
    # GraphQL API (e.g. by base64 encoding the whole file which may cause issues
    # when the file sizes become larger).
    class BlobsController < Api::ApplicationController
      register_permissions(
        ::Decidim::Apifiles::BlobsController,
        ::Decidim::Apifiles::Permissions,
        ::Decidim::Permissions
      )

      def create
        enforce_permission_to :create, :blob

        return render json: { error: :file_not_provided }, status: :unprocessable_entity unless file_uploaded?
        return render json: { error: :unallowed_file_extension }, status: :unprocessable_entity unless extension_allowlist.any? { |ext| ext == uploaded_file_extension }
        return render json: { error: :unallowed_content_type }, status: :unprocessable_entity unless content_type_allowlist.any? { |type| type.match?(uploaded_file.content_type) }

        blob = ActiveStorage::Blob.create_and_upload!(
          io: uploaded_file,
          filename: uploaded_file.original_filename,
          content_type: uploaded_file.content_type
        )

        render json: blob.as_json(methods: :signed_id)
      end

      private

      def uploaded_file
        @uploaded_file ||= params.require(:file)
      end

      def uploaded_file_extension
        @uploaded_file_extension ||= File.extname(uploaded_file.original_filename).strip.downcase[1..-1]
      end

      def file_uploaded?
        return true if defined?(Rack::Test::UploadedFile) && uploaded_file.is_a?(Rack::Test::UploadedFile)

        uploaded_file.is_a?(ActionDispatch::Http::UploadedFile)
      end

      def extension_allowlist
        Decidim.organization_settings(current_organization).upload_allowed_file_extensions_admin
      end

      def content_type_allowlist
        Decidim.organization_settings(current_organization).upload_allowed_content_types_admin
      end

      # Handles the unauthorized (not signed in) and forbidden (not an admin)
      # cases for the file upload endpoint.
      def user_has_no_permission
        if current_user
          render body: nil, status: :forbidden
        else
          render body: nil, status: :unauthorized
        end
      end

      def permission_class_chain
        ::Decidim.permissions_registry.chain_for(::Decidim::Apifiles::BlobsController)
      end

      def permission_scope
        :admin
      end
    end
  end
end
