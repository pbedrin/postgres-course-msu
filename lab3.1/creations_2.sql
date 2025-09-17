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
  "location_id" integer,
  "location" text,
  "sizes" jsonb,
  "tags" varchar(50)[],
  "avg_rating" numeric(2, 1)
);

CREATE TABLE "users" (
  "user_id" serial,
  "name" text,
  "phone_number" varchar(15),
  "email" text
);

CREATE TABLE "interactions" (
  "interaction_id" serial,
  "week_id" integer,
  "artwork_id" integer,
  "user_id" integer,
  "user_locatlity" text,
  "views" integer,
  "views_duration" interval,
  "rating" smallint,
  "is_favorite" boolean
);

CREATE TABLE "weeks_for_analysis" (
  "week_id" serial,
  "year" integer,
  "month" smallint,
  "week" smallint
);

SET CONSTRAINTS ALL DEFERRED;

COPY storage_locations
    FROM '/Library/PostgreSQL/11/bin/Database/locations1.csv' WITH (FORMAT TEXT, delimiter '|', null 'null');

COPY artworks
    FROM '/Library/PostgreSQL/11/bin/Database/artworks1.csv' WITH (FORMAT TEXT, delimiter '|', null 'null');

COPY users
    FROM '/Library/PostgreSQL/11/bin/Database/users1.csv' WITH (FORMAT TEXT, delimiter '|', null 'null');

COPY interactions
    FROM '/Library/PostgreSQL/11/bin/Database/interactions1.csv' WITH (FORMAT TEXT, delimiter '|', null 'null');

COPY weeks_for_analysis
    FROM '/Library/PostgreSQL/11/bin/Database/weeks1.csv' WITH (FORMAT TEXT, delimiter '|', null 'null');

ALTER TABLE storage_locations add PRIMARY KEY(location_id);
ALTER TABLE artworks add PRIMARY KEY(artwork_id);
ALTER TABLE users add PRIMARY KEY(user_id);
ALTER TABLE interactions add PRIMARY KEY(interaction_id);
ALTER TABLE weeks_for_analysis add PRIMARY KEY (week_id);

ALTER TABLE storage_locations ALTER COLUMN title SET NOT NULL;

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

ALTER TABLE artworks
ADD CONSTRAINT measure_unit_check CHECK
  (NOT((((sizes -> 'width') IS NOT NULL) OR ((sizes -> 'height') IS NOT NULL)
    OR ((sizes -> 'length') IS NOT NULL)) AND ((sizes -> 'measure') IS NULL)));

ALTER TABLE interactions
ADD FOREIGN KEY (artwork_id)
REFERENCES artworks(artwork_id)
ON DELETE CASCADE;

ALTER TABLE interactions
ADD FOREIGN KEY (user_id)
REFERENCES users(user_id)
ON DELETE SET NULL;

ALTER TABLE interactions
ADD FOREIGN KEY (week_id)
REFERENCES weeks_for_analysis(week_id)
ON DELETE CASCADE;

ALTER TABLE interactions ALTER COLUMN artwork_id SET NOT NULL;
ALTER TABLE interactions ALTER COLUMN week_id SET NOT NULL;
ALTER TABLE interactions ALTER COLUMN views SET DEFAULT 0;
ALTER TABLE interactions ALTER COLUMN views_duration SET DEFAULT '0:0:0';
ALTER TABLE interactions ALTER COLUMN is_favorite SET DEFAULT False;

COMMIT; 

ANALYZE;
--rollback;