module Borderlands
  class AkamaiObject
    def id
      nil
    end
    def name
      nil
    end
    def to_s
      name
    end
    def <=>(other)
      self.to_s <=> other.to_s
    end
    attr_reader :id
    attr_reader :name
  end
end
