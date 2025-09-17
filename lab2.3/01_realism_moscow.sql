-- Показать локации в Москве, где можно посмотреть картины в жанре реализм. Отсортировать по количеству картин
SELECT
	st.title AS location,
	st.local_address AS address,
	st.contact_data AS contacts,
	COUNT(artworks.artwork_id) AS realism_artworks_count
FROM storage_locations AS st
JOIN artworks USING(location_id)
JOIN artworks_styles USING(artwork_id)
JOIN styles USING(style_id)
JOIN art_areas USING(art_area_id)
WHERE styles.title = 'Реализм' AND st.locality = 'Москва' AND art_areas.title = 'живопись'
GROUP BY st.location_id
ORDER BY realism_artworks_count DESC