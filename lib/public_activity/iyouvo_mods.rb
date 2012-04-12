module PublicActivity
  # Module extending classes that serve as owners
  module IyouvoMods
    extend ActiveSupport::Concern
    module InstanceMethods
      def send_to_pusher(activity, key, owner, params)
        if !Pusher.app_id.nil? && !Pusher.key.nil? && !Pusher.secret.nil?
          picture_url = newsfeed_picture_url(activity)

          Pusher['acitivty-channel'].trigger('acitivty-create',
                                             {:activity_id => activity.id, :picture_url => picture_url, :key => key,
                                              :owner => owner, :parameters => params, :text => activity.text,
                                              :requires_security_check => requires_security_check(activity),
                                              :object => self})
        end
      end

      def newsfeed_picture_url(news_feed)
          case
            when news_feed.trackable_type.eql?("Tweet")
              url = '/assets/givegab-icon.png'
            when (news_feed.trackable_type.eql?("Program") || news_feed.trackable_type.eql?("NpJob"))
              url = determine_nonprofit_logo_url(news_feed.trackable.organization.logo)
            when news_feed.trackable_type.eql?("Task")
              url = determine_nonprofit_logo_url(news_feed.trackable.program.organization.logo)
            when news_feed.trackable_type.eql?("Organization")
              url = determine_nonprofit_logo_url(news_feed.trackable.logo)
            when news_feed.trackable_type.eql?("Group")
              if news_feed.trackable.logo.present? && news_feed.trackable.logo.profile.url != "/assets/profile_default_group_logo.png"
                url = news_feed.trackable.logo.profile.url
              elsif news_feed.trackable.is_collegiate?
                url = '/assets/university-icon.png'
              end
            when news_feed.owner.present?
              url = news_feed.owner.picture.thumb.url
            else
              url = ""
          end
          url
        end

        def determine_nonprofit_logo_url(logo)
          if logo.present? && logo.profile.url != "/assets/profile_default_org_logo.png"
            url = logo.profile.url
          else
            url = '/assets/nonprofit-icon.png'
          end
          url
        end

      def requires_security_check(activity)
        activity.trackable_type.eql?("GroupMembership")  ||
          (activity.trackable_type.eql?("Comment") &&
            activity.trackable.present? &&
            activity.trackable.commentable_type.eql?("Group"))
      end
    end
  end
end