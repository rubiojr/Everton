require 'lib/everton'

config = {
  :username => 'myuser',
  :password => 'mypass',
  :consumer_key => 'key',
  :consumer_secret => 'secret',
  :user_store_url => 'http://sandbox.evernote.com/edam/user'
}

Everton::Remote.authenticate config

# Add text note to notebook 'bar'
Everton::Notebook.find('bar').add_note 'note title', 'note text'
