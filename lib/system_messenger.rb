module SystemMessenger
  # used to send system message to users within PXB

  # send msg to user
  def self.send_message usr, listing, msg_type
    if sender = User.where(:email => PIXI_EMAIL).first
      case msg_type
        when 'approve'; msg = 'Your pixi has been approved.'
	when 'deny'; msg = 'Your pixi has been denied due to #{listing.explanation}.'
      end

      # send message
      sender.posts.create(pixi_id: listing.pixi_id, recipient_id: usr.id, content: msg, msg_type: msg_type)
    end
  end
end