# frozen_string_literal: true

module Decidim
  module Apifiles
    module AttachmentFormExtensions
      extend ActiveSupport::Concern

      included do
        # Remove the validators from the `:description` field as we want to make
        # it optional.
        _validators.reject! { |key, _| key == :description }
        _validate_callbacks.each do |callback|
          callback.filter.attributes.delete(:description)
        end
      end
    end
  end
end
