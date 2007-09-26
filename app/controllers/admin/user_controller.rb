class Admin::UserController < ApplicationController

    before_filter :check_authentication_admin
    verify :method => :post, :only => [ :destroy_user ],
         :redirect_to => { :action => :list_users }
         

    def list_users
       @user_pages, @users = paginate :users, :per_page => 20
    end

    def show_user
       @user = User.find(params[:id])
    end

    def edit_user
       if request.post?
          @user = User.find_by_id(params[:id])
          if @user.update_attributes(params[:user])
            if !$MAGIC_USERS.include?(@user.email)
              @user.active=params[:user][:active]
              @user.admin=params[:user][:admin]
            end 
            @user.save
            if params[:password].length > 0
  	             @errors="" # start with no errors, then add errors if parameters are not correct
      	         @errors += "Please enter a password of at least 3 characters.<br/>" if params[:password].length < 3
                   @errors += "Please ensure the two passwords you have entered match.<br/>" if params[:password]!=params[:password_confirmation]
  	             if @errors.empty? # if no errors occur, try to save user
                      @user.password=params[:password] 
                      @user.save
                      flash[:notice]='The account and password were successfully updated.'
                      redirect_to :action => 'list_users', :id => @form
                   else
                      @errors="Please correct the following problems to continue:<br/>" + @errors         
                      flash.now[:warning]=@errors
                   end
             else
                   flash[:notice]='The user was successfully updated.'
                   redirect_to :action => 'list_users', :id => @form
             end           
          end
       else
          @user = User.find_by_id(params[:id])
       end
    end

    def destroy_user
        begin
           User.find(params[:id]).destroy
           flash[:message]='The user was deleted.'
         rescue Exception => exc
           flash[:warning]=exc.message
        end
        redirect_to :action => 'list_users'
    end
                  
end
