require 'borderlands/property'
require 'borderlands/contract'
require 'borderlands/group'
require 'borderlands/client'
require 'borderlands/hostname'
require 'borderlands/rule'

module Borderlands
  class PropertyManager
    def initialize(client)
      raise 'client must be a Borderlands::Client object' unless client.is_a? Client
      @client = client
    end

    def groups
      begin
        groups_hash = @client.get_json_body('/papi/v0/groups')
        groups = groups_hash['groups']['items'].map do |grp|
          Group.new grp
        end
        groups
      rescue Exception => e
        raise "unable to retrieve groups: #{e.message}"
      end
    end
    
    def contracts
      begin
        contracts_hash = @client.get_json_body('/papi/v0/contracts')
        contracts = contracts_hash['contracts']['items'].map do |ctr|
          Contract.new ctr
        end
        contracts
      rescue Exception => e
        raise "unable to retrieve contracts: #{e.message}"
      end
    end

    # fetch a single property
    def property(contractid, groupid, propertyid)
      begin
        property_hash = @client.get_json_body(
          "/papi/v0/properties/#{propertyid}",
          { 'contractId' => contractid, 'groupId' => groupid, },
        )
      rescue
        puts "# unable to retrieve property for (group=#{groupid},contract=#{contractid},property=#{propertyid}): #{e.message}"
      end
      Property.new property_hash['properties']['items'].first
    end

    # takes a long time to complete!
    def properties
      properties = []
      contract_group_pairs.each do |cg|
        begin
          properties_hash = @client.get_json_body(
            "/papi/v0/properties/",
            { 'contractId' => cg[:contract], 'groupId' => cg[:group], }
          )
          if properties_hash && properties_hash['properties']['items']
            properties_hash['properties']['items'].each do |prp|
              properties << Property.new(prp)
            end
          end
        rescue Exception => e
          # probably due to Akamai PM permissions, don't raise for caller to handle
          puts "# unable to retrieve properties for (group=#{cg[:group]},contract=#{cg[:contract]}): #{e.message}"
        end
      end
      properties
    end

    # version defaults to the current production version, which is pretty
    # much always going to be the most meaningful thing to look at
    def hostnames(property, version = nil)
      raise 'property must be a Borderlands::Property object' unless property.is_a? Property
      version ||= property.productionversion
      begin
        hostnames_hash = @client.get_json_body(
          "/papi/v0/properties/#{property.id}/versions/#{version}/hostnames/",
          { 'contractId' => property.contractid, 'groupId' => property.groupid },
        )
      rescue Exception => e
        raise "unable to retrieve hostnames for #{property.name}: #{e.message}"
      end
      if hostnames_hash && hostnames_hash['hostnames'] && hostnames_hash['hostnames']['items']
        hostnames = hostnames_hash['hostnames']['items'].map do |ehn|
          Hostname.new ehn
        end
      else
        # no hostnames returned
        hostnames = nil
      end
      hostnames
    end

    # version defaults to current production version here too
    def ruletree(property,version = nil)
      raise 'property must be a Borderlands::Property object' unless property.is_a? Property
      version ||= property.productionversion
      tree = nil
      begin
        rt = @client.get_json_body(
          "/papi/v0/properties/#{property.id}/versions/#{version}/rules/",
          { 'contractId' => property.contractid, 'groupId' => property.groupid },
        )
        tree = Rule.new rt['rules']
      rescue Exception => e
        raise "unable to retrieve rule tree for #{property.name}: #{e.message}"
      end
      tree
    end

  private
    def contract_group_pairs
      pairs = []
      groups.map do |group|
        if group.contractids
          group.contractids.map do |ctr|
            pairs << { :group => group.id, :contract => ctr }
          end
        end
      end
      pairs
    end
  end
end
