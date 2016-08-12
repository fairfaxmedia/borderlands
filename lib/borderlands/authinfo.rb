module Borderlands
  class AuthInfo
    def initialize(_client_token,_client_secret,_access_token,_host,_max_body)
      @access_token  = _access_token
      @client_token  = _client_token
      @client_secret = _client_secret
      @max_body      = _max_body
      @host          = _host
    end
    attr_reader :access_token
    attr_reader :client_token
    attr_reader :client_secret
    attr_reader :host
    attr_reader :max_body
  end
end
