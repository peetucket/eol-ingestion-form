module Ubio
           
    #Class for the manipulation of the API key and base URL
    
    class Config
      
      #Read the API key config for the current ENV
      unless File.exist?(RAILS_ROOT + '/config/ubio_key.yml')
        raise UbioKeyConfigFileNotFoundException.new("File RAILS_ROOT/config/ubio_key.yml not found")
      else
        env = ENV['RAILS_ENV'] || RAILS_ENV
        UBIO_KEY = YAML.load_file(RAILS_ROOT + '/config/ubio_key.yml')[env]
      end

      def self.get_base_url
      
        "http://www.ubio.org/webservices/"
        
      end
      
      def self.get_key(options = {})
        if options.has_key?(:key)
          options[:key]
        elsif UBIO_KEY.is_a?(Hash)
          #For this environment, multiple hosts are possible.
          #:host must have been passed as option
          if options.has_key?(:host)
            UBIO_KEY[options[:host]]
          else
            raise AmbiguousUbioKeyException.new(UBIO_KEY.keys.join(","))
          end
        else
          #Only one possible key: take it and ignore the :host option if it is there
          UBIO_KEY
        end
      end
      
    end

   class UbioKeyConfigFileNotFoundException < StandardError
   end
        
   class AmbiguousUbioKeyException < StandardError
   end
   
end
