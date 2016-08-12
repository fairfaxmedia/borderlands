require 'borderlands/property'
require 'borderlands/contract'
require 'borderlands/group'
require 'borderlands/client'

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

    # takes a long time to complete!
    def properties
      properties = []
      contract_group_pairs.each do |cg|
        begin
          properties_hash = @client.get_json_body(
            [ "/papi/v0/properties/?",
              "contractId=#{cg[:contract]}&",
              "groupId=#{cg[:group]}" ].join
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
