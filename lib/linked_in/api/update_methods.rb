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
         comment_hash = {:update_comment => {:comment => comment}}
         post(path, comment_hash.to_json, "Content-Type" => "application/json")
      end

      def update_like(network_key, liked)
         path = "/people/~/network/updates/key=#{network_key}/is-liked"
         put(path, {:is_liked => liked}.to_json, "Content-Type" => "application/json")
      end


      # def update_network(message)
      #   path = "/people/~/person-activities"
      #   post(path, network_update_to_xml(message))
      # end
      #
      # def send_message(subject, body, recipient_paths)
      #   path = "/people/~/mailbox"
      #
      #   message         = LinkedIn::Message.new
      #   message.subject = subject
      #   message.body    = body
      #   recipients      = LinkedIn::Recipients.new
      #
      #   recipients.recipients = recipient_paths.map do |profile_path|
      #     recipient             = LinkedIn::Recipient.new
      #     recipient.person      = LinkedIn::Person.new
      #     recipient.person.path = "/people/#{profile_path}"
      #     recipient
      #   end
      #   message.recipients = recipients
      #   post(path, message_to_xml(message)).code
      # end
      #
      # def clear_status
      #   path = "/people/~/current-status"
      #   delete(path).code
      # end
      #

    end

  end
end
