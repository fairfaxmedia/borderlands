module Borderlands
  class RuleAuditor
    def initialize(options={})
      @propertymanager = options[:propertymanager]
      @propertycache   = options[:propertycache] || @propertymanager.properties
    end
  end
end
