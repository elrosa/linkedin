require 'hashie'
require 'multi_json'

module LinkedIn
  class Mash < ::Hashie::Mash

    # a simple helper to convert a json string to a Mash
    def self.from_json(json_string)
      result_hash = ::MultiJson.decode(json_string)
      new(result_hash)
    end

  end
end
