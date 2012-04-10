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

      def newsfeed_picture_url(activity)
        case
          when activity.trackable_type.eql?("Tweet")
            url = '/assets/givegab-icon.png'
          when (activity.trackable_type.eql?("Program") || activity.trackable_type.eql?("NpJob"))
            url = activity.trackable.organization.logo.profile.url
          when activity.trackable_type.eql?("Task")
            url = activity.trackable.program.organization.logo.profile.url
          when activity.trackable_type.eql?("Group")
            if activity.trackable.logo.present? && activity.trackable.logo.profile.url != "/assets/profile_default_group_logo.png"
              url = activity.trackable.logo.profile.url
            elsif activity.trackable.is_collegiate?
              url = '/assets/university-icon.png'
            end
          when activity.owner.present?
            url = activity.owner.picture.thumb.url
          else
            url = ""
        end
        url
      end

      def requires_security_check(activity)
        activity.trackable_type.eql?("GroupMembership")
      end
    end
  end
end