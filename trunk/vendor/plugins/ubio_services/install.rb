require 'fileutils'

#copy the key file
ubio_config = File.dirname(__FILE__) + '/../../../config/ubio_key.yml'
unless File.exist?(ubio_config)
  FileUtils.copy(File.dirname(__FILE__) + '/ubio_key.yml.sample',ubio_config)
end
