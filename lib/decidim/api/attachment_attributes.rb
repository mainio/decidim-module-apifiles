# frozen_string_literal: true

module Decidim
  module Apifiles
    # The attachment attributes for managing an attachment.
    class AttachmentAttributes < GraphQL::Schema::InputObject
      description "Attributes for attachments"

      argument :collection, Decidim::Apifiles::AttachmentCollectionInput, "The input argument for attachment collection.", required: false
      argument :weight, GraphQL::Types::Int, description: "The attachment weight, i.e. its position, lowest first", required: false, default_value: 0
      argument :title, GraphQL::Types::JSON, description: "The attachment title localized hash, e.g. {\"en\": \"English title\"}", required: true
      argument :description, GraphQL::Types::JSON, description: "The attachment description localized hash (plain text), e.g. {\"en\": \"English description\"}", required: false
      argument :file, Decidim::Apifiles::FileAttributes, "The file for the attachment", required: true
    end
  end
end
