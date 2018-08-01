class ApplicationMailer < ActionMailer::Base
  default from: 'alice@lispa.it'
  layout 'mailer'
end
