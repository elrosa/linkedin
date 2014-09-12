module LinkedIn
  class Post < LinkedIn::Base
    lazy_attr_reader :action, :activities, :commentable, :comments, :comments_count, :likable, :liked, :num_likes,
                     :post_type, :posted_at, :text, :update_key, :user, :company, :timestamp


    #@return [LinkedIn::Post]
    def initialize(attrs={})
      super
      self.activities
    end

    def action

    end

    # @return [LinkedIn::Activity]
    def activities
      @activities ||= create_activities(@attrs)
    end

    # @return [Boolean]
    def commentable
      @commentable ||= @attrs["is_commentable"]
    end

    # @return [LinkedIn::Comments]
    def comments
      @comments ||= @attrs["update_comments"].nil? ? [] : @attrs["update_comments"].fetch("all", []).map{|comment| LinkedIn::Comment.new(comment)}
    end
    # @return Integer
    def comments_count
      @comments_count ||= @attrs["update_comments"].nil? ? 0 : @attrs["update_comments"].fetch("_total", 0)
    end

    # @return Integer
    def company
      return @company if @company.present?

      company_hash = @attrs.deep_find('company') || {}
      #update = @attrs["update_content"]
      #
      #case @attrs["update_type"]
      #  when "JOBP"
      #    company_hash = update.fetch("job", {}).fetch("company", nil)
      #  when "CMPY"
      #    #I HATE THEM
      #    company_hash = update.fetch("company_update", {}).fetch("company", nil)
      #    company_hash ||= update.fetch("job", {}).fetch("company", nil)
      #end
      #company_hash ||= update.fetch("company", {})

      @company = LinkedIn::Company.new(company_hash)
    end

    # @return [Boolean]
    def likable
      @likable ||= @attrs["is_likable"] unless @attrs["is_likable"].nil?
    end

    # @return [Boolean]
    def liked
      @liked ||= @attrs["is_liked"] unless @attrs["is_liked"].nil?
    end

    #@return Time
    def posted_at
      @posted_at ||= Time.at(@attrs["timestamp"]/1000) unless @attrs["timestamp"].nil?
    end

    # @return [Symbol]
    def post_type
      #@post_type ||= @attrs["update_type"].downcase.to_sym unless @attrs["update_type"].nil?
      @post_type ||= guess_post_type(@attrs)
    end

    # @return [String]
    def text
      @text ||=
        if @attrs["update_content"].present?
          case @attrs["update_type"]
            when "STAT" then @attrs["update_content"]["person"]["current_status"]
            when "SHAR" then @attrs["update_content"]["person"]["current_share"]["comment"]
            else @attrs.deep_find("action").fetch("code", nil)
            #when "VIRL" then "added_#{@attrs["update_content"]["update_action"]["action"]["code"]}".downcase
            #else nil
          end
        else
          nil
        end
    rescue
      @text ||= nil
    end

    # @return [LinkedIn::User]
    def user
      return @user if @user.present?

      user_hash = nil
      update = @attrs["update_content"]

      case @attrs["update_type"]
      when "JOBP"
        user_hash = update.fetch("job", {}).fetch("job_poster", nil)
      when "MSFC"
        user_hash = update.fetch("company_person_update", {}).fetch("person", nil)
      when "CMPY"
        #I HATE THEM
        user_hash = update.fetch("company_update", {}).fetch("company_profile_update", {}).fetch("editor", nil)
        #user_hash ||= update.fetch("company_person_update", {}).fetch("person", nil)
      end
      user_hash ||= update.deep_find('person') #fetch("person", {})

      @user = LinkedIn::User.new(user_hash)
    end

    private
      def create_activities(attrs)
        person_updates = attrs["update_content"].person
        activities = []
        case attrs["update_type"]
          when "MSFC"
            company = attrs["update_content"].fetch("company")
            unless company.blank?
              activities << LinkedIn::Activity.new("name" => company.name, "url" =>  "http://linkedin.com/company/#{company.id}")
            end
          when "APPM"
            arr = []
            raw_activities = person_updates.fetch("person_activities", {"all" => []}).fetch("all")
            raw_activities.each {|activity|
              activities << LinkedIn::Activity.new("name" => activity.body)
            }
            arr
          when "QSTN"
            question = attrs["update_content"]["question"]
            activities << LinkedIn::Activity.new("name" => question.title, "url" =>  question.web_url)
          when "ANSW"
            question = attrs["update_content"]["question"]
            answers = question.fetch("answers", [])
            answers.each { |answer|
              activities << LinkedIn::Activity.new("name" => question["title"], "url" => question["web_url"], "description_url" => answer["web_url"])
            }
          when "JGRP"
            raw_groups = person_updates.fetch("member_groups", {"all" => []}).fetch("all")
            raw_groups.each { |group|
              url = group["site_group_request"].fetch("url", nil)  if group["site_group_request"]
              activities << LinkedIn::Activity.new("name" => group["name"], "url" => url)
            }
          when "CONN"
            raw_connections = person_updates.fetch("connections", {"all" => []}).fetch("all")
            raw_connections.each { |connection|
              user = LinkedIn::User.new(connection)
              activities << LinkedIn::Activity.new("name" => user.name, "url" => user.profile_url)
            }
          when "PREC"
            raw_recommendations = person_updates.fetch("recommendations_received", {"all" => []}).fetch("all")
            raw_recommendations.each {|recommendation|
              recommender = recommendation["recommender"]
              unless recommender.blank?
                user = LinkedIn::User.new(recommender)
                activities << LinkedIn::Activity.new("name" => user.name, "url" => user.profile_url)
              end
            }
          when "SVPR"
            raw_recommendations = person_updates.fetch("recommendations_given", {"all" => []}).fetch("all")
            raw_recommendations.each {|recommendation|
              recommendee = recommendation["recommendee"]
              unless recommendee.blank?
                user = LinkedIn::User.new(recommender)
                activities << LinkedIn::Activity.new("name" => user.name, "url" => user.profile_url)
              end
            }
          when "PROF"
            changed_hash = attrs.fetch("updated_fields", {"all" => []}).fetch("all").last
            unless changed_hash.blank?
              changed = changed_hash["name"]
              case changed
                when "person/skills"
                  skills = person_updates.fetch("skills", {"all" => []})
                  all_skills = skills.fetch("all")
                  all_skills.each {|skill|
                    activities << LinkedIn::Activity.new("name" => skill["skill"]["name"])
                  }
                  #post.post_type = :skill
                when "person/positions"
                  positions = person_updates.fetch("positions", {"all" => []})
                  all_positions = positions.fetch("all")
                  all_positions.each {|position|
                    company = position["company"]
                    unless company.blank?
                      activities << LinkedIn::Activity.new("name" => company.name, "url" => "http://linkedin.com/company/#{company.id}")
                      #post.post_type = :position
                    end
                  }
                when "person/organizations"
                  #post.post_type = :organization
              end
            end
          when "VIRL"
            original = attrs["updateContent"].fetch("updateAction", {}).fetch("updateContent", {}).fetch("person", {})
            if original.any?
              activities << LinkedIn::Activity.new("name" => "#{original["firstName"]} #{original["lastName"]}")
            end
        end
        activities
      end

      def guess_post_type attrs
        return attrs["update_type"].downcase.to_sym if attrs["update_type"] != "PROF"

        changed_hash = attrs.fetch("updated_fields", {"all" => []}).fetch("all").last
        unless changed_hash.blank?
          changed = changed_hash["name"]
          case changed
            when "person/skills"
              :skill
            when "person/positions"
              :position
            when "person/organizations"
              :organization
            else
              :prof
          end
        else
          :prof
        end

      end


  end
end