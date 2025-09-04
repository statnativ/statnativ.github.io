source "https://rubygems.org"

# GitHub Pages gem includes Jekyll and related plugins
gem "github-pages", group: :jekyll_plugins

# Required for Ruby 3.4+
gem "base64"
gem "bigdecimal"

# If you have any plugins, put them here!
group :jekyll_plugins do
  gem "jekyll-paginate"
  gem "jekyll-sitemap" 
  gem "jekyll-gist"
  gem "jekyll-feed"
  gem "jekyll-include-cache"
end

# Windows and JRuby does not include zoneinfo files, so bundle the tzinfo-data gem
# and associated library.
platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", "~> 1.2"
  gem "tzinfo-data"
end

# Lock `http_parser.rb` gem to `v0.6.x` on JRuby builds since newer versions of the gem
# do not have a Java counterpart.
gem "http_parser.rb", "~> 0.6.0", :platforms => [:jruby]