# frozen_string_literal: true

require 'rails/generators/active_record'

module Comfy
  module Generators
    class CmsGenerator < Rails::Generators::Base
      include Rails::Generators::Migration
      include Thor::Actions

      source_root File.expand_path('../../../..', __dir__)

      def generate_migration
        %w[01_create_cms 02_add_markdown_to_snippets].each do |migration|
          destination   = File.expand_path("db/migrate/#{migration}.rb", destination_root)
          migration_dir = File.dirname(destination)
          destination   = self.class.migration_exists?(migration_dir, migration)

          if destination
            puts "\e[0m\e[31mFound existing #{migration}.rb migration. Remove it if you want to regenerate.\e[0m"
          else
            migration_template "db/migrate/#{migration}.rb", "db/migrate/#{migration[3..]}.rb"
          end
        end
      end

      def generate_initializer
        copy_file 'config/initializers/comfortable_media_surfer.rb',
                  'config/initializers/comfortable_media_surfer.rb'
      end

      def generate_railties_order
        application <<~RUBY
          # Ensuring that ActiveStorage routes are loaded before Comfy's globbing
          # route. Without this file serving routes are inaccessible.
          config.railties_order = [ActiveStorage::Engine, :main_app, :all]
        RUBY
      end

      def generate_routing
        route_string = <<~RUBY
          comfy_route :cms_admin, path: "/admin"
          # Ensure that this route is defined last
          comfy_route :cms, path: "/"
        RUBY
        route route_string
      end

      def generate_cms_seeds
        directory 'db/cms_seeds', 'db/cms_seeds'
      end

      def generate_assets
        copy_file 'app/assets/javascripts/comfy/admin/cms/custom.js',
                  'app/assets/javascripts/comfy/admin/cms/custom.js'
        copy_file 'app/assets/stylesheets/comfy/admin/cms/custom.sass',
                  'app/assets/stylesheets/comfy/admin/cms/custom.sass'
      end

      def show_readme
        readme 'lib/generators/comfy/cms/README'
      end

      def self.next_migration_number(dirname)
        ActiveRecord::Generators::Base.next_migration_number(dirname)
      end
    end
  end
end
