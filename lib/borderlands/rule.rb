require 'borderlands/akamaiobject'
require 'borderlands/behavior'
require 'borderlands/criteria'

module Borderlands
  class Rule < AkamaiObject
    def initialize(data, options={})
      @id         = data['name'] # rules don't have an id field
      @name       = data['name']
      @options    = data['options']
      @behaviors = []
      @depth      = options[:depth] || 0
      if data['behaviors']
        @behaviors = data['behaviors'].map do |bv|
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
          Rule.new(child, { :depth => @depth + 1 })
        end
      end
    end

    def is_secure
      options['is_secure']
    end

    def to_pp
      bn = @behaviors.map { |b| b.name }
      cn = @criteria.map  { |c| c.name }
      indent = "\t" * @depth
      ppout = [ "#{indent}#{name}: criteria[#{cn.join(',')}], behaviours[#{bn.join(',')}]" ]
      if @children
        @children.each { |child| ppout << child.to_pp }
      end
      ppout.join("\n")
    end

    def match_behaviors(bmatch)
      behaviors.keep_if { |b| b.name == bmatch }
    end

    def walk(&block)
      raise "expected block" unless block_given?
      yield self
      @children.each { |child| child.walk(&block) } if @children
    end

    attr_reader :options
    attr_reader :criteria
    attr_reader :behaviors
    attr_reader :children
    attr_reader :depth
  end

end
