require 'borderlands/authinfo'
require 'akamai/edgegrid'
require 'net/http'
require 'uri'

module Borderlands
  class Client
    def initialize(config)
      raise 'config must be an AuthInfo object' unless config.is_a? AuthInfo
      @baseuri = URI('https://' + config.host)
      @http = Akamai::Edgegrid::HTTP.new(
          address=baseuri.host,
          port=baseuri.port
      )
      @http.setup_edgegrid(
        :access_token  => config.access_token,
        :client_token  => config.client_token,
        :client_secret => config.client_secret,
        :max_body      => config.max_body,
      )
    end
    def get(req, query={})
      resp = nil
      uri = URI.join(
        baseuri,
        req,
        '?' + query.keys.map { |k| [ k, '=', query[k] ].join }.join('&')
      )
      resp = @http.request(Net::HTTP::Get.new uri.to_s)
      resp.body
    end

    def get_json_body(req, query={})
      body = get(req,query)
      begin
        json = JSON.parse(body)
      rescue Exception => e
        raise "unparseable JSON body in API response: #{e.message}"
      end
      json
    end
    attr_reader :baseuri
  end
end
