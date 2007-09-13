class UserController < ApplicationController

    before_filter :check_authentication, :only=>:edit

    def check_authentication    
      go_to_login unless session[:user]
    end

	def login
	
     service=params[:service] || "" # check for web service call
     
	   if request.get? && service==""
	     session[:user]=nil
	   else
	     begin # rescue check
          user = User.authenticate(params[:email], params[:password])
          session[:last_entry]=nil # clear previous observation in case it was there
          if service=="" # check for web service call
              session[:user] = user
              redirect_to session[:return_to] || '/' # if not, go to the next page
          else # this is a web service call
              user.password_salt=""
              user.password_hash=""
              @web_service_response=user
              render :template=>'web_service/response.rxml',:layout=>false
              return
          end # end check for web service call
         rescue Exception => exc # login failed
           if service=="" # check for web service call
              flash.now[:warning]=exc.message
              return
           else # this is a web service call
              return_user=User.new
              return_user.id=""
              web_service_response(return_user)
              return
          end # end check for error
         end # end rescue clause
	   end # end check for posted page
	   
	end
	
	def logout
	
	   session[:user] = nil
       redirect_to :controller=>'home', :action=>'index'
       	
	end

    def create
    
      if request.post?
         @user=User.new(params[:user])
         @errors="" # start with no errors, then add errors if parameters are not correct
	       @errors += "Please enter a password of at least 3 characters.<br/>" if params[:password].length < 3
         @errors += "Please ensure the two passwords you have entered match.<br/>" if params[:password]!=params[:password_confirmation]
	     if @errors.empty? # if no errors occur, try to save user
            @user.password=params[:password]
            if @user.save
              flash[:notice]='Your account was successfully created.'
              session[:user]=@user
              redirect_to :controller=>'home',:action=>'index'
            end
         else # otherwise show errors
            @errors="Please correct the following problems to continue:<br/>" + @errors
            flash.now[:warning]=@errors
         end
      end
      
    end
    
    def forgot_password
      
      if request.post?
        @user=User.find_by_email(params[:email])
        if @user != nil
          new_password=[Array.new(6){rand(256).chr}.join].pack("m").chomp
          Emailer.deliver_send_password(@user,new_password)
          @user.password=new_password
          @user.save
          flash[:notice]="A new password has been emailed to you.  After logging in, reset your password by updating your account information."
          redirect_to :controller=>'user',:action=>'login'
        else
          flash.now[:warning]="The email address you have entered was not found in the system.  Please be sure you enter the same email address you registered with."
        end
      end
      
    end
    
    def edit
    
      if request.post?
        
        @user=User.find_by_email(session[:user].email)
        if @user.update_attributes(params[:user])
           session[:user]=@user
           if params[:password].length > 0
	             @errors="" # start with no errors, then add errors if parameters are not correct
    	         @errors += "Please enter a password of at least 3 characters.<br/>" if params[:password].length < 3
                 @errors += "Please ensure the two passwords you have entered match.<br/>" if params[:password]!=params[:password_confirmation]
	             if @errors.empty? # if no errors occur, try to save user
                    @user.password=params[:password] 
                    @user.save
                    flash.now[:notice]='Your account and password were successfully updated.'
                 else
                    @errors="Please correct the following problems to continue:<br/>" + @errors         
                    flash.now[:warning]=@errors
                 end
           else
                 flash.now[:notice]='Your account was successfully updated.'
           end          
        end
        
      else
      
        @user=session[:user]
      
      end
      
    end
    	
end
