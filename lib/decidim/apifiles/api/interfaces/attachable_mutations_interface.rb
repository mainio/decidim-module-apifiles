# frozen_string_literal: true

module Decidim
  module Apifiles
    # This interface represents an attachable object mutation, i.e. an object
    # that can receive updates to its attachments.
    module AttachableMutationsInterface
      include Decidim::Api::Types::BaseInterface
      description "An interface that can be used in objects with attachment mutations"

      field :create_attachment, Decidim::Core::AttachmentType, null: false do
        description "Creates an attachment."

        argument :attributes, Decidim::Apifiles::AttachmentAttributes, description: "Input attributes to create an attachment", required: true
      end

      field :update_attachment, Decidim::Core::AttachmentType, null: false do
        description "Updates an attachment."

        argument :id, GraphQL::Types::ID, required: true
        argument :attributes, Decidim::Apifiles::AttachmentAttributes, description: "Input attributes to update an attachment", required: true
      end

      field :delete_attachment, Decidim::Core::AttachmentType, null: false do
        description "Deletes an attachment."

        argument :id, GraphQL::Types::ID, required: true
      end

      def create_attachment(attributes:)
        raise ::Decidim::ActionForbidden unless current_user&.admin?

        form = Decidim::Admin::AttachmentForm.from_params(
          "attachment" => attachment_params(attributes)
        ).with_context(
          current_organization:,
          current_component: object.component,
          current_user:,
          attached_to: object
        )

        attachment = nil
        Decidim::Admin::CreateAttachment.call(form, object) do
          on(:ok) do
            attachment = @attachment
          end
        end
        return attachment if attachment.present?

        if form.errors.any?
          return GraphQL::ExecutionError.new(
            form.errors.full_messages.join(", ")
          )
        end

        GraphQL::ExecutionError.new(
          I18n.t("decidim.admin.attachments.create.error")
        )
      end

      def update_attachment(id:, attributes:)
        raise ::Decidim::ActionForbidden unless current_user&.admin?

        attachment = object.attachments.find_by(id:)
        raise GraphQL::ExecutionError, "Invalid attachment ID provided: #{id}" unless attachment

        form = Decidim::Admin::AttachmentForm.from_params(
          "attachment" => attachment_params(attributes)
        ).with_context(
          current_organization:,
          current_component: object.component,
          current_user:,
          attached_to: object
        )

        status = nil
        Decidim::Admin::UpdateAttachment.call(attachment, form) do
          on(:ok) do
            status = :ok
          end
        end
        return attachment if status == :ok

        if form.errors.any?
          return GraphQL::ExecutionError.new(
            form.errors.full_messages.join(", ")
          )
        end

        GraphQL::ExecutionError.new(
          I18n.t("decidim.admin.attachments.update.error")
        )
      end

      def delete_attachment(id:)
        raise ::Decidim::ActionForbidden unless current_user&.admin?

        attachment = object.attachments.find_by(id:)
        raise GraphQL::ExecutionError, "Invalid attachment ID provided: #{id}" unless attachment

        Decidim.traceability.perform_action!("delete", attachment, current_user) do
          attachment.destroy!
        end

        attachment
      end

      private

      def current_organization
        context[:current_organization]
      end

      def current_user
        context[:current_user]
      end

      def attachment_params(attributes)
        {
          title: attributes.title,
          description: attributes.description,
          weight: attributes.weight,
          attachment_collection_id: attributes.collection&.id_value,
          file: attributes.file&.blob&.signed_id
        }
      end
    end
  end
end
