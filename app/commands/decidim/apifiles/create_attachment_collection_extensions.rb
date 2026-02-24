# frozen_string_literal: true

module Decidim
  module Apifiles
    module CreateAttachmentCollectionExtensions
      extend ActiveSupport::Concern

      included do
        private

        # Stores the collection so that we can return it through the API.
        def create_attachment_collection
          @attachment_collection = Decidim.traceability.create!(
            Decidim::AttachmentCollection,
            current_user,
            attributes
          )
        end

        def attributes
          {
            name: form.name,
            key: form.key.presence&.strip,
            weight: form.weight,
            description: form.description,
            collection_for: @collection_for
          }
        end
      end
    end
  end
end
