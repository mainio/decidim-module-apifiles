# frozen_string_literal: true

module Decidim
  module Apifiles
    # This module's job is to extend the API with custom fields related to
    # decidim-apifiles.
    module QueryExtensions
      # Public: Extends a type with `decidim-apifiles`'s fields.
      #
      # type - A GraphQL::BaseType to extend.
      #
      # Returns nothing.
      def self.included(type)
        type.field :blob, BlobType, null: true, description: "Finds a blob" do
          argument :id, GraphQL::Types::ID, required: false, description: "The ID of the blob"
          argument :signed_id, GraphQL::Types::String, required: false, description: "The signed ID of the blob"
        end
      end

      # Retrieves a blob by ID or signed ID
      def blob(id: nil, signed_id: nil)
        if id
          ActiveStorage::Blob.find_by(id: id)
        elsif signed_id
          ActiveStorage::Blob.find_signed(signed_id)
        else
          raise GraphQL::ExecutionError, "Either 'id' or 'signedId' must be provided."
        end
      end
    end
  end
end
