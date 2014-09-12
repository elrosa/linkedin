module LinkedIn
  module Api

    module QueryMethods

      def profile(options={})
        path = person_path(options)
        simple_query(path, options)
      end

      def connections(options={})
        path = "#{person_path(options)}/connections"
        simple_query(path, options)
      end

      def network_updates(options={})
        path = "#{person_path(options)}/network/updates"
        raw_posts = simple_query(path, options)
        raw_posts.fetch("all", []).map{|post|
          LinkedIn::Post.new(post)
        }
      end

      def stream_updates(options={})
        path = "#{person_path(options)}/network/updates"
        raw_posts = simple_query(path, options.merge({type: ['SHAR']}))
        raw_posts.fetch("all", []).map{|post|
          LinkedIn::Status.new(post)
        }
      end

      def connection_count(options={})
        path = "#{person_path(options)}/num-connections"
        get(path)
      end

      def company(options = {})
        path   = company_path(options)
        simple_query(path, options)
      end

      def current_share(options = {})
        path = "#{person_path(options)}:(current-share)"
        simple_query(path, options)
      end

      def current_share_id(options = {})
        path = "#{person_path(options)}/network/updates?scope=self&count=1"
        q = simple_query(path)
        q["all"].first["update_key"]
      end

      private

        def simple_query(path, options={})
          fields = options[:fields] || LinkedIn.default_profile_fields

          if options[:public]
            path +=":public"
          elsif fields
            path +=":(#{fields.map{ |f| f.to_s.gsub("_","-") }.join(',')})"
          end
          headers = options[:headers] || {}
          if options[:params]
            path += "?#{options[:params].to_param}"
          end
          Mash.from_json(get(path, headers))
        end

        def person_path(options)
          path = "/people/"
          if options[:id]
            path += "id=#{options[:id]}"
          elsif options[:url]
            path += "url=#{CGI.escape(options[:url])}"
          else
            path += "~"
          end
        end

        def company_path(options)
          path = "/companies/"
          if options[:id]
            path += "id=#{options[:id]}"
          elsif options[:url]
            path += "url=#{CGI.escape(options[:url])}"
          elsif options[:name]
            path += "universal-name=#{CGI.escape(options[:name])}"
          elsif options[:domain]
            path += "email-domain=#{CGI.escape(options[:domain])}"
          else
            path += "~"
          end
        end

    end

  end
end