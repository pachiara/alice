module Loggable
  extend ActiveSupport::Concern
  
  def alice_logger
    @@alice_logger ||= Logger.new("#{Rails.root}/#{Rails.configuration.x.alice['alice_logger_path']}")
  end

  def user=(u)
    @user = u
  end

  def user
    @user
  end
  
end