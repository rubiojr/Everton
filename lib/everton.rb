require 'rubygems'
require 'evernote'
require 'yaml'
require 'uri'

#
# Great example fetched Evernote Forum at:
# http://forum.evernote.com/phpbb/viewtopic.php?f=43&t=27547
#

module Evernote
  module EDAM
    module Type
      class NoteFilter
        include ::Thrift::Struct, ::Thrift::Struct_Union
        ORDER = 1
        ASCENDING = 2
        WORDS = 3 
        NOTEBOOKGUID = 4
        TAGGUIDS = 5
        TIMEZONE = 6
        INACTIVE = 7

        FIELDS = {
                    ORDER => {:type => ::Thrift::Types::I32, :name => 'order', :optional => true},
                    ASCENDING => {:type => ::Thrift::Types::BOOL, :name => 'ascending', :optional => true},
                    WORDS => {:type => ::Thrift::Types::STRING, :name => 'words', :optional => true},
                    NOTEBOOKGUID => {:type => ::Thrift::Types::STRING, :name => 'notebookGuid', :optional => true},
                    TAGGUIDS => {:type => ::Thrift::Types::LIST, :name => 'tagGuids', :optional => true, :enum_class => Evernote::EDAM::Type::PrivilegeLevel},
                    TIMEZONE => {:type => ::Thrift::Types::STRING, :name => 'timezone', :optional => true},
                    INACTIVE => {:type => ::Thrift::Types::BOOL, :name => 'active', :optional => true}
                  }

         def struct_fields; FIELDS; end

         def validate
         end

         ::Thrift::Struct.generate_accessors self
      end
    end
  end
end


module Everton

  VERSION = '0.1.1'

  class Remote
    
    class << self
      attr_reader :user_store, :note_store, :access_token
    end

    def self.authenticate config
      if config.is_a? Hash
        cfg = config
      else
        cfg = YAML.load_file config
      end
        @user_store = Evernote::UserStore.new(cfg[:user_store_url], cfg)
        auth_result = user_store.authenticate
        @user = auth_result.user
        @access_token = auth_result.authenticationToken
        uri = URI.parse cfg[:user_store_url]
        host = uri.host
        scheme = uri.scheme
        @note_store_url = "#{scheme}://#{host}/edam/note/#{@user.shardId}"
        @note_store = Evernote::NoteStore.new(@note_store_url)
    end
  end

  class ::Evernote::EDAM::Type::Notebook

    def add_note(title, text)
      note = Evernote::EDAM::Type::Note.new()
      note.title = title
      note.notebookGuid = self.guid
      note.content = '<?xml version="1.0" encoding="UTF-8"?>' +
                     '<!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd"><en-note>' +
                     text +
                     '</en-note>'
      Everton::Remote.note_store.createNote(Everton::Remote.access_token, note)
    end

    def add_image(title, text, filename)
      image = File.open(filename, "rb") { |io| io.read }
      hashFunc = Digest::MD5.new
      hashHex = hashFunc.hexdigest(image)

      data = Evernote::EDAM::Type::Data.new()
      data.size = image.size
      data.bodyHash = hashHex
      data.body = image

      resource = Evernote::EDAM::Type::Resource.new()
      resource.mime = "image/png"
      resource.data = data;
      resource.attributes = Evernote::EDAM::Type::ResourceAttributes.new()
      resource.attributes.fileName = filename

      note = Evernote::EDAM::Type::Note.new()
      note.title = title
      note.notebookGuid = self.guid
      note.content = '<?xml version="1.0" encoding="UTF-8"?>' +
          '<!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">' +
            '<en-note>' + text + 
              '<en-media type="image/png" hash="' + hashHex + '"/>' +
                '</en-note>'
      note.resources = [ resource ]

      Everton::Remote.note_store.createNote(Everton::Remote.access_token, note)

    end
    
    # See advanced search
    # http://www.evernote.com/about/kb/article/advanced-search?lang=en
    #
    # http://www.evernote.com/about/developer/api/ref/NoteStore.html#Struct_NoteFilter
    #
    # http://www.evernote.com/about/developer/api/ref/NoteStore.html#Fn_NoteStore_findNotes
    def find_notes(filter=nil, params = {})
      f = Evernote::EDAM::Type::NoteFilter.new()
      f.notebookGuid = self.guid
      f.words = filter if filter
      offset = params[:offset] || 0
      max_notes = params[:max_notes] || 20
      Everton::Remote.note_store.findNotes(Remote.access_token,f,offset,max_notes).notes
    end

  end

  class Notebook
    def self.all
      Remote.note_store.listNotebooks(Remote.access_token)
    end

    def self.find(name)
      all.each do |n|
        return n if n.name == name
      end
      nil
    end

  end

end


