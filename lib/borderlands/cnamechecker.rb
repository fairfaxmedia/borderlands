require 'resolv'

module Borderlands
  class CNAMEChecker
    def initialize
      @resolver = Resolv::DNS.new
    end
    def check(name,target)
      result = @resolver.getresource(name,Resolv::DNS::Resource::IN::CNAME)
      result && result.name.to_s == target
    end
  end
end
