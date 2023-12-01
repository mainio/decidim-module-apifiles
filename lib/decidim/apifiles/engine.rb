# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module Apifiles
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Apifiles

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :blobs, only: [:create, :destroy]
      end

      initializer "decidim_apifiles.middleware", after: "decidim-api.middleware" do |app|
        # Allow the /api/blobs route from any origin because it is an API
        # endpoint.
        app.config.middleware.insert_before 0, Rack::Cors do
          allow do
            origins "*"
            resource "/api/blobs", headers: :any, methods: [:post]
          end
        end
      end

      initializer "decidim_apifiles.mount_routes", before: :add_routing_paths do
        # Mount the engine routes to Decidim::Core::Engine because otherwise
        # they would not get mounted properly.
        Decidim::Core::Engine.routes.prepend do
          mount Decidim::Apifiles::Engine => "/api"
        end
      end

      initializer "decidim_apifiles.query_extensions" do
        Decidim::Api::QueryType.include Decidim::Apifiles::QueryExtensions
      end

      initializer "decidim_apifiles.mutation_extensions", after: "decidim-api.graphiql" do
        Decidim::Api::MutationType.include Decidim::Apifiles::MutationExtensions
      end
    end
  end
end
