module LinkedIn
  class Company < LinkedIn::Base
    lazy_attr_reader :id, :name,


    #@return [LinkedIn::Company]
    def initialize(attrs={})
      super
    end

  end
end