require "borderlands/version"
require "borderlands/config"
require "borderlands/propertymanager"
require "borderlands/propertyauditor"
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
      puts propertymanager.properties.sort.map { |p| "#{p.contractid} #{p.groupid} #{p.id} #{p.name}" }
    end

    desc 'ruletree', 'dump rule tree for a property'
    method_option :property, type: :string, required: true, desc: 'id of property'
    method_option :contract, type: :string, required: true, desc: 'id of contract'
    method_option :group, type: :string, required: true, desc: 'id of group'
    def ruletree
      property = propertymanager.property(
        options[:contract],
        options[:group],
        options[:property],
      )
      rt = propertymanager.ruletree(property)
      rt.walk do |rule|
        indent = "\t" * rule.depth.to_i
        puts "#{indent}rule: #{rule.name}"
        rule.criteria.each  { |c| puts "#{indent}- criteria:  #{c.name}" }
        rule.behaviors.each { |b| puts "#{indent}- behaviour: #{b.name}" }
      end
    end

    desc 'list_origins', 'list all origin hostnames used in a property'
    method_option :property, type: :string, required: true, desc: 'id of property'
    method_option :contract, type: :string, required: true, desc: 'id of contract'
    method_option :group, type: :string, required: true, desc: 'id of group'
    def list_origins
      property = propertymanager.property(
        options[:contract],
        options[:group],
        options[:property],
      )
      rt = propertymanager.ruletree(property)
      origins = []
      rt.walk do |rule|
        rule.behaviors.keep_if { |x| x.name == 'origin' }.each do |behaviour|
          origins << behaviour.options['hostname']
        end
      end
      puts origins.uniq.sort.join("\n")
    end

    method_option :all, type: :boolean, default: false,
      desc: 'list properties that have no DNS problems'
    desc 'audit_hostnames', 'examine all accessible properties for DNS anomalies'
    def audit_hostnames
      groups = {}
      propertymanager.groups.sort.each { |g| groups[g.id] = g.name.gsub(/\s+/,'_') }
      format = "%-8s %-30s %-40s %-4s %-45s %-45s %-s"
      puts sprintf format, *%w(VERDICT GROUP PROPERTY PVER HOSTNAME EDGE-HOSTNAME DNS-STATUS)
      propertymanager.properties.sort.each do |property|
        group = groups[property.groupid]
        hostnames = propertymanager.hostnames(property)
        if hostnames
          verdict = 'PROBLEMS' if hostnames.any?  { |hostname| hostname.status.ok? }
          verdict = 'DEAD'     if hostnames.none? { |hostname| hostname.status.ok? }
          verdict = 'OK'       if hostnames.all?  { |hostname| hostname.status.ok? }
          if options[:all] || verdict != 'OK'
            hostnames.each do |hostname|
              puts sprintf format,
                verdict,
                groups[property.groupid],
                property.name,
                property.productionversion,
                hostname.name,
                hostname.edgehostname,
                hostname.status.to_s
            end
          end
        else
          puts sprintf format,
            'DEAD',
            group,
            property.name,
            property.productionversion || 'none',
            *%w(none none DNS:NONE)
        end
      end
    end

    desc 'audit_origins', 'check conformance of origin rules'
    def audit_origins
      properties = propertymanager.properties
      pra = PropertyRuletreeAuditor.new(properties, { :propertymanager => propertymanager })
      pra.walk do |property,ruletree|
        puts "property: #{property.name}"
        ruletree.walk do |rule|
          behaviors = rule.behaviors.map { |b| b.name }
          ok = true
          if behaviors.include? 'origin'
            ok = [ 'origin','cpCode' ].all?  { |bb| behaviors.include? bb }
            puts "* #{rule.name}: origin without corresponding cpCode behaviour" unless ok
            origin = rule.match_behaviors('origin').first
            if origin.options['cacheKeyHostname'] == 'ORIGIN_HOSTNAME'
              puts "* #{rule.name}: cache key hostname == origin hostname"
            end
          else
            ok = false
          end
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
