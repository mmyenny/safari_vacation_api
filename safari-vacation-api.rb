require 'sinatra'
require 'sinatra/json'
require 'sinatra/reloader' if development?
require 'active_record'
require 'rack/cors'

# Allow anyone to access our API via a browser
use Rack::Cors do |config|
  config.allow do |allow|
    allow.origins '*'
    allow.resource '*'
  end
end

ActiveRecord::Base.establish_connection(
  adapter: "postgresql",
  database: "safari_vacation"
)

class SeenAnimal < ActiveRecord::Base
end

#Create GET /Animals Endpoint that returns all animals you have seen
get '/Animals' do
  json SeenAnimal.all.order(:id)
end


#Create GET /Search?species=lion that returns all animals where the species name contains the title parameter
get '/Search' do
  species = params["species"]
  animals = SeenAnimal.where('species LIKE ?', "%#{species}%")

  json animals
end

#Create a POST /Animal endpoints that adds a movie to the database. This should take a JSON body
post '/Animal' do
  data = JSON.parse(request.body.read)

  animal_params = data["animal"]

  new_animal = SeenAnimal.create(animal_params)

  json animal: new_animal
end

#OR
# Create a `POST /Animal` endpoints that adds a animal to the database. This should take a JSON body
# JSON body looks like:
# {
#    "seen_animal": {
#      "species": "Duck",
#      "count_of_times_seen": 10,
#      "location_of_last_seen": "Kitchen"
#    }
# }
#post '/Animal' do
  # JSON.parse - Turn the string into an object. Take string that looks like JSON and turn it into a hash we can use
  # request.body.read - Reads the body of the request, that is where the API user will put their data (e.g. when you are in postman that is where you typed your JSON)
 # animal_json_object = JSON.parse(request.body.read)

  # Pass the hash we get back by accessing "seen_animal" to SeenAnimal.create which will make a new record in the database
  #animal_active_record_object = SeenAnimal.create(animal_json_object###["seen_animal"])

  # Make the repsonse the JSON version of that new record in the database
  #json animal_active_record_object
#end


# Create a `GET /Animal/{location}` that returns animals of only that location
get '/Animal/:location' do
  # Get the parameter from the URL


  # the variable matching_animals will be an array of SeenAnimal objects
  # but only those WHERE
  # -- the column "location_of_last_seen" matches *exactly* the value in the variable `the_location_the_user_wants`
  # -- which is the parameter from the URL
  json SeenAnimal.where(location_of_last_seen: params["location"])

end

# Create a `PUT /Animal/{id}` endpoint that adds 1 to the count of times seen for that animal
put '/Animal/:id' do
  # Find the first animal in the database where the column `species` exactly matches what is inside the variable `species`

  # new_count = found_animal.count_of_times_seen + 1

  # found_animal.update(count_of_times_seen: new_count)

  # json found_animal

  # Find the animal in the database with that id

  SeenAnimal.where(id: params["id"]).update_all("count_of_times_seen = count_of_times_seen + 1")

  found_animal = SeenAnimal.find(params["id"])

  json found_animal
end


# Create a `DELETE /Animal/{id}` endpoint that deletes that animal id from the database
delete '/Animal/:id' do
  found_animal = SeenAnimal.find(params["id"])

  found_animal.destroy

  json found_animal
end


