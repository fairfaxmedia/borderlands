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

    method_option :all,
      type: :boolean,
      default: false,
      desc: 'display properties that have no hostname/DNS problems'
    desc 'audit_hostnames', 'examine all accessible properties for DNS anomalies'
    def audit_hostnames
      format = "%-40s %-4s %-45s %-45s %-s"
      puts sprintf format, *%w(PROPERTY PVER HOSTNAME EDGE-HOSTNAME DNS-STATUS)
      propertymanager.properties.sort.each do |property|
        hostnames = propertymanager.hostnames(property)
        if hostnames
          if options[:all] || ! hostnames.all? { |hostname| hostname.status.ok? }
            hostnames.each do |hostname|
              puts sprintf format,
                property.name,
                property.productionversion, 
                hostname.name,
                hostname.edgehostname,
                hostname.status.to_s
            end
          end
        else
          puts sprintf format,
            property.name,
            property.productionversion || 'none',
            *%w(none none DNS:NONE)
        end
      end
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
