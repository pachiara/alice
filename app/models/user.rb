class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable, password_length: 8..25

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :admin 
  # attr_accessible :title, :body
  
  validate  :email_domain
  
  def email_domain
    if !Rails.configuration.x.alice["users_email_domain_validation_regex"].nil?
      r = Regexp.new(Rails.configuration.x.alice["users_email_domain_validation_regex"])
      if (r =~ email).nil?
        errors.add(:email, :invalid_domain)
      end
    end
  end
  
end
