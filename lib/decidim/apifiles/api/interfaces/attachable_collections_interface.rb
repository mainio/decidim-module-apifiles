# frozen_string_literal: true

module Decidim
  module Apifiles
    # This interface represents an attachable object with collections, i.e.
    # an object that can hold attachment collections.
    module AttachableCollectionsInterface
      include Decidim::Api::Types::BaseInterface
      description "An interface that can be used in objects with attachment collections"

      field :attachment_collections, [Decidim::Apifiles::AttachmentCollectionType, { null: true }], description: "This object's attachment collections", null: false
    end
  end
end
