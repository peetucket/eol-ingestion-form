# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
   def show_messages
    
    # this will render out any messages in the flash into the "messageContainer" div, which can be styled using CSS
    
    if flash[:notice] || flash[:warning] || flash[:message]
        for name in [:warning, :notice, :message]
          resultHTML=render_message(name,flash[name]) if flash[name] != nil 
      end
    end
    
    flash.discard
    
    return resultHTML
    
  end
  
  def required_field_message
    "Fields in <span class=""form_fields_required"">blue</span> are required."
  end
  
 
  def render_message(name,message)
    
     resultHTML=""
     resultHTML+= "<div id=\"messagecontainer\">"
     resultHTML+= "<div id=\"#{name}\"><img src=\"/images/#{name}.gif\" alt=\"icon\"/>&nbsp;&nbsp;#{message}</div>"
     resultHTML+= "</div>"
    
  end


end
