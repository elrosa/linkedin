require 'oauth'

module LinkedIn

  class << self
    attr_accessor :token, :secret, :default_profile_fields

    # config/initializers/linkedin.rb (for instance)
    #
    # LinkedIn.configure do |config|
    #   config.token = 'consumer_token'
    #   config.secret = 'consumer_secret'
    #   config.default_profile_fields = ['education', 'positions']
    # end
    #
    # elsewhere
    #
    # client = LinkedIn::Client.new
    def configure
      yield self
      true
    end
  end

  autoload :Api,     "linked_in/api"
  autoload :Client,  "linked_in/client"
  autoload :Mash,    "linked_in/mash"
  autoload :Errors,  "linked_in/errors"
  autoload :Helpers, "linked_in/helpers"
  autoload :Search,  "linked_in/search"
  autoload :Version, "linked_in/version"
  autoload :Base,    "linked_in/base"

  autoload :Comment, "linked_in/comment"
  autoload :User,    "linked_in/user"
  autoload :Company, "linked_in/company"
  autoload :Activity,"linked_in/activity"

  autoload :Status,  "linked_in/status"
  autoload :Post,    "linked_in/post"
end
