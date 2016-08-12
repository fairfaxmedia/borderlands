require "borderlands/version"
require "borderlands/config"
require "borderlands/propertymanager"
require 'json'
require 'pp'
require 'resolv'
require 'thor'

module Borderlands
  class CLI < Thor
    desc 'list_groups', 'list all accessible property groups'
    def list_groups
      puts propertymanager.groups.sort.map { |g| "#{g.id} #{g.name}" }
    end

    desc 'list_contracts', 'list all accessible contracts'
    def list_contracts
      puts propertymanager.contracts.sort.map { |c| "#{c.id} #{c.name}" }
    end

    desc 'list_properties', 'list all accessible properties'
    def list_properties
      puts "# retrieving properties. this may take rather a long time..."
      puts propertymanager.properties.sort.map { |p| "#{p.id} #{p.name}" }
    end

    desc 'version', 'display Borderlands gem version'
    def version
      puts "Borderlands v#{VERSION}"
    end

  private
    def akamai(section = :default)
      @edgegrid_config ||= Config.new
      @edgegrid_client ||= {}
      @edgegrid_client[section] ||= @edgegrid_config.client(section)
      @edgegrid_client[section]
    end
    def propertymanager
      @pm ||= PropertyManager.new(akamai)
    end
  end
end
