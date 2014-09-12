module LinkedIn
  class Status < LinkedIn::Base
    lazy_attr_reader :commentable, :comments, :comments_count, :likable, :liked, :num_likes,
                     :posted_at, :text, :update_key, :user, :timestamp


    #@return [LinkedIn::Status]
    def initialize(attrs={})
      super
    end

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

    # @return [String]
    def text
      @text ||= @attrs.deep_find('current_status') || @attrs.deep_find('current_share').try(:comment) || @attrs.deep_find("body")
    end

    # @return [LinkedIn::User]
    def user
      @user ||= LinkedIn::User.new(@attrs.deep_find('person') || {})
    end
  end
end

