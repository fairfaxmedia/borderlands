require 'borderlands/akamaiobject'
require 'borderlands/behavior'
require 'borderlands/criteria'

module Borderlands
  class Rule < AkamaiObject
    def initialize(data)
      @id         = data['name'] # rules don't have an id field
      @name       = data['name']
      @options    = data['options']
      @behaviours = []
      if data['behaviors']
        @behaviours = data['behaviors'].map do |bv|
          Behavior.new bv
        end
      end
      @criteria = []
      if data['criteria']
        @criteria = data['criteria'].map do |cv|
          Criteria.new cv
        end
      end
      if data['children'] && data['children'].size > 0
        @children = data['children'].map do |child|
          Rule.new child
        end
      end
    end
    def is_secure
      options['is_secure']
    end
    attr_reader :options
    attr_reader :behaviors
  end
end
