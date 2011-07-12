# Everton #

Thin wrapper around Evernote ruby client library (https://github.com/cgs/evernote)

# Installing #

    gem install evertone

# Usage #

    require 'rubygems'
    require 'everton'
    
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
    Everton::Notebook.all.each do |n|
      puts n.name
    end
    
    # Get the first notebook
    notebook = Everton::Notebook.all.first
    
    # Get the notebook named 'bar'
    bar_notebook = Everton::Notebook.find('bar')
    
    # Add image to notebook 'bar'
    bar_notebook.add_image 'note title', 'note content', '/home/rubiojr/Desktop/guns.jpg'
    
    # Add a text note
    bar_notebook.add_note 'note title', 'anothe note, only text'


# Copyright #

Copyright (c) 2011 Sergio Rubio. See LICENSE.txt for
further details.

