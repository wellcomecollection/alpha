# Wellcome Library Alpha

We're taking the work done in our What's In The Library? project -- http://whatsinthelibrary.com -- and moving it into the Wellcome Library infrastructure. It'll be a link from the existing Sandbox area -- https://wellcomelibrary.org/what-we-do/sandbox/ -- and positioned as an experimental first step. 

## Installation

The website requires the following services to be installed and running on a server somewhere:

### Postgres

[Postgres](http://www.postgresql.org) is used as the primary database. It is an open source project, and can either be compiled and installed from source, or you can use a commerical cloud service (like Heroku or Amazon RDS).

For local development on a Mac, the easiest way to get it up and running is via [Postgres.app](http://postgresapp.com), a packaged OSX app.

The project requires version 9.4 or greater.

### Redis

[Redis](http://redis.io) is used a secondary datastore for managing the 'job queue' (tasks that need to be run). Again, it can be compiled and run from source, or you can use a commerical cloud service (like Heroku or Amazon ElastiCache).

The project requires version 2.8 or greater (3.0.3+ is recommended for large installations). These requirements come from [Sidekiq](https://github.com/mperham/sidekiq), the queue manager.

### ElasticSearch

[ElasticSearch](https://www.elastic.co) is used a secondary datastore for fast searching and querying.  Again, it can be compiled and run from source, or you can use a commerical cloud service (like Searchly, QBox or Amazon).
