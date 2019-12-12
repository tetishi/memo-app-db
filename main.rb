require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'rack/contrib'
require 'pg'

class Note
  attr_reader :id, :title, :content

  def initialize(id:, title:, content:)
    @id = id || SecureRandom.uuid
    @title = title
    @content = content
  end

  class << self
    def db_connection
      result = PG::connect(dbname: "notes_data")
    end

    def select_all
      db_connection.exec("SELECT * FROM notes;")
    end

    def find_id(id:)
      note = nil
      @note = db_connection.exec("SELECT * FROM notes WHERE id = '#{id}'")
      @note.each do |row|
        note = Note.new(id: row["id"], title: row["title"], content: row["content"])
      end
      note
    end

    def new_note(id: nil, title:, content:)
      note = Note.new(id: id, title: title, content: content)
      db_connection.exec("INSERT INTO notes VALUES('#{note.id}', '#{note.title}', '#{note.content}');")
    end

    def delete_note(id:)
      db_connection.exec("DELETE FROM notes WHERE id = '#{id}';")
    end

    def edit_note(id:, title:, content:)
      db_connection.exec("UPDATE notes SET title = '#{title}', content = '#{content}' WHERE id = '#{id}';")
    end
  end
end

get "/" do
  @notes = Note.select_all
  erb :index
end

get "/new" do
  erb :new
end

get "/note/:id" do |id|
  @note = Note.find_id(id: params[:id])
  erb :show
end

post "/create" do
  if params[:title].match(/\A\R|\A\z/)
    @note = Note.new_note(id: params[:id], title: "新規メモ", content: params[:content])
  else
    @note = Note.new_note(id: params[:id], title: params[:title], content: params[:content])
  end
    redirect '/'
    erb :index
end

delete '/note/:id' do |id|
  Note.delete_note(id: params[:id])
  redirect '/'
  erb :index
end

get '/note/edit/:id' do |id|
  @note = Note.find_id(id: params[:id])
  erb :edit
end

patch '/note/update/:id' do |id|
  Note.edit_note(id: params[:id], title: params[:title], content: params[:content])
  redirect '/'
  erb :index
end
