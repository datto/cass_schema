source 'https://rubygems.org'

# Specify your gem's dependencies in cass_migrations.gemspec
gemspec

group :development, :test do
  gem "pry"
  gem "awesome_print"
  gem 'm', :git => 'git@github.com:ANorwell/m.git', :branch => 'minitest_5'
end

group :test do
  gem 'minitest_should', :git => 'git@github.com:citrus/minitest_should.git'
  gem "mocha"
end

gem 'cassandra-driver', :git => 'git@github.com:datastax/ruby-driver.git', :tag => 'v2.0.1'
