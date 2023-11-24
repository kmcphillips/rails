# frozen_string_literal: true

module Rails
  class Application
    class CredentialsConfig # :nodoc:
      def initialize(application)
        @application = application
        @content_path = nil
        @content_path_default = true
        @key_path = nil
        @key_path_default = true
      end

      def content_path
        @content_path ||= build_content_path
      end

      def content_path_default?
        @content_path_default
      end

      def content_path=(path)
        @content_path_default = false
        @content_path = path
      end

      def key_path=(path)
        @key_path_default = false
        @key_path = path
      end

      def key_path
        @key_path ||= build_key_path
      end

      def key_path_default?
        @key_path_default
      end

      private
        def build_content_path
          path = @application.root.join("config/credentials/#{Rails.env}.yml.enc")
          path = @application.root.join("config/credentials.yml.enc") if !path.exist?
          path
        end

        def build_key_path
          path = @application.root.join("config/credentials/#{Rails.env}.key")
          path = @application.root.join("config/master.key") if !path.exist?
          path
        end
    end
  end
end
