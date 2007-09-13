Data Ingestion From Web Services
August 15, 2007
Peter Mangiafico

base_url for all webservices is the default URL for your website
replace in all urls below

All web services are REST type, with GETs or POSTs to specified URLs and querystring parameters

To enter an observation requires several steps:
1. First you need a user id with which to associate the observation.
2. Next you need an organism id with which to associate the observation.
3. Next you need a habitat id with which to associate the observation.
4. Then you can send the observation once you have the required data.
5. Finally you can add an attribute/value pair to the observation you just entered.

####################################
Step 1: You need a valid user id in the system.  First determine the user id by passing a username/password combo.

URL: 
base_url/user/login?service=true&email=EMAIL ADDRESS&password=PASSWORD

Parameters Required:

service = true
email = email address to lookup
password = password to lookup

Returned object is a "user" XML document, with the key nodes being:

ID - the system ID for this user

To call this service from Ruby and parse the results, use this example:

####
# start common code for all web service calls
require 'net/http'
require 'uri'
require 'rexml/document'
base_url='http://localhost:3000'
# end common code for all web service calls
####

email='test@test.com'
password='test'
resp=Net::HTTP.get_response(URI.parse(base_url+'/user/login?service=true&email=' + URI.escape(email) + '&password=' + URI.escape(password)))
xml_doc=REXML::Document.new(resp.body)

user_id=xml_doc.elements["//id"].text
#####################################


####################################
Step 2: To enter a new species, and/or determine it's ID/namebank ID within the system.

URL:
base_url/observation/enter_species?service=true&organism[name]=NAME OF ORGANISM

Parameters Required:
service = true
organism_name = organism name to lookup and/or create

Returned object is an "organism" XML document, with the key nodes being:

ID - the system ID of this organism, automatically created if the organism did not exist yet
namebank-id - the namebankID of the organism, if found

To call this service from Ruby and parse the results, use this example:

# insert the common code from step 1 above

organism_name='Aotus'
resp=Net::HTTP.get_response(URI.parse(base_url+'/observation/enter_species?service=true&organism[name]=' + URI.escape(organism_name)))
xml_doc=REXML::Document.new(resp.body)

organism_id=xml_doc.elements["//id"].text
namebank_id=xml_doc.elements["//namebank-id"]
#####################################

####################################
Step 3: To see the list of possible habitats and habitat IDs, call this web service.

URL
base_url/observation/get_habitats?service=true

Parameters Required:
service = true

Returned object is a "habitat" XML document, with the key nodes being:

ID - the system ID of the habitat
name - the name of the habitat

To call this service from Ruby and parse the results, use this example:

# insert the common code from step 1 above

resp=Net::HTTP.get_response(URI.parse(base_url+'/observation/get_habitats?service=true'))
xml_doc=REXML::Document.new(resp.body)

xml_doc.elements.each("//habitat") {|habitat| puts habitat.elements['id'].text + '=' + habitat.elements['name'].text}
#####################################

####################################
Step 4: To enter an observation.

URL: 
base_url/observation/record?service=true&id=ORGANISM ID&user_id=USER ID&entry[habitat_id]=HABITAT ID&entry[lat]=LATITUDE&entry[lon]=LONGITUDE&entry[location]=LOCATION STRING&entry[date]=DATE/TIME&entry[description]=DESCRIPTION TEXT

Parameters Required:
service = true
user_id = user id (from step 1)
id = organism id (from step 2)
entry[habitat_id] = habitat id (from step 3)
entry[lat] = latitude  (-90 to 90)
entry[lon] = longitude (-180 to 180)
entry[location] = location string
entry[date] = date/time value (yyyy-mm-dd hh:mm:ss)
entry[description] = description string

Returned object is an "entry" XML document.

To call this service from Ruby and parse the results, use this example:

# insert the common code from step 1 above

organism_id='1'
user_id='1'
habitat_id='1'
lat='41.523'
lon='-70.668'
location='Woods Hole'
date='2007-8-8 12:23:00'
description='Description goes here'

resp=Net::HTTP.get_response(URI.parse(base_url+'/observation/record?service=true&id=' + organism_id + '&user_id=' + user_id + '&entry[habitat_id]=' + habitat_id + '&entry[lat]=' + lat + '&entry[lon]=' + lon + '&entry[location]=' + URI.escape(location) + '&entry[date]=' + URI.escape(date) + '&entry[description]=' + URI.escape(description)))
xml_doc=REXML::Document.new(resp.body)

entry_id=xml_doc.elements["//id"].text
#####################################

####################################
Step 5: To add an attribute to an existing observation.

URL: 
base_url/observation/record?service=true&entry_id=OBSERVATION ID ID&attribute_name=ATTRIBUTE NAME&attribute_value=ATTRIBUTE VALUE

Parameters Required:
service = true
entry_id = entry id (from step 4)
attribute_name = name of attribute
attribute_value = value of attribute

Returned object is an "data point" XML document.

To call this service from Ruby and parse the results, use this example:

# insert the common code from step 1 above

entry_id='1'
attribute_name='color'
attribute_value='green'

resp=Net::HTTP.get_response(URI.parse(base_url+'/observation/add_data_point?service=true&entry_id=' + entry_id + '&attribute_name=' + URI.escape(attribute_name) + '&attribute_value=' + URI.escape(attribute_value)))
xml_doc=REXML::Document.new(resp.body)

data_point_id=xml_doc.elements["//id"].text
#####################################


#####################################
Putting it all together

The example below shows how you can add an full observation with an attribute.  Note that
the email and password combo must be active in the system for anything else to work.

# common setup code
require 'net/http'
require 'uri'
require 'rexml/document'
base_url='http://localhost:3000'

# user parameters
email='test@test.com'
password='test'

# organism name
organism_name='Aotus'

# habitat
habitat_id='1'

# observation data
lat='41.523'
lon='-70.668'
location='Woods Hole'
date='2007-8-8 12:23:00'
description='Description goes here'

# attribute to add to observation
attribute_name='color'
attribute_value='green'

# make web service call to get user ID
resp=Net::HTTP.get_response(URI.parse(base_url+'/user/login?service=true&email=' + URI.escape(email) + '&password=' + URI.escape(password)))
xml_doc=REXML::Document.new(resp.body)
user_id=xml_doc.elements["//id"].text

# make web service call to get organism id
resp=Net::HTTP.get_response(URI.parse(base_url+'/observation/enter_species?service=true&organism[name]=' + URI.escape(organism_name)))
xml_doc=REXML::Document.new(resp.body)
organism_id=xml_doc.elements["//id"].text

# make web service call to record observation
resp=Net::HTTP.get_response(URI.parse(base_url+'/observation/record?service=true&id=' + organism_id + '&user_id=' + user_id + '&entry[habitat_id]=' + habitat_id + '&entry[lat]=' + lat + '&entry[lon]=' + lon + '&entry[location]=' + URI.escape(location) + '&entry[date]=' + URI.escape(date) + '&entry[description]=' + URI.escape(description)))
xml_doc=REXML::Document.new(resp.body)
entry_id=xml_doc.elements["//id"].text

# make web service call to add attribute to observation
resp=Net::HTTP.get_response(URI.parse(base_url+'/observation/add_data_point?service=true&entry_id=' + entry_id + '&attribute_name=' + URI.escape(attribute_name) + '&attribute_value=' + URI.escape(attribute_value)))
xml_doc=REXML::Document.new(resp.body)
data_point_id=xml_doc.elements["//id"].text

### note that once you have the user id and organism ID, you can simply add observations for the
###    same organism over and over again as neeed using the IDs you already have
