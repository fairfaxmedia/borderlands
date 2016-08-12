require 'borderlands/akamaiobject'

module Borderlands
  class Contract < AkamaiObject
    def initialize(data)
      @id       = data['contractId']
      @name     = @id #because they don't have a name
      @typename = data['contractTypeName']
    end
    attr_reader :typename
  end
end
