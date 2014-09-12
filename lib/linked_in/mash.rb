require 'hashie'
require 'hashie/extensions/deep_find'
require 'multi_json'

module LinkedIn
  class Mash < ::Hashie::Mash
    include Hashie::Extensions::DeepFind

    # a simple helper to convert a json string to a Mash
    def self.from_json(json_string)
      result_hash = ::MultiJson.decode(json_string)
      new(result_hash)
    end

    protected

    # overload the convert_key mash method so that the LinkedIn
    # keys are made a little more ruby-ish
    def convert_key(key)
      case key.to_s
        when '_key'
          'id'
        when '_total'
          'total'
        when 'values'
          'all'
        when 'numResults'
          'total_results'
        else
          underscore(key)
      end
    end

    # borrowed from ActiveSupport
    # no need require an entire lib when we only need one method
    def underscore(camel_cased_word)
      word = camel_cased_word.to_s.dup
      word.gsub!(/::/, '/')
      word.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
      word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
      word.tr!("-", "_")
      word.downcase!
      word
    end


  end
end
