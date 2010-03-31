require 'net/http'
require 'uri'
require 'open-uri'
require 'digest/sha1'
require 'tmpdir'

TWITTER = {:user     => 'username',
           :password => 'password',
           :to       => 'you'}

def post(url, user=nil, password=nil, args={})
  url = URI.parse(url)
  req = Net::HTTP::Post.new(url.path)
  req.basic_auth user, password if user && password 
  req.set_form_data(args) unless args.empty?
  Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }
end

def send_notification(url)
  message = "#{url} was updated at #{Time.now}."
  post("http://twitter.com/direct_messages/new.json",
       TWITTER[:user], TWITTER[:password],
       'text' => message, 'user' => TWITTER[:to])
end

url = ARGV.shift
filename = File.join(Dir.tmpdir, "#{Digest::SHA1.hexdigest(url)}.hash")
last_digest = File.read(filename) rescue nil

open(url) do |fd|
  digest = Digest::SHA1.hexdigest(fd.read)
  unless digest == last_digest
    send_notification(url) 
    File.open(filename, 'w+') {|f| f.write(digest)}
  end
end
