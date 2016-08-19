require 'borderlands/akamaiobject'
require 'borderlands/cnamechecker'

module Borderlands
  class Hostname < AkamaiObject
    def initialize(data)
      @id           = data['edgeHostnameId']
      @name         = data['cnameFrom']
      @edgehostname = data['cnameTo']
      @cnametype    = data['cnameType']
      update_status
    end
    def update_status(refresh = false)
      @cnamechecker ||= CNAMEChecker.new
      @status = @cnamechecker.check(name,edgehostname) if ! status || refresh
    end
    attr_reader :edgehostname
    attr_reader :status
  end
end
