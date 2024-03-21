# frozen_string_literal: true

module Decidim
  module Apifiles
    module AttachmentCollectionExtensions
      extend ActiveSupport::Concern

      included do
        validates :slug, uniqueness: { scope: :collection_for }, if: -> { slug.present? }
      end
    end
  end
end
