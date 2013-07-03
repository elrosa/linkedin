module LinkedIn
  module Api

    module UpdateMethods

      def add_share(share)
        path = "/people/~/shares"
        defaults = {:visibility => {:code => "anyone"}}
        post(path, defaults.merge(share).to_json, "Content-Type" => "application/json")
      end

      def update_comment(network_key, comment)
         path = "/people/~/network/updates/key=#{network_key}/update-comments"
         comment_hash = {:comment => comment}
         post(path, comment_hash.to_json, "Content-Type" => "application/json")
      end


      def delete_comment(network_key, comment)
         path = "/people/~/network/updates/key=#{network_key}/update-comments"
         comment_hash = {:comment => comment}
         post(path, comment_hash.to_json, "Content-Type" => "application/json")
      end

      def update_like(network_key, liked)
         path = "/people/~/network/updates/key=#{network_key}/is-liked"
         put(path, liked, "Content-Type" => "application/json")
      end


    end

  end
end
