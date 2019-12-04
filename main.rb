require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'rack/contrib'

$json = 'json/note.json'
$json_info = open($json) do |file|
  JSON.load(file)
end

$notes = $json_info['notes']

def note(note_id)
  i = ""
  $notes.each do |note|
    if note['id'].to_s == note_id.to_s
      i = note
      break
    end
  end
  return i
end

def update_json
  File.open("json/note.json", 'w') do |file|    
    JSON.dump($json_info, file)
  end
end

get "/" do
  @notes = $notes
  erb :index
end

get "/add" do
  erb :new
end

get "/note/:id" do |n|
  @note = note(n)
  erb :show
end

post "/new" do
  if !params[:title].match(/\A\R|\A\z/)
    initialized_id = 0
    $notes.each do |note|
      if initialized_id <= note['id'].to_i
        initialized_id = note['id'].to_i + 1
      end
    end
    added_note = {"id" => initialized_id.to_s, "title" => params[:title], "content" => params[:content]}
    $json_info['notes'].push(added_note)
    update_json
  end
  redirect '/'
  erb :index
end

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

patch '/note/edit2/:id' do
  added_note = {"id" => params[:id].to_s, "title" => params[:title], "content" => params[:content]}
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