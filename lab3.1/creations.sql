BEGIN;

CREATE TABLE "storage_locations" (
  "location_id" serial,
  "title" text,
  "type" text,
  "contact_data" json
);

CREATE TABLE "artworks" (
  "artwork_id" serial,
  "title" text,
  "authors" text[],
  "description" text,
  "creation_year" integer,
  "photo_url" text,
  "cost" numeric,
  "currency" varchar(3),
  "art_area" text,
  "style" text,
  "location" text,
  "location_id" integer,
  "sizes" jsonb,
  "tags" varchar(50)[],
  "rating" numeric(2, 1)
);

CREATE TABLE "users" (
  "user_id" serial,
  "name" text,
  "phone_number" varchar(15),
  "email" text
);

CREATE TABLE "interactions" (
  "interaction_id" serial,
  "artwork_title" text,
  "artwork_authors" text[],
  "artwork_style" text,
  "artwork_area" text,
  "location" text,
  "location_id" integer,
  "artwork_id" integer,
  "user_id" integer,
  "user_locatlity" text,
  "interaction_type" varchar(20),
  "duration" interval,
  "timestamp_start" timestamp,
  "rating" smallint
);

CREATE TABLE "favorites" (
  "user_id" integer,
  "artwork_id" integer
);

SET CONSTRAINTS ALL DEFERRED;

COPY storage_locations
    FROM '/Library/PostgreSQL/11/bin/Database/locations.csv' WITH (FORMAT TEXT, delimiter '|', null 'null');

COPY artworks
    FROM '/Library/PostgreSQL/11/bin/Database/artworks.csv' WITH (FORMAT TEXT, delimiter '|', null 'null');

COPY users
    FROM '/Library/PostgreSQL/11/bin/Database/users.csv' WITH (FORMAT TEXT, delimiter '|', null 'null');

COPY interactions
    FROM '/Library/PostgreSQL/11/bin/Database/interactions.csv' WITH (FORMAT TEXT, delimiter '|', null 'null');

COPY favorites
    FROM '/Library/PostgreSQL/11/bin/Database/favorites.csv' WITH (FORMAT TEXT, delimiter '|', null 'null');

ALTER TABLE storage_locations add PRIMARY KEY(location_id);
ALTER TABLE artworks add PRIMARY KEY(artwork_id);
ALTER TABLE users add PRIMARY KEY(user_id);
ALTER TABLE interactions add PRIMARY KEY(interaction_id);
ALTER TABLE favorites add PRIMARY KEY ("user_id", "artwork_id");

ALTER TABLE storage_locations ALTER COLUMN title SET NOT NULL;
ALTER TABLE storage_locations ALTER COLUMN type SET NOT NULL;

ALTER TABLE artworks ALTER COLUMN title SET NOT NULL;

ALTER TABLE artworks
ADD FOREIGN KEY (location_id)
REFERENCES storage_locations(location_id)
ON DELETE SET NULL;

ALTER TABLE artworks
ADD CONSTRAINT cost_check CHECK (cost >= 0::numeric);

ALTER TABLE artworks
ADD CONSTRAINT creation_year_check CHECK (creation_year <= date_part('year', CURRENT_DATE));

ALTER TABLE artworks
ADD CONSTRAINT currency_check CHECK (NOT((cost IS NOT NULL) AND (currency IS NULL)));

ALTER TABLE interactions
ADD FOREIGN KEY (location_id)
REFERENCES storage_locations(location_id)
ON DELETE SET NULL;

ALTER TABLE interactions
ADD FOREIGN KEY (artwork_id)
REFERENCES artworks(artwork_id)
ON DELETE CASCADE;

ALTER TABLE interactions
ADD FOREIGN KEY (user_id)
REFERENCES users(user_id)
ON DELETE SET NULL;

ALTER TABLE favorites
ADD FOREIGN KEY (artwork_id)
REFERENCES artworks(artwork_id)
ON DELETE CASCADE;

ALTER TABLE favorites
ADD FOREIGN KEY (user_id)
REFERENCES users(user_id)
ON DELETE CASCADE;

COMMIT; 

ANALYZE;
--rollback;