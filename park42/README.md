# Park42

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

## Development using Docker Compose

Ensure you have Docker and Docker Compose installed. Run the following to start the app and PostgreSQL (using Postgres 17.5):

```bash
docker-compose up --build
```

The Rails server will be available at http://localhost:3000 and the database at port 5432.
