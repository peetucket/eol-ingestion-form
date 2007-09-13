# UbioServices
require 'uri'
require 'net/http'
require 'timeout'

module Ubio
    
    class Services
      
      # get all namebank names containing a given search term, combined vernacular and scientific, return an 2-d array
      def self.namebank_search(search_term,params="")
        
        timeout_seconds = params[:timeout_seconds] || 2
        limit = params[:limit] || 10
        qualifier = params[:qualifier] || "contains"
        scope = params[:scope] || "all"
        
        base_url=Ubio::Config.get_base_url + "service_internal.php?version=2.0&keyCode=" + Ubio::Config.get_key + "&function=namebank_search&max=" + limit.to_s + "&scope=" + scope + "&qualifier=" + qualifier + "&search=" + URI.escape(search_term)
 
        result_array=Array.new
 
        # only give the call a predetermined time to execute, otherwise just return blank value       
        begin
          begin
            response=Timeout::timeout(timeout_seconds) {Net::HTTP.get_response(URI.parse(base_url))}
          rescue TimeoutError 
            return result_array
          end
        rescue
          return result_array        
        end
        
        if response.code == "200" # HTML response from webservice is OK
      
          xml_document=REXML::Document.new(response.body)
          
          xml_document.elements.each("/results/scientificNames/value") do |node|
            
            result_array<<[node.elements['nameString'].text,node.elements['namebankID'].text]
            
          end # end loop over scientific names

          xml_document.elements.each("/results/vernacularNames/value") do |node|
            
            result_array<<[node.elements['nameString'].text,node.elements['namebankID'].text]
            
          end # end loop over vernacular names
          
          result_array=result_array.sort          
          
        end # end check for correct HTML response code
        
        return result_array
        
      end # end namebank_search function

      # return a single namebank ID value for a given search term (exact match required)
     def self.get_namebank_ID(search_term,params="")
 
        timeout_seconds = params[:timeout_seconds] || 1
        
        base_url=Ubio::Config.get_base_url + "service_internal.php?version=2.0&keyCode=" + Ubio::Config.get_key + "&function=namebank_search&qualifier=equals&search=" + URI.escape(search_term)
        result=""
        
       # only give the call a predetermined time to execute, otherwise just return blank value       
       begin
         begin
          response=Timeout::timeout(timeout_seconds) {response=Net::HTTP.get_response(URI.parse(base_url))}
           rescue TimeoutError 
            return result
          end
        rescue
          return result_array        
        end    
        
        if response.code == "200" # HTML response from webservice is OK
      
          xml_document=REXML::Document.new(response.body)
          
          node = xml_document.elements["//namebankID"] # get single namebank ID returned
          
          result=node.text unless node==nil
                              
        end # end check for correct HTML response code
        
        return result     
       
     end # end exact namebank search to return an ID
     
     # get namebank names and IDs for an ajax autocomplete call, return an 2-d array
     def self.ajax_namebank_search(search_term,params="")
  
        timeout_seconds = params[:timeout_seconds] || 1
        limit = params[:limit] || 10
        
        base_url=Ubio::Config.get_base_url + "ajax_search.php?keyCode=" + Ubio::Config.get_key + "&search=" + URI.escape(search_term) + "&limit=" + limit.to_s
 
        result_array=Array.new
                
        # only give the call a predetermined time to execute, otherwise just return blank value       
        begin
          begin
            response=Timeout::timeout(timeout_seconds) {response=Net::HTTP.get_response(URI.parse(base_url))}
          rescue TimeoutError 
            return result_array
          end
        rescue
          return result_array        
        end 
        
        if response.code == "200" # HTML response from webservice is OK
      
          xml_document=REXML::Document.new(response.body)
          
          xml_document.elements.each("/results/value") do |node|
            
            result_array<<[node.elements['nameString'].text,node.elements['namebankID'].text]
            
          end # end loop names
          
          return result_array         
          
        end # end check for correct HTML response code
        
        return result_array
        
      end # end ajax_namebank_search function
      
      def self.ping(timeout_seconds=1)

        base_url=Ubio::Config.get_base_url + "ping.php?keyCode=" + Ubio::Config.get_key
        
        # only give the call a predetermined time to execute, otherwise just return blank value       
        begin
          begin
            response=Timeout::timeout(timeout_seconds) {response=Net::HTTP.get_response(URI.parse(base_url))}
          rescue TimeoutError 
            return false
          end
        rescue
          return result_array        
        end
        
         if response.code == "200"  # result code 200 is a good response
           true
         else
           false
         end 
        
        end # end ping call
     
    end # end services class

end # end uBio module
  
