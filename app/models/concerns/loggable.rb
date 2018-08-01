module Loggable
  extend ActiveSupport::Concern

  def alice_logger
    @@alice_logger ||= Logger.new("#{ALICE['alice_logger_path']}#{ALICE['alice_logger_name']}")
  end

  def user=(u)
    @user = u
  end

  def user
    @user
  end

end
