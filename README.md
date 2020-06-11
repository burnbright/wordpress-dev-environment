# WordPress Local Development Environment

This project provides a way to run/develop WordPress sites locally, before publishing changes to a live site.

The primary tool to do this is Docker.

## Usage

Kick off the web and database servers with docker:

```sh
docker-compose up
```

## Introducing a site

Add each WordPress site to the `sites` directory.

If your website folder is `my-website`, the resulting website should be visible at:
http://locahost/my-website/

## Add database

Use a MySQL client to connect to the local database running at:
`localhost:4306`

## Updating URLs

The URLs in the database need to up updated for the site to work locally.

```sql
UPDATE wp_options SET option_value = REPLACE(option_value, 'http://my-website.com', 'http://localhost/my-website');
```

```sql
UPDATE wp_posts SET post_content = REPLACE(post_content, 'http://my-website.com', 'http://localhost/my-website');
```

Don't forget to do the reverse if uploading database to a live server.
