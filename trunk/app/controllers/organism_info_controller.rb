class OrganismInfoController < ApplicationController
  
  before_filter :check_authentication, :only=>'record'
  
  def view
  
    @organism_infos=OrganismInfo.find(:all,:conditions=>["organism_id=?",params[:id]],:order=>"Date DESC")
    render(:partial=>"view",:layout=>false, :object=>@organism_infos)
    
  end
  
  def record
         
   organism_id=params[:id]   

   if request.post?
        
       # get form data
       organism_info_form_data=params[:organism_info]
       
       # create the new info
       @organism_info=OrganismInfo.create(organism_info_form_data)
       @organism_info.organism_id=organism_id
       @organism_info.date=Time.now
       @organism_info.user=session[:user]
       
       redirect_to(:controller=>"organism",:action=>"view",:id=>organism_id) if @organism_info.save == true

    end # end check for page posted
    
    # get the details for this organism
    @organism=Organism.find(organism_id,:include=>:organism_infos)
      
  end
  
end
