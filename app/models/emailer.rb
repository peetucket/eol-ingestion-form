class Emailer < ActionMailer::Base
  
  def send_password(user,new_password)
    user=User.find(user.id)
    @subject    = $WEBSITE_NAME +": Password request"
    @body       = {:user=>user, :new_password=>new_password}
    @recipients = user.email
    @from       = $EMAIL_FROM
  end

  def activate_account(user)
    user=User.find(user.id)
    @subject    = $WEBSITE_NAME +": Activate Account"
    @body       = {:user=>user}
    @recipients = user.email
    @from       = $EMAIL_FROM
  end
      
end
