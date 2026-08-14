# frozen_string_literal: true

module Decidim
  module Apifiles
    module AttachmentCollectionTypeExtensions
      extend ActiveSupport::Concern

      included do
        field :key, GraphQL::Types::String,
              "A technical key for the attachment collection to identify a specific correct collection", null: true
        field :slug, GraphQL::Types::String, "DEPRECATED: Use 'key' instead", null: true, method: :key
      end
    end
  end
end
