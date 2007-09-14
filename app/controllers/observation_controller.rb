require 'net/http'
require 'uri'
require 'rexml/document'

class ObservationController < ApplicationController

 # user needs to be logged in to record an observation
 before_filter :check_authentication, :only=>[:enter_species,:record]
 
 def search
        
    @limit = params[:limit] || $DEFAULT_LIMIT
    
    # get the map for the location search
    @map = create_map(0,0,1) # default location 
    @map.event_init(@map,:click,javascript_for_clicked_location(true))
       
    # get the most observered organisms
    @popular_organisms=Entry.count(:all, :limit=>30, :group=> "organism", :order=>"1 desc")
    @popular_organisms_mapped=@popular_organisms.map {|organism,count| [organism.name,organism.id]}

   
 end

def search_results

    @limit = params[:limit] || $DEFAULT_LIMIT
    
    kml = params[:kml] || ""
                 
      # get coords and location for search by location
      entry = params[:entry]
      if entry != nil 
        @lat = entry[:lat]
        @lon = entry[:lon]
        @location=entry[:location]      
        @range = entry[:confidence_range] || "0"
        @range_unit = entry[:confidence_range_units] 
        @habitat_id = entry[:habitat_id]
      end # end check for coordinates entered
     
     # get form data for search by organism name
     @organism_name=params[:organism][:name]
     organism=Organism.find_by_name(@organism_name) if @organism_name !=""
     
     # get form data for search by observer name
     @observer_name=params[:user][:name]
     observer=User.find_by_fullname(@observer_name) if @observer_name != ""
     
     # get form data for description
     @description=params[:description]

     # get form data for attribute/value search
     data_point_params=params[:data_point] || ""
     attribute_value_params=params[:attribute_value] || ""
        
     conditions_columns=""
     conditions_values=""
     conditions=""
     
     # now set conditions
     if observer != nil 
         conditions_columns+="user_id=? and "
         conditions_values+=observer.id.to_s + ","
     end
     if organism != nil 
         conditions_columns+="organism_id=? and "
         conditions_values+=organism.id.to_s + ","
     end
     if @description != "" 
         conditions_columns+="description like ? and "
         conditions_values+="'%" + @description + "%',"   
    end
    if @habitat_id != "" 
         conditions_columns+="habitat_id=? and "
         conditions_values+=@habitat_id.to_s + "," 
    end
     
     # chop off last 'and' and ','
     conditions_columns.chomp!(" and ")
     conditions_values.chomp!(",")
 
     if conditions_columns != ""
       conditions=",:conditions=>['" + conditions_columns + "'," + conditions_values + "]"
     end

     @unique_users=Array.new
     @unique_organisms=Array.new
       
     # next check to see if we have also have a location search
     if @lat.to_f != 0 && @lon.to_f != 0 && @range.to_f != 0 # if we have entered a latitude, longitude
       
       commandstring="@entries=Entry.find_within(@range,:origin=>[@lat,@lon],:units=>params[@range_unit],:order=>:distance,:limit=>" + @limit + conditions + ")"

       @location_search=true
       
       # get a google map ready
       @map = create_map(@lat.to_f,@lon.to_f,get_zoom_range(@range))
     
       # set map center
       @map.overlay_init(GMarker.new([@lat.to_f,@lon.to_f],:icon=>:map_center,:title => "Search center", :info_window=>"Search center:<br>" + @location + "<br>" + formatLatLonDecimalAsDegrees(0,"",@lat,@lon)))
 
       elsif data_point_params[:value] !="" && attribute_value_params[:name] != "" # attribute search, NOT FUNCTIONAL YET
 
            attribute_value=AttributeValue.find_by_name(attribute_value_params[:name]) 
            if attribute_value.nil? == false
              data_points=DataPoint.find_all_by_attribute_value_id_and_value(attribute_value.id,data_point_params[:value])
              @entries=data_points.entries
            end           
       
       elsif conditions!="" # advanced search
     
         commandstring="@entries=Entry.find(:all,:order=>'date DESC',:limit=>" + @limit +  conditions + ")"
 
         @location_search=false
 
         # get a google map ready
         @map = create_map(0,0,1)
     
     end # end check for location search

     if commandstring!=nil # if we've got a search to run, execute and display results
      
       eval(commandstring)
      
       @num_entries=@entries.size
       
       # check for entries within the specified area
       if @num_entries==0 # no entries found        
          flash.now[:warning]="No observations were found within your specified criteria."
          return
       end # end check for existing entries
   
        # loop over results and add markers to map, showing different icon for your own observations
        for entry in @entries
            add_single_map_marker(@map,entry)  
             # get unique list of species in results
             @unique_organisms << [entry.organism.name,entry.organism.id] if @unique_organisms.include?([entry.organism.name,entry.organism.id])==false
             # get unique list of users in results
             @unique_users << [entry.user.fullname,entry.user.id] if @unique_users.include?([entry.user.fullname,entry.user.id])==false   
        end # end loop over entries
           
        @unique_organisms.sort!
        @unique_users.sort!
 
         # if rendering kml, then render it and return
       if kml != ""
            send_data(render(:template=>'web_service/kml.rxml',:layout=>false),:filename=>"observations.kml",:type => "application/vnd.google-earth.kml+xml")
           # return            
       end
    
  else
  
       @num_entries = 0
 
    end # end check for command string present
   

end

def view_observer
    
	# get this user
	@user=User.find(params[:id])
	
	# get the list of organisms for this user
	@organisms=@user.organisms
  
  @num_entries=@organisms.size
	
end

def view

  # get a google map around a specific observation
   @entry=Entry.find(params[:id],:include=>[:data_points,:images,:assets])        

   @map = create_map(@entry.lat.to_f,@entry.lon.to_f,12)
   @map.overlay_init(GMarker.new([@entry.lat.to_f,@entry.lon.to_f],:title => @entry.organism.name, :info_window => info_window_marker(@entry)))
   
 end

 
  # first observation page, collecting only the organism name
  def enter_species
 
    # check to see if this a web service call
    service=params[:service] || ""
    
    # check for page posted with observed organism
    if request.post? || service!=""
       
       # get form data
       organism_name=params[:organism][:name]
       
       # check to see if this is an existing known organism
       @organism=Organism.find_by_name(organism_name)
       
       if @organism == nil # organism was not found, so try to add it
         
         @organism = Organism.new
         @organism.name=organism_name
         
         # look up namebank ID if it exists
         @organism.namebank_id=Ubio::Services.get_namebank_ID(organism_name,:timeout_seconds=>10)
         
         if @organism.save == false # if we couldn't save it, re-render the form page to show errors
            
            if service=="" # if this is not a web service call get list of organisms observered by logged in user for display
              @your_organisms=get_user_species
              return
            else # this is a web service call, error returned
              web_service_response(nil)  
              return
            end # check for web service call
          
          end # end check for able to save organism
          
       end # end check for existing organism found
        
       if service=="" # check for web service call
         redirect_to(:action=>"record",:id=>@organism.id)  # redirect to next observation recording page if not coming from web service
       else
          web_service_response(@organism)
          return
       end # end check for web service call
 
    end # end check for page posted
   
    # get list of organisms observered by logged in user
    @your_organisms=get_user_species
    
  end

 
  # second observation page, used to enter in basic info about observation
  def record

    # check to see if this a web service call
    service=params[:service] || ""
 
    begin
      @organism = Organism.find(params[:id])
    rescue
      if service==""
        redirect_to(:action=>"enter_species")
        return
      else
        web_service_response(nil)   
        return 
      end
    end
    
    @map = create_map(0,0,1)
    @map.event_init(@map,:click,javascript_for_clicked_location(false))
  
    # check for page posted with observation data
    if request.post? || service!=""
       
       # get form data
       entry_form_data=params[:entry]
       image_data=params[:uploaded_data] || ""
       
       # store data in entry object
       @entry=Entry.create(entry_form_data)
       
       # associate it with organism and logged in user
       @entry.organism=@organism
       @entry.user=session[:user] 
       @entry.user_id=params[:user_id] if service!=""   
       
       if @entry.valid?  # check to see if the entry is valid
           
           @entry.temperature=convert_fahrenheit_to_celcius(@entry.temperature) if params[:temp_units]=="F" 
           
           # try to store uploaded image if available
             if image_data != ""
               @image = Image.new()
               @image.uploaded_data=image_data
               @image.user=session[:user]
               @image.entry=@entry
               return if @image.valid? == false  # if the image is not valid, go back to entry to show errors 
             end

            @entry.save
            @image.save if image_data != "" # save image if it's there
            
            # save attribute values if there is something in the session
            if session[:attribute_values] != nil
              session[:attribute_values].each do |values| # iterate over attribute value pairs
                
                # get them from the session
                attribute_value_name=values[0]
                data_entry_value=values[1] 
                
                store_data_point(attribute_value_name,data_entry_value,@entry.id)
                
               end # end loop over all attribute value pairs
            end # end check for attribute value pairs in session
 
            # save assets if there is something in the session
            if session[:assets] != nil
              session[:assets].each do |asset| # iterate over assets
                # store the new asset
                new_asset=Asset.new()
                new_asset.url=asset.url
                new_asset.description=asset.description
                new_asset.asset_type_id=asset.asset_type_id
                new_asset.entry=@entry
                new_asset.user=session[:user]
                new_asset.save
              end # end loop over all assets
            end # end check for assets in session

            # destroy session containing attribute values and assets
            clear_observation_sessions    
            
            flash[:notice]="Thank you! Your observation was recorded."
            if params[:another_entry]=="true"  && service==""
               # user requested to add another observation at this location
               session[:last_entry]=@entry
               redirect_to(:controller=>"observation",:action=>"enter_species") 
             elsif service==""
               session[:last_entry]=nil
               redirect_to(:controller=>"home",:action=>"index")          
             else
                web_service_response(@entry)  
                return      
            end

          end # end check for valid entry
    
    else # this is the first time on the page, be sure temp session starts out as blank
        
        clear_observation_sessions        
        if session[:last_entry]!=nil 
          @entry=session[:last_entry]  # use last entry values as default if we find it in the session        
        else # set default values
          @entry=Entry.new
          @entry.confidence_range=0
          @entry.number=1
          @entry.date=Time.now
          @entry.lat=""
          @entry.lon=""
          @entry.location=session[:user].address if session[:user] !=nil  #default to address of logged in user
        end
        
    end # end check for page posted
    
    if service!=""
        web_service_response(nil)   
        return
    end
 
end

##########################################################################
# Web service Calls
##########################################################################
  # web service method to enter an observation with an optional attribute all in one step
 
 def add_observation
  
    base_url=request.host
    base_url+=":"+request.port.to_s if request.port!=80

    service=params[:service] || ""

    user_id=params[:user_id]
    organism_name=params[:organism_name]
    entry=params[:entry]
    attribute_name=params[:attribute_name]
    attribute_value=params[:attribute_value]
    @response=nil
    begin
      
  
      if service != "" 
        # make web service call to get organism id
        resp=Net::HTTP.get_response(request.host,'/observation/enter_species?service=true&organism[name]=' + URI.escape(organism_name),request.port)
        xml_doc=REXML::Document.new(resp.body)
        organism_id=xml_doc.elements["//id"].text
        
        if organism_id !="" 
            @response=Organism.find(organism_id)  
            
            # make web service call to record observation
            resp=Net::HTTP.get_response(URI.parse(base_url+'/observation/record?service=true&id=' + organism_id + '&user_id=' + user_id + '&entry[habitat_id]=' + entry[:habitat_id]+ '&entry[lat]=' + entry[:lat] + '&entry[lon]=' + entry[:lon] + '&entry[location]=' + URI.escape(entry[:location]) + '&entry[date]=' + URI.escape(entry[:date]) + '&entry[description]=' + URI.escape(entry[:description])))
            xml_doc=REXML::Document.new(resp.body)
            entry_id=xml_doc.elements["//id"].text
      
            if attribute_name!="" && attribute_value!=""
              # make web service call to add attribute to observation
              resp=Net::HTTP.get_response(URI.parse(base_url+'/observation/add_data_point?service=true&entry_id=' + entry_id + '&attribute_name=' + URI.escape(attribute_name) + '&attribute_value=' + URI.escape(attribute_value)))
              xml_doc=REXML::Document.new(resp.body)
              data_point_id=xml_doc.elements["//id"].text      
            end 
       
       end
     
      end     
   
     # rescue 

     #   web_service_response(@nil)
     #   return

      end

      web_service_response(@response)
    
 end

  # web service call to get habitats
  def get_habitats
    service=params[:service] || ""
    if service != ""
      web_service_response(Habitat.all)
    end
  end

  # web service call to add data points
  def add_data_point
      begin
        service=params[:service] || ""
        if service != ""
          attribute_value_name=params[:attribute_name]
          data_entry_value=params[:attribute_value]
          entry_id=params[:entry_id]
          dp=store_data_point(attribute_value_name,data_entry_value,entry_id)
          web_service_response(dp)
        else
          web_service_response(nil)
        end
      rescue
          web_service_response(nil)  
      end
 
 end

##########################################################################
# Ajax only Methods
##########################################################################

# update icons on search results page to show only selected organisms and/or users based on querystring sent in
  def ajax_update_search_results 
    
    limit = params[:limit] || $DEFAULT_LIMIT
 
    range_unit = params[:range_unit] || "miles" 
    range=params[:range] || "0"       
    
    # get coords and location for search by location
    entry = params[:entry]
    if entry != nil 
      lat = entry[:lat]
      lon = entry[:lon]    
    end # end check for coordinates entered
       
    organism_ids=params[:organism_ids] || ""
    user_ids=params[:user_ids] || ""
    
    organism_ids.chomp!(",")
    user_ids.chomp!(",")

    conditions=""
    conditions += "organism_id in (#{organism_ids}) and " if organism_ids != ""
    conditions += "user_id in (#{user_ids}) and " if user_ids != ""
    conditions.chomp!(" and ")

     # next check to see if we have also have a location search
     if lat.to_f != 0 && lon.to_f != 0 && range.to_f != 0 # if we have entered a latitude, longitude
       commandstring="@entries=Entry.find_within(range,:origin=>[lat,lon],:units=>params[range_unit],:order=>:distance,:limit=>" + limit + ",:conditions=>'" + conditions + "')"
    else    
       commandstring="@entries=Entry.find(:all,:limit=>" + limit + ",:conditions=>'" + conditions + "')"
    end
    eval(commandstring)     
        
    render(:layout=>false)
    
  end
  
# get attribute value pair typed in by user and store in session temporarily until observation is saved
  def ajax_add_attribute
    
     data_point=params[:data_point] || ""
     attribute_value=params[:attribute_value] || ""
     
     if data_point[:value] !="" && attribute_value[:name] != "" 
       session[:attribute_values] ||= Array.new # start new session array to temporarily store the attribute values if it doesn't exit
       # we will store these in model objects if and when the observation is finally submitted
       
       # push new value onto the array
       session[:attribute_values] << [attribute_value[:name],data_point[:value]]
     end
     
      @response=session[:attribute_values] || ""
       
  end
 
   # get asset typed in by user and store in session temporarily until observation is saved
  def ajax_add_asset
    
     asset=params[:asset]
     
     if asset[:description] !="" && asset[:url] != "" 
       session[:assets] ||= Array.new # start new session array to temporarily store the assets if it doesn't exit
       # we will store these in model objects if and when the observation is finally submitted
       
       # push new asset object onto the array
       session[:assets] << Asset.new(asset)
     end
     
      @response=session[:assets] || ""
       
  end
  
 # get location typed by user and return latitude/longitude via rjs, or simply update map 
  def ajax_geocode_location
    
    # entered location
    service=params[:service] || ""

    location=params[:entry][:location]
    from_quick_jump=params[:from_quick_jump]
    
    @res = GeoKit::Geocoders::MultiGeocoder.geocode(location) if location != ""   
    @response_message=""

    if @res.nil? == false && @res.success == true
      @lat=@res.lat
      @lon=@res.lng
      @full_address=@res.full_address
      @zoom=8
    else
      @response_message="location not found" if @res.nil? == false 
      @lat=0
      @lon=0
      @zoom=1
    end

    # bind javascript variable map to google map, so we can update from the RJS template
    @map = Variable.new("map")
    
    # render :nothing=>true if @res.success==false # don't do anything if the address was not found
    
    if service!="" 
       if @res.nil?
         web_service_response(nil)
       else
         en=Entry.new
         en.lat=@lat
         en.lon=@lon
         web_service_response(en)
       end
    else
      # if we are coming from the google map quick jump and the address was geocoded, use special RJS template
      render :file=>"app/views/shared/ajax_map_quick_jump.rjs" if from_quick_jump=="true" 
    end
    
   end
  
  def ajax_update_map

   # entered lat/lon
    @lat=params[:entry][:lat]
    @lon=params[:entry][:lon] 
    @full_address=params[:entry][:location]
    @response_message=""
    
    # bind javascript variable map to google map, so we can update from the RJS template
    @map = Variable.new("map")
    
    render :file=>"app/views/observation/ajax_geocode_location.rjs"
    
  end


##########################################################################
# Private Methods
##########################################################################
   private
   def store_data_point(attribute_value_name,data_entry_value,entry_id)
        
        # store the new attribute value if its not there
        at=AttributeValue.find_by_name(attribute_value_name) 
        if at == nil # if it's not there, create it
          at=AttributeValue.new
          at.name=attribute_value_name
          at.save
        end
        
        # store the new data point
        dp=DataPoint.new
        dp.value=data_entry_value
        dp.attribute_value=at
        dp.entry_id=entry_id
        dp.save
        
        return dp

   end
   
  def get_zoom_range(range)
  
      # get zoom range for goole maps based on the search location range
      range_number=range.to_f
      
      if range_number < 2
        14
      elsif range_number < 10
        12
      elsif range_number < 50
        11
      elsif range_number <101
        10
      elsif range_number<201
        7
      elsif range_number<350
        5       
      elsif range_number<501
        3
      else
        1
      end
          
   end

   def clear_observation_sessions
        session[:attribute_values] = nil
        session[:assets] = nil
   end

   def get_user_species
     User.find(session[:user].id,:include=>:organisms).organisms.map {|o| [o.name, o.id]}
   end
end

