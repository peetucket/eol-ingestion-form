# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_eol_session_id'

  # these methods are also available as helpers for the views
  helper_method :format_date_for_kml, :format_date, :format_date_time, :format_short_date, :info_window_marker, :convert_fahrenheit_to_celcius, :convert_celcius_to_fahrenheit, :formatLatLonDecimalAsDegrees  
   
  # catch all uncaught errors and log them
  def rescue_action_in_public(exception)
         SystemNotifier.deliver_exception_notification(self,request,exception) 
         redirect_to(:controller=>'home',:action=>'error')
  end
 
   # set up the google map for the page
   def create_map(lat,lon,zoom)
    map = GMap.new("map")
    map.control_init(:small_map=>true,:map_type=>true)
    map.center_zoom_init([lat,lon],zoom) # 1 is the zoom level, center on the center of the world
    setup_map_icons(map)
    map
  end
  
  def javascript_for_clicked_location(update_location)
    
    js_function="function (overlay,point) {"
    js_function+=" $('entry_lat').value=point.y;"
    js_function+=" $('entry_lon').value=point.x;"
    js_function+=" $('entry_location').value=point.y + ', ' + point.x;" if update_location
    js_function+="updateLatLonDegrees(); }"
    return js_function
    
  end
  
  # set up custom icons for the google map
  def setup_map_icons(map)
      map.icon_global_init(GIcon.new(:image => "/images/center_icon.png", :icon_size => GSize.new(32,32),:icon_anchor => GPoint.new(16,32),:info_window_anchor => GPoint.new(16,0)),"map_center")
      map.icon_global_init(GIcon.new(:image => "/images/your_icon.png", :icon_size => GSize.new(32,32),:icon_anchor => GPoint.new(16,32),:info_window_anchor => GPoint.new(16,0)),"your_icon")
      map.icon_global_init(GIcon.new(:image => "/images/other_icon.png", :icon_size => GSize.new(32,32),:icon_anchor => GPoint.new(16,32),:info_window_anchor => GPoint.new(16,0)),"other_icon")

      # special hardcoded icon colors for neil's imported data
      #map.icon_global_init(GIcon.new(:image => "http://www.google.com/mapfiles/markerA.png", :icon_size => GSize.new(20,34),:icon_anchor => GPoint.new(10,34),:info_window_anchor => GPoint.new(10,0)),"GBIF")
      #map.icon_global_init(GIcon.new(:image => "http://www.google.com/mapfiles/markerB.png", :icon_size => GSize.new(20,34),:icon_anchor => GPoint.new(10,34),:info_window_anchor => GPoint.new(10,0)),"ProMED")
      #map.icon_global_init(GIcon.new(:image => "http://www.google.com/mapfiles/markerC.png", :icon_size => GSize.new(20,34),:icon_anchor => GPoint.new(10,34),:info_window_anchor => GPoint.new(10,0)),"whoEPR")
      #map.icon_global_init(GIcon.new(:image => "http://www.google.com/mapfiles/markerD.png", :icon_size => GSize.new(20,34),:icon_anchor => GPoint.new(10,34),:info_window_anchor => GPoint.new(10,0)),"NCBI")

  end
  
  # add the marker to the google map based on the entry provided
  def add_single_map_marker(map,entry)
    
      icon_name="your_icon"
      icon_name="other_icon" if session[:user]==nil || (session[:user]!=nil && session[:user]!=entry.user)

      # special harccoded icon colors for neil's imported data
     # case entry.user.id
     #   when 4: icon_name="ProMED"   
     #   when 5: icon_name="whoEPR"
     #   when 6: icon_name="GBIF"
     #   when 10: icon_name="NCBI" 
     # end

      marker=GMarker.new([entry.lat.to_f,entry.lon.to_f],:icon=>icon_name.intern,:title => entry.organism.name, :info_window => info_window_marker(entry))
      map.overlay_init(marker)

  end
 
 
  # return HTML to be displayed in info marker on map for given entry
  def info_window_marker(entry,sanitize=false)
    organism_name=entry.organism.name
    organism_name.gsub!('"','\'')
    entry_html='<table width=50% border="0">'
    entry_html += '<tr><td><strong>' + organism_name + '</strong>'
    entry_html += ' (' + entry.number.to_s + ')' if entry.number > 1
    entry_html += '<br/>' + entry.displayed_location + '<br/>' + entry.user.fullname + '<br/>' + format_date(entry.date) + "</td>"
    entry_html += '<td><img src="' + entry.images[0].public_filename(:thumb) + '"></td>' if entry.images.count==1  
    entry_html += "</tr></table>"
    entry_html.gsub!('"','\"') if sanitize==true
    entry_html
    
  end
  
  def go_to_login
       session[:return_to] = request.request_uri
       flash[:notice]="Please login to continue."
       redirect_to :controller=>'user', :action => 'login'
  end
 
 def check_authentication
    
      go_to_login unless session[:user] || params[:service]
    
  end
       
  def check_authentication_admin
       # user needs to be an admin to use this controller
      go_to_login unless session[:user]
       if session[:user] != nil
        go_to_login if session[:user].admin == false 
      end
  end
   
 # call via AJAX autocomplete for attribute value names
 def get_attribute_value_names
      @attribute_values = AttributeValue.find(:all,:limit=>20,:order=>:name,:conditions=>["name LIKE ?",params[:attribute_value][:name] +"%"])
      render(:template=>"shared/get_attribute_value_names",:layout=>false)  
 end
 
 # call via AJAX autocomplete for data point values for a given attribute value
 def get_data_point_values
      # look up the attribute value and find its possible data points for athe autocomplete
      data_point_value=params[:data_point_value]
      if params[:attribute_value_name] != ""
        attribute_value=AttributeValue.find_by_name(params[:attribute_value_name])
        if attribute_value != nil 
          @data_points = DataPoint.find(:all,:limit=>20,:order=>:value,:conditions=>["attribute_value_id = ? AND value LIKE ?",attribute_value.id,data_point_value +"%"])
          render(:template=>"shared/get_data_point_values",:layout=>false)  
          return
        end
      end
      render(:nothing=>true)
 end
 
 # call via AJAX autocomplete for organism names
  def get_organism_names
      @organisms = Organism.find(:all,:limit=>20,:order=>:name,:conditions=>["name LIKE ?",params[:organism][:name] + "%"])
      render(:template=>"shared/get_organism_names",:layout=>false)
   end

 # call via AJAX autocomplete for organism names from namebank
  def get_namebank_names
    @organisms = Ubio::Services.ajax_namebank_search(params[:organism][:name],:limit=>20)
    render(:template=>"shared/get_namebank_names",:layout=>false)
  end

 # call via AJAX autocomplete for observer names
  def get_observer_names
      @users = User.find(:all,:limit=>20,:order=>:fullname,:conditions=>["fullname LIKE ?",params[:user][:name] +"%"])
      render(:template=>"shared/get_observer_names",:layout=>false)
 end
 
 def web_service_response(obj)
      @web_service_response=obj
      render :template=>'web_service/response.rxml',:layout=>false  
 end

  def convert_celcius_to_fahrenheit(temp)
    return "" if temp.nil?
    return ((9/5.0)*temp.to_f)+32.0
  end
 
  def convert_fahrenheit_to_celcius(temp)
    return "" if temp.nil?    
    return (5/9.0)*(temp.to_f-32.0)
  end
  
 # special formatters 
     def format_date_time(inTime)
        inTime.strftime("%A, %B %d, %Y - %I:%M %p %Z") unless inTime==nil
    end
  
    def format_date(inDate)
        inDate.strftime("%A, %B %d, %Y") unless inDate==nil
    end
    
    def format_short_date(inDate)
        inDate.strftime("%m/%d/%y") unless inDate==nil     
    end

    def format_date_for_kml(inDate)
        inDate.strftime("%y-%m-%d") unless inDate==nil
    end
   
 def formatLatLonDecimalAsDegrees(range,units,lat,lon)

    returnString=""
    lat=lat.to_f
    lon=lon.to_f
    
    if range > 0 then
      returnString += "within "+ range.to_s + " " + units + " of "
    end
    
    if lat < 0
      returnString += "S "
    else
      returnString += "N "
    end
           
    lat = lat.abs
    latdeg = lat.floor
    latmin = ((lat-latdeg)*60.0).floor
    latsec =  (((((lat - latdeg) - (latmin/60.0)) * 60.0 * 60.0) * 100.0) / 100.0 ).round
    returnString += latdeg.to_s + "&deg; " + latmin.to_s + "' " + latsec.to_s + "'' "

    returnString += ", "

    if lon < 0
      returnString += "W "
    else
      returnString += "E "
    end

    lon = lon.abs
    londeg = lon.floor
    lonmin = ((lon-londeg)*60.0).floor
    lonsec = (((((lon - londeg) - (lonmin / 60.0 )) * 60.0 * 60.0) * 100.0 ) / 100.0).round
    returnString += londeg.to_s + "&deg; " + lonmin.to_s + "' " + lonsec.to_s + "'' "
  
    returnString
    
    
  end
  
end
