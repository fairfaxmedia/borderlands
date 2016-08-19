require 'borderlands/hostnamestatus'
require 'resolv'

module Borderlands
  class CNAMEChecker
    def initialize
      @resolver = Resolv::DNS.new
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
      begin
        result = lookup(name)
        status = :dns_mismatch if result != target && lookup(result) != target
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
