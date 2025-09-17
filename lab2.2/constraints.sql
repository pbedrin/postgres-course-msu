-- authors_areas
ALTER TABLE authors_areas
ADD CONSTRAINT del_authors_areas_author_id_fkey FOREIGN KEY (author_id)
REFERENCES authors (author_id) ON DELETE CASCADE;

ALTER TABLE authors_areas
ADD CONSTRAINT del_authors_areas_art_area_id_fkey FOREIGN KEY (art_area_id)
REFERENCES art_areas (art_area_id) ON DELETE CASCADE;

-- authors_artworks
ALTER TABLE authors_artworks
ADD CONSTRAINT del_authors_artworks_author_id_fkey FOREIGN KEY (author_id)
REFERENCES authors (author_id) ON DELETE CASCADE;

ALTER TABLE authors_artworks
ADD CONSTRAINT del_authors_artworks_artwork_id_fkey FOREIGN KEY (artwork_id)
REFERENCES artworks (artwork_id) ON DELETE CASCADE;

-- authors_countries
ALTER TABLE authors_countries
ADD CONSTRAINT del_authors_countries_author_id_fkey FOREIGN KEY (author_id)
REFERENCES authors (author_id) ON DELETE CASCADE;

ALTER TABLE authors_countries
ADD CONSTRAINT del_authors_countries_country_id_fkey FOREIGN KEY (country_id)
REFERENCES countries (country_id) ON DELETE CASCADE;

-- artworks_materials
ALTER TABLE artworks_materials
ADD CONSTRAINT del_artworks_materials_artwork_id_fkey FOREIGN KEY (artwork_id)
REFERENCES artworks (artwork_id) ON DELETE CASCADE;

ALTER TABLE artworks_materials
ADD CONSTRAINT del_artworks_materials_material_id_fkey FOREIGN KEY (material_id)
REFERENCES materials (material_id) ON DELETE CASCADE;

-- artworks_styles
ALTER TABLE artworks_styles
ADD CONSTRAINT del_artworks_styles_artwork_id_fkey FOREIGN KEY (artwork_id)
REFERENCES artworks (artwork_id) ON DELETE CASCADE;

ALTER TABLE artworks_styles
ADD CONSTRAINT del_artworks_styles_style_id_fkey FOREIGN KEY (style_id)
REFERENCES styles (style_id) ON DELETE CASCADE;

-- artworks
ALTER TABLE artworks
ADD CONSTRAINT del_artworks_art_area_id_fkey FOREIGN KEY (art_area_id)
REFERENCES art_areas (art_area_id) ON DELETE SET NULL;

ALTER TABLE artworks
ADD CONSTRAINT del_artworks_location_id_fkey FOREIGN KEY (location_id)
REFERENCES storage_location (location_id) ON DELETE SET NULL;

-- storage_location
ALTER TABLE storage_location
ADD CONSTRAINT del_storage_location_type_id_fkey FOREIGN KEY (type_id)
REFERENCES storage_location (type_id) ON DELETE CASCADE;

ALTER TABLE storage_location
ADD CONSTRAINT del_storage_location_country_id_fkey FOREIGN KEY (country_id)
REFERENCES storage_location (country_id) ON DELETE CASCADE;