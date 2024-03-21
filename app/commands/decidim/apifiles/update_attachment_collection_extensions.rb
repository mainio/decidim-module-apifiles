# frozen_string_literal: true

module Decidim
  module Apifiles
    module UpdateAttachmentCollectionExtensions
      extend ActiveSupport::Concern

      included do
        private

        def attributes
          {
            name: form.name,
            weight: form.weight,
            description: form.description.presence
          }.compact.merge(
            # Ensure that slug can be set to nil
            slug: form.slug.presence
          )
        end
      end
    end
  end
end
