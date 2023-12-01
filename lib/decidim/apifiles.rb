# frozen_string_literal: true

require "decidim/apifiles/api"
require "decidim/apifiles/engine"

module Decidim
  # This namespace holds the logic of the `Apifiles` module.
  module Apifiles
    autoload :QueryExtensions, "decidim/apifiles/query_extensions"
    autoload :MutationExtensions, "decidim/apifiles/mutation_extensions"
  end
end
