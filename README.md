# Wellcome Library Alpha

We're taking the work done in our What's In The Library? project -- http://whatsinthelibrary.com -- and moving it into the Wellcome Library infrastructure. It'll be a link from the existing Sandbox area -- https://wellcomelibrary.org/what-we-do/sandbox/ -- and positioned as an experimental first step.

## Installation

Running the website, either locally or in production, requires both setting up the code to run the website itself, and some additional services.

### Website

The server-side code for the website is written in Ruby. The first requirement is having the correct version of this installed, as specified in the `Gemfile` (currently Ruby 2.2.3).

This can be installed either as the system Ruby, or for local development, using a tool like `rbenv` or `rvm` (which allow multiple versions of Ruby to installed on the same machine).

Once Ruby is installed, the library (or 'gem') called Bundler needs to be installed (if not already) – this allows for easy installation and management of additional Ruby gems. It can be installed using `gem install bundler`.

Once Bundler is installed, the rest of the libraries (as specified in the `Gemfile` and `Gemfile.lock`) can be installed by running `bundle install`.

To start the web server, you can run the command specified in the `Procfile`:

`bundle exec puma -C config/puma.rb`.

Alternatively, for local development you could install the gem `foreman` (by running `gem install foreman`) and then run `foreman start web`. As well as running the command specified in the `Procfile`, this also reads the contents of `.env` and exposes the contents as environment variables.

As well as the web server, there is also a job queue worker process (run by a library called Sidekiq), which can be started by running `foreman start worker` or `bundle exec sidekiq`.

Running `foreman start` starts both a web server and a job queue worker at the same time.

### Services

The website requires the following services to be installed and running on a server somewhere:

#### Postgres

[Postgres](http://www.postgresql.org) is used as the primary database. It is an open source project, and can either be compiled and installed from source, or you can use a commerical cloud service (like Heroku or Amazon RDS).

For local development on a Mac, the easiest way to get it up and running is via [Postgres.app](http://postgresapp.com), a packaged OSX app.

The project requires version 9.4 or greater.

The hostname, port, username, password and database name should be set in an environmnent variable called `DATABASE_URL` (eg `postgres://user:pass@host:port/database_name`).

The tables and indexes for the database can be setup for the first time by running `bundle exec rake db:setup`. After that, any future changes to the database structure can be made by running `bundle exec rake db:migrate`.

#### Redis

[Redis](http://redis.io) is used a secondary datastore for managing the 'job queue' (tasks that need to be run). Again, it can be compiled and run from source, or you can use a commerical cloud service (like Heroku or Amazon ElastiCache).

The project requires version 2.8 or greater (3.0.3+ is recommended for large installations). These requirements come from [Sidekiq](https://github.com/mperham/sidekiq), the queue manager.

The hostname, port, username and password should be set in an environmnent variable called `REDIS_URL` (eg `redis://user:pass@host:port`).

#### ElasticSearch

[ElasticSearch](https://www.elastic.co) is used a secondary datastore for fast searching and querying.  Again, it can be compiled and run from source, or you can use a commerical cloud service (like Searchly, QBox or Amazon).

The hostname, username and password should be set in an environmnent variable called `ELASTICSEARCH_URL` (eg `https://user:pass@host`).
