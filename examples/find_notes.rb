require 'lib/everton'

config = {
  :username => 'myuser',
  :password => 'mypass',
  :consumer_key => 'key',
  :consumer_secret => 'secret',
  :user_store_url => 'http://sandbox.evernote.com/edam/user'
}

# Authenticate
Everton::Remote.authenticate config


# Iterate over all the netbooks and print the notebook name
n = Everton::Notebook.all.first

# Find the first 20 notes in notebook n
n.find_notes.each do |note|
  puts note.title
end

# Find a note in notebook n using filter
# See http://www.evernote.com/about/kb/article/advanced-search?lang=en
n.find_notes('intitle:Aspirations').each do |note|
  puts note.title
end



