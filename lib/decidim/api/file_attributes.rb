# frozen_string_literal: true

module Decidim
  module Apifiles
    # The file attributes can be used outside of this module for the GraphQL
    # mutations that need to work with attaching or detaching files to different
    # objects.
    class FileAttributes < GraphQL::Schema::InputObject
      description "Attributes for attaching files to objects"

      argument :blob_id, GraphQL::Types::Int, description: "The file blob ID to attach to the object", required: false
      argument :remove, GraphQL::Types::Boolean, description: "Defines if the file should be removed from the object (also removes the blob)", required: false

      def blob
        return unless blob_id

        ActiveStorage::Blob.find_by(id: blob_id)
      end
    end
  end
end
