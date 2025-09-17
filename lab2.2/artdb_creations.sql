CREATE TABLE authors (
  author_id SERIAL PRIMARY KEY,
  name text NOT NULL,
  description text,
  photo_url text,
  earliest_date_of_birth date,
  latest_date_of_birth date,
  earliest_date_of_death date,
  latest_date_of_death date,
  contact_data jsonb,
  CONSTRAINT birth_check CHECK
    (latest_date_of_birth < now() and earliest_date_of_birth <= latest_date_of_birth),
  CONSTRAINT death_check CHECK
    (latest_date_of_death < now() and earliest_date_of_death <= latest_date_of_death),
  CONSTRAINT life_years_check CHECK
    (latest_date_of_death > earliest_date_of_birth)
);

CREATE TABLE art_areas (
  art_area_id SERIAL PRIMARY KEY,
  title text NOT NULL UNIQUE,
  description text
);

CREATE TABLE authors_areas (
  author_id SERIAL,
  art_area_id SERIAL,
  PRIMARY KEY (author_id, art_area_id),
  FOREIGN KEY (author_id) REFERENCES authors (author_id) ON DELETE CASCADE,
  FOREIGN KEY (art_area_id) REFERENCES art_areas (art_area_id) ON DELETE CASCADE
);

CREATE TABLE location_types (
  type_id SERIAL PRIMARY KEY,
  type_name text NOT NULL UNIQUE
);

CREATE TABLE countries (
  country_id SERIAL PRIMARY KEY,
  country_name text NOT NULL UNIQUE
);

CREATE TABLE storage_locations (
  location_id SERIAL PRIMARY KEY,
  title text NOT NULL,
  type_id SERIAL NOT NULL,
  country_id SERIAL NOT NULL,
  locality text NOT NULL,
  local_address text,
  contact_data jsonb,
  opening_year integer,
  FOREIGN KEY (type_id) REFERENCES location_types (type_id) ON DELETE CASCADE,
  FOREIGN KEY (country_id) REFERENCES countries (country_id) ON DELETE CASCADE,
  CONSTRAINT opening_year_check CHECK (opening_year <= date_part('year', CURRENT_DATE))
);

CREATE TABLE artworks (
  artwork_id SERIAL PRIMARY KEY,
  title text NOT NULL,
  description text,
  creation_year integer,
  photo_url text,
  cost numeric,
  currency varchar(3),
  art_area_id integer,
  location_id integer,
  width numeric,
  height numeric,
  length numeric,
  measure_unit varchar(6),
  FOREIGN KEY (art_area_id) REFERENCES art_areas (art_area_id) ON DELETE SET NULL,
  FOREIGN KEY (location_id) REFERENCES storage_locations (location_id) ON DELETE SET NULL,
  CONSTRAINT measure_unit_check CHECK (NOT(((width IS NOT NULL) OR (height IS NOT NULL) OR (length IS NOT NULL)) AND (measure_unit IS NULL))),
  CONSTRAINT currency_check CHECK (NOT((cost IS NOT NULL) AND (currency IS NULL))),
  CONSTRAINT creation_year_check CHECK (creation_year <= date_part('year', CURRENT_DATE)),
  CONSTRAINT cost_check CHECK (cost >= 0::numeric)
);

CREATE TABLE authors_artworks (
  artwork_id SERIAL,
  author_id SERIAL,
  PRIMARY KEY (artwork_id, author_id),
  FOREIGN KEY (artwork_id) REFERENCES artworks (artwork_id) ON DELETE CASCADE,
  FOREIGN KEY (author_id) REFERENCES authors (author_id) ON DELETE CASCADE
);

CREATE TABLE styles (
  style_id SERIAL PRIMARY KEY,
  title text NOT NULL UNIQUE,
  description text
);

CREATE TABLE materials (
  material_id SERIAL PRIMARY KEY,
  title text NOT NULL UNIQUE,
  description text,
  photo_url text
);

CREATE TABLE artworks_styles (
  artwork_id SERIAL,
  style_id SERIAL,
  PRIMARY KEY (artwork_id, style_id),
  FOREIGN KEY (artwork_id) REFERENCES artworks (artwork_id) ON DELETE CASCADE,
  FOREIGN KEY (style_id) REFERENCES styles (style_id) ON DELETE CASCADE
);

CREATE TABLE authors_countries (
  author_id SERIAL,
  country_id SERIAL,
  PRIMARY KEY (author_id, country_id),
  FOREIGN KEY (author_id) REFERENCES authors (author_id) ON DELETE CASCADE,
  FOREIGN KEY (country_id) REFERENCES countries (country_id) ON DELETE CASCADE
);

CREATE TABLE artworks_materials (
  artwork_id SERIAL,
  material_id SERIAL,
  PRIMARY KEY (artwork_id, material_id),
  FOREIGN KEY (artwork_id) REFERENCES artworks (artwork_id) ON DELETE CASCADE,
  FOREIGN KEY (material_id) REFERENCES materials (material_id) ON DELETE CASCADE
);