# frozen_string_literal: true

module Decidim
  module Apifiles
    class AttachmentCollectionType < Decidim::Api::Types::BaseObject
      description "An attachment collection"

      field :attachments, [Decidim::Core::AttachmentType, { null: true }], "The collection's attachments", null: false
      field :description, Decidim::Core::TranslatedFieldType, "The description of this attachment collection", null: true
      field :id, GraphQL::Types::ID, "The id of this attachment collection", null: false
      field :key, GraphQL::Types::String, "A technical key for the attachment collection to identify a specific correct collection", null: true
      field :name, Decidim::Core::TranslatedFieldType, "The name of this attachment collection", null: false
      field :slug, GraphQL::Types::String, "DEPRECATED: Use 'key' instead", null: true, method: :key
      field :weight, GraphQL::Types::Int, "The weight of this attachment collection", null: false

      # @deprecated Use `#key` instead.
    end
  end
end
