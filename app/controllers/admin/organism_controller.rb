class Admin::OrganismController < ApplicationController
  
      before_filter :check_authentication_admin
      verify :method => :post, :only => [ :destroy_observation ],
         :redirect_to => { :controller=>:home, :action => :error }
         
    def destroy_observation
      id=params[:id]
      referer=params[:referer] || request.referer
      Entry.delete(id)
      flash[:notice]="The observation was deleted."
      redirect_to referer
    end
  
end
