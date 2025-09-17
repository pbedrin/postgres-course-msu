CREATE VIEW weekly_stats AS
	SELECT
		artwork_id,
		(SELECT location FROM artworks WHERE artworks.artwork_id = interactions.artwork_id) AS locat,
		SUM(views) AS views_cnt,
		SUM(views_duration) AS duration_sum,
		AVG(rating) AS avg_rating,
		COUNT(is_favorite) filter (where is_favorite) AS favorites_cnt
	FROM interactions
	WHERE week_id = 25
	GROUP BY artwork_id;

DROP FUNCTION artwork_relocation(integer, integer)

-- artwork_relocation: функция, изменяющая локацию произведения
-- -- Аргументы: id произведения, id новой локации
-- -- Проверка на существование подаваемой локации
CREATE OR REPLACE FUNCTION artwork_relocation(artwork_id integer, new_location_id integer)
RETURNS SETOF artworks
AS $$
DECLARE
	new_location_id integer;
BEGIN
	BEGIN
		-- без strict: первая возвращенная строка / NULL (строк не найдено)
		-- 	   strict: ровно одна строка / NO_DATA_FOUND (строк не найдено) / TOO_MANY_ROWS (>1 строки)
	    SELECT location_id INTO STRICT new_location_id
			FROM storage_locations
			WHERE storage_locations.location_id = artwork_relocation.new_location_id;
	    EXCEPTION
			WHEN NO_DATA_FOUND THEN
				RAISE EXCEPTION 'Не существует локации с location_id=%', artwork_relocation.new_location_id;
	END;
	
	RETURN QUERY
	UPDATE artworks
	SET location_id = new_location_id,
		location = (SELECT title FROM storage_locations WHERE location_id = new_location_id)
	WHERE artworks.artwork_id = artwork_relocation.artwork_id
	RETURNING *;
	
	RETURN;
END;
$$ LANGUAGE plpgsql;

select * from artworks where artwork_id = 1;
select * from storage_locations where location_id = 1;

select * from artwork_relocation(1, 2);