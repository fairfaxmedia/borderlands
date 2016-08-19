require 'borderlands/akamaiobject'

module Borderlands
  class Property < AkamaiObject
    def initialize(data)
      @id                = data['propertyId']
      @name              = data['propertyName']
      @accountid         = data['accountId']
      @contractid        = data['contractId']
      @groupid           = data['groupId']
      @latestversion     = data['latestVersion']
      @stagingversion    = data['stagingVersion']
      @productionversion = data['productionVersion']
      @note              = data['note']
    end
    attr_reader :accountid
    attr_reader :contractid
    attr_reader :groupid
    attr_reader :latestversion
    attr_reader :stagingversion
    attr_reader :productionversion
    attr_reader :note
  end
end
