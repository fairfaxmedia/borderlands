require 'borderlands/authinfo'
require 'borderlands/client'
require 'inifile'

module Borderlands
  class Config
    def initialize(file = "#{ENV['HOME']}/.edgerc")
      @ini = IniFile.load(file)
    end
    def authinfo(section = :default)
      raise "no such section '#{section}'" unless @ini[section]
      [ 'access_token', 'client_token', 'client_secret', 'host' ].each do |x|
        raise "section '#{section}' missing required '#{x}' entry" unless @ini[section][x]
      end
      AuthInfo.new(
        @ini[section]['client_token'],
        @ini[section]['client_secret'],
        @ini[section]['access_token'],
        @ini[section]['host'],
        @ini[section]['max-body'] || 131072
      )
    end
    def client(section = :default)
      Client.new(authinfo(section))
    end
  end
end
