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
            # Ensure that key can be set to nil
            key: form.key.presence
          )
        end
      end
    end
  end
end
