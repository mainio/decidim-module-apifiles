# frozen_string_literal: true

module Decidim
  module Apifiles
    module AttachmentCollectionFormExtensions
      extend ActiveSupport::Concern

      included do
        # Remove the validators from the `:description` field as we want to make
        # it optional.
        _validators.reject! { |key, _| key == :description }
        _validate_callbacks.each do |callback|
          callback.raw_filter.attributes.delete(:description)
        end

        attribute :slug, String
      end
    end
  end
end
