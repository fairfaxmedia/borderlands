module Borderlands
  class HostnameStatus
    def initialize(status, message = nil)
      raise 'invalid hostname status: #{status}' unless STATUS.keys.include? status
      @status  = status
      @message = message
    end
    def ok?
      status == :dns_ok
    end
    def to_s
      ok? ? STATUS[status] : "#{STATUS[status]} (#{message})"
    end
    attr_reader :status
    attr_reader :message
  private
    STATUS = {
      :dns_ok       => 'DNS:OK',
      :dns_mismatch => 'DNS:MISMATCH',
      :dns_error    => 'DNS:ERROR',
      :dns_failure  => 'DNS:FAILURE',
    }
  end
end

