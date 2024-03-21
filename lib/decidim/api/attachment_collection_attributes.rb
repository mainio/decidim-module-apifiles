# frozen_string_literal: true

module Decidim
  module Apifiles
    # The attachment collection attributes for managing an attachment
    # collection.
    class AttachmentCollectionAttributes < GraphQL::Schema::InputObject
      description "Attributes for attachment collections"

      argument :weight, GraphQL::Types::Int, description: "The attachment collection weight, i.e. its position, lowest first", required: false, default_value: 0
      argument :slug, GraphQL::Types::String, description: "The attachment collection slug, i.e. its technical handle", required: false
      argument :name, GraphQL::Types::JSON, description: "The attachment collection name localized hash, e.g. {\"en\": \"English name\"}", required: true
      argument(
        :description,
        GraphQL::Types::JSON,
        description: "The attachment collection description localized hash (plain text), e.g. {\"en\": \"English description\"}",
        required: false
      )
    end
  end
end
