require 'fileutils'

ubio_config = File.dirname(__FILE__) + '/../../../config/ubio_key.yml'
if File.exist?(ubio_config)
  FileUtils.delete(ubio_config)
end