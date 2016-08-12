require 'borderlands/akamaiobject'

module Borderlands
  class Group < AkamaiObject
    def initialize(data)
      @id            = data['groupId']
      @name          = data['groupName']
      @parentgroupid = data['parentGroupId']
      @contractids   = data['contractIds']
    end
    attr_reader :parentgroupid
    attr_reader :contractids
  end
end

