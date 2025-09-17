-- Выведем типы локаций и объекты этих типов
SELECT
	location_types.type_id,
	location_types.type_name,
	storage_locations.location_id,
	storage_locations.title
FROM location_types
LEFT JOIN storage_locations USING(type_id)

-- Удалим типы локаций, в которых нет ни одного объекта
DELETE FROM location_types
WHERE type_id in 
	(SELECT location_types.type_id
	 FROM location_types
	 LEFT JOIN storage_locations USING(type_id)
	 WHERE storage_locations.type_id is NULL)
RETURNING type_id, type_name