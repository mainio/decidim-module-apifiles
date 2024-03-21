# frozen_string_literal: true

module Decidim
  module Apifiles
    autoload :AttachmentAttributes, "decidim/api/attachment_attributes"
    autoload :AttachmentCollectionType, "decidim/api/attachment_collection_type"
    autoload :AttachmentCollectionAttributes, "decidim/api/attachment_collection_attributes"
    autoload :AttachmentCollectionInput, "decidim/api/attachment_collection_input"
    autoload :BlobType, "decidim/api/blob_type"
    autoload :BlobMutationType, "decidim/api/blob_mutation_type"
    autoload :FileAttributes, "decidim/api/file_attributes"

    autoload :AttachableCollectionsInterface, "decidim/apifiles/api/interfaces/attachable_collections_interface"
    autoload :AttachableCollectionsMutationsInterface, "decidim/apifiles/api/interfaces/attachable_collections_mutations_interface"
    autoload :AttachableMutationsInterface, "decidim/apifiles/api/interfaces/attachable_mutations_interface"

    module Api
      autoload :AttachmentTypeExtensions, "decidim/apifiles/api/types/attachment_type_extensions"
    end
  end
end
