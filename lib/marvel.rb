require 'marvel/version'
require 'marvel/exceptions'
require 'httparty'
require 'marvel/api'

module Marvel
  class << self
    def set_config(config)
      @config = config
      @api = nil
    end

    def total_characters
      response = with_handling do
        api.characters({limit: 1})
      end
      response['data']['total']
    end

    def sample_character_thumbnail
      response = with_handling do
        api.characters({limit: 1, offset: 1000})
      end
      character = response['data']['results'].last
      [character['thumbnail']['path'], character['thumbnail']['extension']].join('.')
    end

    def characters_in_comics(comic_ids: [])
      return nil if comic_ids.empty?

      response = with_handling do
        api.characters({comics: comic_ids.join(',')})
      end
      response['data']['results'].map { |character|
        character['name']
      }
    end

  private

    attr_reader :config

    def api
      verify_configuration
      @api ||= Marvel::Api.new(
        public_key: config[:public_key],
        private_key: config[:private_key]
      )
    end

    def verify_configuration
      if config.nil?
        raise Marvel::NotConfigured, 'Not configured. Please use #set_config with a hash containing :public_key and :private_key.'
      end

      if !config.has_key?(:public_key) || config[:public_key].empty?
        raise Marvel::NotConfigured, 'No Marvel API public key has been set in the configuration, or is empty.'
      end

      if !config.has_key?(:private_key) || config[:private_key].empty?
        raise Marvel::NotConfigured, 'No Marvel API private key has been set in the configuration, or is empty.'
      end
    end

    def with_handling
      response = yield
      if response.code != 200
        raise Marvel::ApiError, "Unexpected API response. code=#{response.code} reason=#{response['message']}"
      end
      response
    end
  end
end
