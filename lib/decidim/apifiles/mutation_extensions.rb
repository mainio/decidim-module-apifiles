# frozen_string_literal: true

module Decidim
  module Apifiles
    # This module's job is to extend the API with custom fields related to
    # decidim-budgeting_pipeline.
    module MutationExtensions
      # Public: Extends a type with `decidim-budgeting_pipeline`'s fields.
      #
      # type - A GraphQL::BaseType to extend.
      #
      # Returns nothing.
      def self.included(type)
        type.field :blob, Decidim::Apifiles::BlobMutationType, "A blob", null: false do
          argument :id, GraphQL::Types::ID, "The blob's id", required: true
        end
      end

      def blob(id:)
        ActiveStorage::Blob.find(id)
      end
    end
  end
end
