$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'marvel'
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = 'fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.default_cassette_options = {
    :match_requests_on => [:method,
                           VCR.request_matchers.uri_without_params(:ts, :hash)],
  }
  config.before_record do |i|
    i.response.body.scrub
  end
end
