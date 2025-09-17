-- Показать скульптуры, продаваемые в магазине ArtNow. Отсортировать по стоимости (и валюте).
SELECT
	artworks.title AS artwork,
	artworks.photo_url AS artwork_photo,
	authors.name AS author,
	artworks.cost AS cost,
	artworks.currency AS currency
FROM artworks
JOIN authors_artworks USING(artwork_id)
LEFT JOIN authors USING(author_id)
JOIN art_areas USING(art_area_id)
JOIN storage_locations USING (location_id)
WHERE art_areas.title = 'скульптура' AND storage_locations.title = 'ArtNow'
ORDER BY cost DESC, currency