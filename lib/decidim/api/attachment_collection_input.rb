# frozen_string_literal: true

module Decidim
  module Apifiles
    class AttachmentCollectionInput < GraphQL::Schema::InputObject
      graphql_name "AttachmentCollectionInput"
      description "A type used for mapping attachments to collections"

      argument :id, GraphQL::Types::ID, "Maps the collection using its ID", required: false
      argument :slug, GraphQL::Types::String, "Maps the collection using its slug", required: false

      def prepare
        id = arguments[:id]
        slug = arguments[:slug]

        raise GraphQL::ExecutionError, "Either id or slug needs to be provided." if id.blank? && slug.blank?
        raise GraphQL::ExecutionError, "Only one of id or slug can be provided at a time." if id.present? && slug.present?
        raise GraphQL::ExecutionError, "The slug cannot be empty." if !slug.nil? && slug.empty?

        super
      end

      def id_value
        return arguments[:id].to_i if arguments[:id].present?

        raise GraphQL::ExecutionError, "The slug cannot be empty." if arguments[:slug].blank?
        raise GraphQL::ExecutionError, "Outside of object context." if context[:current_object].blank?

        parent = context[:current_object].object
        raise GraphQL::ExecutionError, "Outside of record context." unless parent

        collection = parent.attachment_collections.find_by(slug: arguments[:slug].strip)
        raise GraphQL::ExecutionError, "Slug not found within the record's collections." unless collection

        collection.id
      end
    end
  end
end
