# frozen_string_literal: true

module Decidim
  module Apifiles
    # This interface represents an attachable collection object mutation, i.e.
    # an object that can receive updates to its attachment collections.
    module AttachableCollectionsMutationsInterface
      include Decidim::Api::Types::BaseInterface
      description "An interface that can be used in objects with attachment collection mutations"

      field :create_attachment_collection, Decidim::Apifiles::AttachmentCollectionType, null: false do
        description "Creates an attachment collection."

        argument :attributes, Decidim::Apifiles::AttachmentCollectionAttributes, description: "Input attributes to create an attachment collection", required: true
      end

      field :update_attachment_collection, Decidim::Apifiles::AttachmentCollectionType, null: false do
        description "Updates an attachment collection."

        argument :id, GraphQL::Types::ID, required: true
        argument :attributes, Decidim::Apifiles::AttachmentCollectionAttributes, description: "Input attributes to update an attachment collection", required: true
      end

      field :delete_attachment_collection, Decidim::Apifiles::AttachmentCollectionType, null: false do
        argument :id, GraphQL::Types::ID, required: true
      end

      def create_attachment_collection(attributes:)
        raise ::Decidim::ActionForbidden unless current_user&.admin?

        form = Decidim::Admin::AttachmentCollectionForm.from_params(attachment_collection_params(attributes)).with_context(
          current_organization:,
          current_component: object.component,
          current_user:,
          collection_for: object
        )

        attachment_collection = nil
        Decidim::Admin::CreateAttachmentCollection.call(form, object, current_user) do
          on(:ok) do
            attachment_collection = @attachment_collection
          end
        end
        return attachment_collection if attachment_collection.present?

        if form.errors.any?
          return GraphQL::ExecutionError.new(
            form.errors.full_messages.join(", ")
          )
        end

        GraphQL::ExecutionError.new(
          I18n.t("decidim.admin.attachment_collections.create.error")
        )
      end

      def update_attachment_collection(id:, attributes:)
        raise ::Decidim::ActionForbidden unless current_user&.admin?

        attachment_collection = object.attachment_collections.find_by(id:)
        raise GraphQL::ExecutionError, "Invalid attachment collection ID provided: #{id}" unless attachment_collection

        params = attachment_collection_params(attributes)

        # Keep the original key through the API if the key wasn't provided
        params[:key] = attachment_collection.key if attributes.key.blank? && attributes.slug.blank?

        form = Decidim::Admin::AttachmentCollectionForm.from_params(params).with_context(
          current_organization:,
          current_component: object.component,
          current_user:,
          collection_for: object
        )

        status = nil
        Decidim::Admin::UpdateAttachmentCollection.call(attachment_collection, form, current_user) do
          on(:ok) do
            status = :ok
          end
        end
        return attachment_collection if status == :ok

        if form.errors.any?
          return GraphQL::ExecutionError.new(
            form.errors.full_messages.join(", ")
          )
        end

        GraphQL::ExecutionError.new(
          I18n.t("decidim.admin.attachment_collections.update.error")
        )
      end

      def delete_attachment_collection(id:)
        raise ::Decidim::ActionForbidden unless current_user&.admin?

        attachment_collection = object.attachment_collections.find_by(id:)
        raise GraphQL::ExecutionError, "Invalid attachment collection ID provided: #{id}" unless attachment_collection

        Decidim.traceability.perform_action!("delete", attachment_collection, current_user) do
          attachment_collection.destroy!
        end

        attachment_collection
      end

      private

      def current_organization
        context[:current_organization]
      end

      def current_user
        context[:current_user]
      end

      def attachment_collection_params(attributes)
        {
          key: attributes.key.presence || attributes.slug,
          weight: attributes.weight,
          name: attributes.name,
          description: attributes.description
        }
      end
    end
  end
end
