# frozen_string_literal: true

module Decidim
  module Apifiles
    module AttachmentCollectionExtensions
      extend ActiveSupport::Concern

      included do
        validates :key, uniqueness: { scope: :collection_for }, if: -> { key.present? }
      end
    end
  end
end
