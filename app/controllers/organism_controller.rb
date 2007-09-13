class OrganismController < ApplicationController

def view

  @limit = params[:limit] || $DEFAULT_LIMIT
  kml=params[:kml] || ""
    
  # get the details for this organism
  @organism=Organism.find(params[:id]) 
 
  # get all observation entries for the supplied organism
  @entries=Entry.find_all_by_organism_id(params[:id],:limit=>@limit, :order=>"date DESC")

  if kml != ""
    send_data(render(:template=>'web_service/kml.rxml',:layout=>false),:filename=>"observations.kml",:type => "application/vnd.google-earth.kml+xml")
    return
  end
  
  @num_entries=@entries.size
  
  @organism_infos=@organism.organism_infos
 
  # get a google map ready
  @map = create_map(0,0,1)
  
  # loop over last observations and add markers to map, showing different icon for your own observations
  for entry in @entries
      add_single_map_marker(@map,entry)    
  end

  
end

def search
  
  # search by organism page
   if session[:user] != nil
    # get list of organisms observered by logged in user
      @your_organisms=User.find(session[:user].id, :include=>:organisms).organisms.map {|o| [o.name, o.id]}
   end # end check for logged in user
  
  if request.post? # check for page post
 
        # get form data for search by organism name
        organism_name=params[:organism][:name]
       
         # check to see if this is an existing known organism
         @organism=Organism.find_by_name(organism_name)
         
         if @organism == nil # organism was not found        
          flash.now[:warning]="The organism you searched for was not found."
          return
         end # end check for existing organism found
         
         redirect_to(:action=>"view",:id=>@organism.id) 
         
       end # end check for page post

end

end
