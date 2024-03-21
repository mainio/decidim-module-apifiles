# frozen_string_literal: true

module Decidim
  module Apifiles
    module Api
      module AttachmentTypeExtensions
        def self.included(type)
          type.field :id, GraphQL::Types::ID, "The attachment ID", null: true
          type.field :title, Decidim::Core::TranslatedFieldType, "The title for this attachment", null: false
          type.field :description, Decidim::Core::TranslatedFieldType, "The description for this attachment", null: true
          type.field :collection, Decidim::Apifiles::AttachmentCollectionType, method: :attachment_collection, null: true
          type.field :file_blob, Decidim::Apifiles::BlobType, "The file blob for this attachment", null: true
        end

        def file_blob
          object.file.blob
        end
      end
    end
  end
end
