require 'sinatra'
require 'sinatra/reloader'
# require 'active_record'
require 'json'

require 'rack/contrib'

# require "rubygems"
# require "bundler/setup"



# ActiveRecord::Base.establish_connection(
#     "adapter" => "sqlite3",
#     "database" => "./bbs.db"
# )

# class Comment < ActiveRecord::Base
# end


# global variable

$json = 'json/note.json'
$json_info = open($json) do |file|  # open json file and read each of them
    JSON.load(file)
end
# get notes array json data
$notes = $json_info['notes']


# method

# return the note related with the id
def note(note_id)
    i = ""
    $notes.each do |note|
        if note['id'].to_s == note_id.to_s
            i = note
            break
        # else   # delete this else statement
        #     i = "no"
        end
    end
    return i
end

# rewrite the json_data
def update_json
    File.open("json/note.json", 'w') do |file|    
        JSON.dump($json_info, file) # write to json file
    end
end




#main page
get "/" do
    @notes = $notes
    erb :index
end

# adding new notes
get "/add" do
    erb :new
end

# contents of notes
get "/note/:id" do |n|
    @note = note(n)
    erb :show
end





# creating process
post "/new" do

    if !params[:title].match(/\A\R|\A\z/)   # as long as the user write title


      # creating id for new_note
      initialized_id = 0
      $notes.each do |note|
        if initialized_id <= note['id'].to_i  # if the value on the left is less than the value on the right
            initialized_id = note['id'].to_i + 1    # new id will be the latest id + 1
        end
      end

      # create new json data with appended new note
      added_note = {"id" => initialized_id.to_s, "title" => params[:title], "content" => params[:content]}
      $json_info['notes'].push(added_note)     # append new note at the end ot json file

      update_json
    end

    redirect '/'
    erb :index

end


# deleting process
delete '/note/delete/:id' do |n|
    count = 0
    $notes.each do |note|
        if note['id'].to_s == n.to_s
            $json_info["notes"].delete_at(count)
            break
        end
        count += 1
    end

    update_json

    redirect '/'
    erb :index
end


get '/note/edit/:id' do |n|
    @note = note(n)
    erb :edit
end


# editing process
patch '/note/edit2/:id' do
    added_note = {"id" => params[:id].to_s, "title" => params[:title], "content" => params[:content]}

    # creating edited notes
    count = 0
    $notes.each do |note|
        if note['id'].to_s == params[:id].to_s
            $json_info["notes"][count]["title"] = added_note["title"]
            $json_info["notes"][count]["content"] = added_note["content"]
            break
        end
        count += 1
    end

    update_json

    redirect '/'
    erb :index
end




# get "/" do
#     @comments = Comment.order("id desc").all
#     erb :index
# end

# post "/new" do
#     Comment.create({:body => params[:body]})
#     redirect '/'
#     erb :index
# end

# delete "/delete" do
#     Comment.find(params[:id]).destroy
#     # redirect '/'
#     # erb :index
# end

# helpers do
#     include Rack::Utils
#     alias_method :h,:escape_html
# end



# get "/host" do  # this way you'll know if this is working http://localhost4567/host
#     "hello"
# end