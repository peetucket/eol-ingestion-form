 
class HomeController < ApplicationController

  @@numEntriesHomePage=15 # the number of latest entries to get on home page
  
  def index
	
  	@entries=get_latest_entries(@@numEntriesHomePage)
	
    # get a google map ready at zoom 1 centered on the 0,0 lat/lon
    @map = create_map(0,0,1)
          
    # loop over last observations and add markers to map
    for entry in @entries
      add_single_map_marker(@map,entry)
    end
    
    if session[:user] != nil then
      @address=session[:user].address
    end
   
  end

  # periodic ajax call from home page
  def ajax_update_latest_entries
		
  	@entries=get_latest_entries(@@numEntriesHomePage)
    
    render(:layout=>false)
    	
  end
  
  def error
    
  end

##########################################################################
# Private Methods
##########################################################################
  private
  def get_latest_entries(num)
	
	# get the last num observations made
    Entry.find(:all,:limit=>num,:order=>"entries.created_at DESC", :include=>[:user,:organism])

  end
  

 

end

