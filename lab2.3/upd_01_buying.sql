-- Скульптура "Морская звезда" (artwork_id = 15), продаётся в магазине ArtNow
SELECT
	artworks.artwork_id AS artwork_id,
	artworks.title AS artwork,
	art_areas.title AS area,
	artworks.cost AS cost,
	artworks.currency AS currency,
	storage_locations.title AS location,
	location_types.type_name AS location_type
FROM artworks
LEFT JOIN storage_locations USING(location_id)
JOIN location_types USING(type_id)
JOIN art_areas USING(art_area_id)
WHERE artworks.title = 'Морская звезда'


-- Скульптура "Морская звезда" перешла из магазина в частную коллекцию
-- Изменяется место хранения, цена перестаёт указываться
UPDATE artworks
SET
	cost = NULL,
	currency = NULL,
	location_id = 4 -- Если указать несуществующий id, будет constraint "artworks_location_id_fkey"
WHERE artwork_id = 15


-- Результат
SELECT
	artworks.artwork_id AS artwork_id,
	artworks.title AS artwork,
	art_areas.title AS area,
	artworks.cost AS cost,
	artworks.currency AS currency,
	storage_locations.title AS location,
	location_types.type_name AS location_type
FROM artworks
LEFT JOIN storage_locations USING(location_id)
JOIN location_types USING(type_id)
JOIN art_areas USING(art_area_id)
WHERE artworks.title = 'Морская звезда'