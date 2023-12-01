# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/apifiles/version"

Gem::Specification.new do |s|
  s.version = Decidim::Apifiles.version
  s.authors = ["Antti Hukkanen"]
  s.email = ["antti.hukkanen@mainiotech.fi"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim-module-apifiles"
  s.required_ruby_version = ">= 3.0"
  s.metadata["rubygems_mfa_required"] = "true"

  s.name = "decidim-apifiles"
  s.summary = "A decidim API module for uploading files through the API"
  s.description = "Extra capabilities for the Decidim API to upload files."

  s.files = Dir["{app,config,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", Decidim::Apifiles.decidim_version
end
