module Marvel
  class Api
    include ::HTTParty
    base_uri 'gateway.marvel.com'

    def initialize(public_key:, private_key:)
      @public_key  = public_key
      @private_key = private_key
    end

    def characters(params={})
      params.merge! auth_params
      options = { query: params }
      self.class.get('/v1/public/characters', options)
    end

  private
    attr_reader :public_key, :private_key

    def auth_params
      ts = Time.now.to_i
      hash = Digest::MD5.hexdigest("#{ts}#{private_key}#{public_key}")
      {
        ts: ts,
        apikey: public_key,
        hash: hash
      }
    end
  end
end
