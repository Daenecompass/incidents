class Comment < ApplicationRecord
  include PgSearch::Model
  multisearchable against: [:comment], using: {
      tsearch: {
          prefix: true,
          highlight: {
              StartSel: '<b>',
              StopSel: '</b>'
          }
      }
  }

  after_create_commit :notify_mentioned_users

  belongs_to :user
  belongs_to :ticket

  validates :comment, presence: true

  private
    def notify_mentioned_users
        mentions = begin
            regex = /@([\w]+)/
            self.description.scan(regex).flatten    
        end
        mentioned_users = User.where(username: mentions)
        mentioned_users.each do |user|
            MentionMailer.mentioned_in_ticket_comment(user, self).deliver_later
        end
    end
end
