-- Показать картины русских художников второй половины XIX века, которые можно посмотреть в музеях Москвы
SELECT
	artworks.title AS artwork,
	artworks.photo_url AS artwork_photo,
	artworks.creation_year AS creation_year,
	authors.name AS author,
	storage_locations.title AS museum,
	storage_locations.local_address AS address,
	storage_locations.contact_data AS contacts
FROM artworks
JOIN authors_artworks USING(artwork_id)
LEFT JOIN authors USING(author_id)
JOIN storage_locations USING(location_id)
JOIN location_types USING(type_id)
JOIN authors_countries USING(author_id)
JOIN countries ON countries.country_id = authors_countries.country_id
JOIN art_areas USING(art_area_id)
WHERE
	storage_locations.locality = 'Москва' AND
	location_types.type_name = 'Музей' AND
	countries.country_name = 'Российская империя' AND
	art_areas.title = 'живопись' AND
	artworks.creation_year BETWEEN 1850 AND 1900
ORDER BY artworks.creation_year