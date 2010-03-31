mini-scripts
=====

A small collection of useful scripts and mini-tools I use from day to day

nntp2atom.rb
----------

Ruby script that turns the last 15 postings NNTP-Newsgroup into an Atom feed. 

Requires:

 - ruby >= 1.8.6
 - gems
    - builder
    - nntp

site_watcher.rb
----------
Ruby script that should be run periodically (via cron, etc.) and checks weather the contents of a web page changed. It saves a hash of the content in your systems /tmp. It does not rely on If-Modified-Since because of all of badly configured web-servers out there. 

Usage is 

  site_watcher.rb http://example.com

Requires:

Built to use only stdlib and do not have gem dependencies.

  - ruby >= 1.8.6

License
=====
© 2010 Thomas Kollbach <dev@bitfever.de>

All all files in this reprository are released under the [MIT Licence](http://www.opensource.org/licenses/mit-license.php).



