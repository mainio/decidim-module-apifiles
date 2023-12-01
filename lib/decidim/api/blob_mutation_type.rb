# frozen_string_literal: true

module Decidim
  module Apifiles
    class BlobMutationType < Decidim::Api::Types::BaseObject
      graphql_name "BlobMutation"
      description "A blob which includes its available mutations"

      def self.authorized?(object, context)
        super && context[:current_user]&.admin?
      end

      field :id, GraphQL::Types::ID, "The Blob's unique ID", null: false

      field :delete, Decidim::Apifiles::BlobType, null: false do
        description "Deletes a given blob object and the associated file."
      end

      def delete
        object.destroy!
        object
      end
    end
  end
end
