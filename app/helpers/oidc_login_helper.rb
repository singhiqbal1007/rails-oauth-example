# frozen_string_literal: true

module OidcLoginHelper
  class GoogleOidc
    CONFIG_ENDPOINT = '.well-known/openid-configuration'
    CONFIG_ISSUER = 'https://accounts.google.com'

    class << self
      def client(root_url)
        @client ||= new_client(root_url)
      end

      def request_for_token(client)
        retry_count = 3
        begin
          token = client.access_token!
        rescue StandardError
          retry_count -= 1
          return nil if retry_count.negative?

          retry
        end
        token
      end

      private

      def new_client(root_url)
        config = new_config('google')
        OpenIDConnect::Client.new(
          identifier: ENV['GOOGLE_CLIENT_ID'],
          secret: ENV['GOOGLE_CLIENT_SECRET'],
          redirect_uri: "#{url_chomp(root_url)}/oauth_callback",
          host: config.issuer,
          authorization_endpoint: config.authorization_endpoint,
          token_endpoint: config.token_endpoint
        )
      end

      def new_config(name)
        # get client configs from database
        config = OidcConfigs.find_by(name: name)

        if config.nil?
          config = OidcConfigs.create(name: name, issuer: CONFIG_ISSUER)
        end

        if config.authorization_endpoint.nil? || config.updated_at < 1.day.ago
          # if database configs are older than 1 day then get it from google endpoint
          uri = URI.parse("#{config.issuer}/#{CONFIG_ENDPOINT}")
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          response = http.get(uri.request_uri)
          hash = JSON.parse response.body
          config.authorization_endpoint = hash['authorization_endpoint']
          config.token_endpoint = hash['token_endpoint']
          config.save!
        end
        config
      end

      def url_chomp(url)
        uri = URI.parse(url.to_s)
        uri.path.squeeze!('/')
        uri.path.chomp!('/')
        uri.to_s
      end
    end
  end
end
