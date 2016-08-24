require 'borderlands/hostnamestatus'
require 'resolv'

module Borderlands
  class CNAMEChecker
    def initialize
      @resolver = Resolv::DNS.new
    end
    def akamai_staging?(name)
      name.match /(edge(suite|key)|akamaihd)-staging.net$/
    end
    def lookup(name)
      result = @resolver.getresource(name,Resolv::DNS::Resource::IN::CNAME)
      if result
        result.name.to_s
      else
        false
      end
    end
    def check(name,target)
      status = :dns_ok
      message = nil

      # with Akamai this can actually happen, eg. foo.edgesuite.net used
      # as both hostname AND edge hostname
      return HostnameStatus.new(:dns_ok) if name == target 

      # where there is a wildcard, we can't safely assume anything, so
      # just assume it is ok
      return HostnameStatus.new(status,'wildcard used, cannot validate') if name.include? '*'

      begin
        result = lookup(name)
        status = :dns_mismatch if result != target && lookup(result) != target
        status = :dns_staging  if akamai_staging? result
      rescue Resolv::ResolvError => e
        status = :dns_error
        message = e.message
      rescue Exception => e
        status = :dns_failure
        message = e.message
      end
      HostnameStatus.new status, message
    end
  end
end
