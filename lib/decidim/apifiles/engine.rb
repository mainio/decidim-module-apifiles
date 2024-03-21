# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module Apifiles
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Apifiles

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

      initializer "decidim_apifiles.api_extensions" do
        Decidim::Core::AttachmentType.include Decidim::Apifiles::Api::AttachmentTypeExtensions
      end

      initializer "decidim_apifiles.query_extensions" do
        Decidim::Api::QueryType.include Decidim::Apifiles::QueryExtensions
      end

      initializer "decidim_apifiles.mutation_extensions", after: "decidim-api.graphiql" do
        Decidim::Api::MutationType.include Decidim::Apifiles::MutationExtensions
      end

      initializer "decidim_apifiles.overrides", after: "decidim.action_controller" do |app|
        app.config.to_prepare do
          # Form extensions
          Decidim::Admin::AttachmentForm.include(Decidim::Apifiles::AttachmentFormExtensions)
          Decidim::Admin::AttachmentCollectionForm.include(Decidim::Apifiles::AttachmentCollectionFormExtensions)

          # Command extensions
          Decidim::Admin::CreateAttachmentCollection.include(Decidim::Apifiles::CreateAttachmentCollectionExtensions)
          Decidim::Admin::UpdateAttachmentCollection.include(Decidim::Apifiles::UpdateAttachmentCollectionExtensions)

          # Model extensions
          Decidim::AttachmentCollection.include(Decidim::Apifiles::AttachmentCollectionExtensions)
        end
      end
    end
  end
end
