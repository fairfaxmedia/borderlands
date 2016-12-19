module Borderlands
  class PropertyAuditor
    def initialize(properties=[], options={})
      raise 'need some properties!' unless properties.size > 0
      raise 'properties must all be Property class' unless properties.all? { |p| p.is_a? Property }
      @properties = properties
      @propertymanager = options[:propertymanager]
    end

    def filter(&block)
      filtered_properties = []
      @properties.each do |property|
        filtered_properties << property if yield(property)
      end
      @properties = filtered_properties
    end

    def walk(&block)
      @properties.each do |property|
        walk_one(property,&block)
      end
    end

    def walk_one(property,&block)
      raise 'property must be a Property object' unless property.is_a? Property
      yield(property)
    end

    def report_one(report)
      puts report.to_s
    end

    def property_hashkey(property)
      raise 'property must be a Property object' unless property.is_a? Property
      [ property.id, property.accountid, property.groupid, ].join('/')
    end

    attr_reader :properties
  end

  class PropertyRuletreeAuditor < PropertyAuditor
    def initialize(properties=[],options={})
      super
      raise 'must supply a PropertyManager object' unless @propertymanager
      @ruletreecache = {}
    end

    def ruletree(property)
      key = property_hashkey(property)
      unless @ruletreecache[key].is_a? Rule
        @ruletreecache[key] = @propertymanager.ruletree(property)
      end
      @ruletreecache[key]
    end

    def walk_one(property,&block)
      raise 'property must be a Property object' unless property.is_a? Property
      yield(property,ruletree(property))
    end
  end
end
