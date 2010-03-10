#!/usr/bin/env ruby
# == Synopsis
#
# Transforms a given NNTP newsgroup into an atom feed.
#
# == Usage
#
# nntp2atom.rb NNTPSERVER GROUPNAME
require 'rdoc/usage'
require 'rubygems'
gem 'nntp'
require 'nntp'
gem 'builder'
require 'builder'
require 'date'

unless (ARGV & %w{-h --help}).empty?
  RDoc::usage 
  exit(-1)
end

server = ARGV.shift
group = ARGV.shift
updated = DateTime.civil(1970)

messages = []

Net::NNTP.start(server, 119) do |nntp|
  message_ids = nntp.listgroup(group)
  nntp.group(group)
  message_ids.last[-10..-1].each do |message_id|
    message = {:id => message_id}
    nntp.head(message_id).each do |header|
      header.each do |line| 
        if line.index('Subject:') 
          message[:subject] = line.split(': ').last
        end
        if line.index('Date:') 
          message[:date] = DateTime.parse(line.split(': ').last)
          updated = message[:date] if message[:date] > updated
        end
        if line =~ /^From: /
          from = line.split(': ').last
          match = from.match(/(.+) <(.+)@(.+)>/)
          message[:author] = match[1] rescue (p line)
          message[:email] = "#{match[2]}@#{match[3]}"
        end
      end
    end    
    message[:body] = nntp.body(message_id).join("\n")
    messages << message
  end
end

xmlstr = ''
atom_feed = Builder::XmlMarkup.new(:target => xmlstr)
atom_feed.feed(:xmlns => 'http://www.w3.org/2005/Atom') do |feed|
  feed.title("Newsgroup #{server} #{group}")
  feed.updated(updated.strftime("%Y-%m-%dT%H:%M:%SZ"))
  uri = "nntp://#{server}/#{group}"
  feed.link(:href => uri)
  feed.id(uri)

  for message in messages
    feed.entry do |entry|
      uri = "nntp://#{server}/#{group}/#{message[:id]}"
      entry.link(:href => uri)
      entry.id(uri)
      entry.title(message[:subject])
      entry.summary(message[:body], :type => 'text')      
      entry.updated(message[:date].strftime("%Y-%m-%dT%H:%M:%SZ")) # needed to work with Google Reader.
      entry.published(message[:date].strftime("%Y-%m-%dT%H:%M:%SZ")) 
      entry.author do |author|
        author.name(message[:author])
        author.email(message[:email])        
      end
    end
  end
end

puts xmlstr