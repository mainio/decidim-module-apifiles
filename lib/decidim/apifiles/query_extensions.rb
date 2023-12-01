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
          argument :id, GraphQL::Types::ID, description: "The ID of the blob", required: true
        end
      end

      def blob(id:)
        ActiveStorage::Blob.find_by(id: id)
      end
    end
  end
end
