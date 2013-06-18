  require 'vcr'

  VCR.configure do |c|
    c.cassette_library_dir = 'spec/cassettes'
    c.hook_into :faraday
    c.configure_rspec_metadata!
    c.ignore_localhost = true
    c.allow_http_connections_when_no_cassette = true
  end

