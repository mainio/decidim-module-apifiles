# frozen_string_literal: true

module Decidim
  module Apifiles
    module AttachmentCollectionTypeExtensions
      extend ActiveSupport::Concern

      included do
        field :id, GraphQL::Types::ID, "The id of this attachment collection", null: false
        field :key, GraphQL::Types::String,
              "A technical key for the attachment collection to identify a specific correct collection", null: true
        field :weight, GraphQL::Types::Int, "The weight of this attachment collection", null: false
        field :slug, GraphQL::Types::String, "DEPRECATED: Use 'key' instead", null: true, method: :key
      end
    end
  end
end
