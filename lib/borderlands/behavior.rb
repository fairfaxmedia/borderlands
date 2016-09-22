require 'borderlands/akamaiobject'

module Borderlands
  class Behavior < AkamaiObject
    def initialize(data)
      @id       = data['name'] # behaviours don't have an id field
      @name     = data['name']
      @options  = data['options']
    end
    attr_reader :options
  end
end
