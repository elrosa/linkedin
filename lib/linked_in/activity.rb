module LinkedIn
  class Activity < LinkedIn::Base
    lazy_attr_reader :name, :url


    #@return [LinkedIn::Activity]
    def initialize(attrs={})
      super
    end

  end
end