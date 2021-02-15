require "skylight/formatters/http"

module Skylight
  module Normalizers
    module Faraday
      class Request < Normalizer
        register "request.faraday"

        DISABLED_KEY = :__skylight_faraday_disabled

        def self.disable
          old_value = Thread.current.thread_variable_get(DISABLED_KEY)
          Thread.current.thread_variable_set(DISABLED_KEY, true)
          yield
        ensure
          Thread.current.thread_variable_set(DISABLED_KEY, old_value)
        end

        def disabled?
          !!Thread.current.thread_variable_get(DISABLED_KEY)
        end

        def normalize(_trace, _name, payload)
          uri = payload[:url]

          if disabled?
            return :skip
          end

          opts = Formatters::HTTP.build_opts(payload[:method], uri.scheme, uri.host, uri.port, uri.path, uri.query)
          description = opts[:title]

          # We use "Faraday" as the title to differentiate it in the UI in
          # case it's wrapping or is wrapped by another HTTP backend
          [opts[:category], "Faraday", description, opts[:meta]]
        end
      end
    end
  end
end
