SET ROLE postgres;

DROP MATERIALIZED VIEW IF EXISTS weekly_stats;
DROP VIEW IF EXISTS artworks_locations;

REVOKE ALL ON ALL TABLES IN SCHEMA public FROM test;
REVOKE ALL ON SCHEMA public FROM test;
REVOKE ALL ON DATABASE tst1 FROM test;

DROP ROLE IF EXISTS test;
DROP ROLE IF EXISTS relocation_role;


-- Создадим пользователя test и выдать доступ к БД
CREATE USER test;
GRANT ALL PRIVILEGES ON DATABASE tst1 to test; -- == право: CREATE (schema), CONNECT(to db), TEMPORARY(create tmp objects)
GRANT USAGE ON SCHEMA public TO test; -- право «просматривать» объекты внутри схемы

-- Присвоим test-у права на таблицы/столбцы
GRANT SELECT ON interactions, weeks_for_analysis TO test; -- interactions, weeks_for_analysis: только select
GRANT SELECT (user_id, name) ON users TO test; -- users: только select без контактных данных

GRANT SELECT, INSERT, UPDATE ON storage_locations to test; -- storage_locations: полные права select, insert, update

GRANT SELECT ON artworks to test; -- artworks: полные права select
GRANT UPDATE (title, authors, description, creation_year, photo_url, -- artworks: запрет на update рейтинга
	cost, currency, art_area, style, location_id, location, sizes, tags) ON artworks to test;

-- Создадим представления
-- 1. weekly_stats представляет статистику показателей произведений за нужную неделю
CREATE MATERIALIZED VIEW weekly_stats AS
	SELECT
		artwork_id,
		(SELECT title FROM artworks WHERE artworks.artwork_id = interactions.artwork_id) AS artwork,
		SUM(views) AS views_cnt,
		SUM(views_duration) AS duration_sum,
		AVG(rating) AS avg_rating,
		COUNT(is_favorite) filter (where is_favorite) AS favorites_cnt
	FROM interactions
	WHERE week_id = 25
	GROUP BY artwork_id, artwork;
	
-- DROP VIEW weekly_stats;
 
GRANT SELECT ON weekly_stats to test;

SET ROLE test;

-- вывести N самых популярных за нужную неделю:
SELECT * FROM weekly_stats
ORDER BY views_cnt DESC, duration_sum DESC, avg_rating DESC, favorites_cnt DESC
LIMIT 100;

SET ROLE postgres;

-- 2. artworks_locations соединяет таблицу произведений и локаций
-- может использоваться, например, при "переезде" произведений
CREATE OR REPLACE VIEW artworks_locations AS
	SELECT
		artwork_id,
		title,
		authors,
		location_id,
		location,
		(SELECT type FROM storage_locations WHERE artworks.location_id = storage_locations.location_id) AS location_type,
		(SELECT contact_data->'address' FROM storage_locations WHERE artworks.location_id = storage_locations.location_id) AS address
	FROM artworks;

-- создадим роль relocation_role, дадим ей права в artworks_locations, назначим пользователю test эту роль
CREATE ROLE relocation_role;
GRANT SELECT ON artworks_locations to relocation_role;
GRANT UPDATE(location_id, location) ON artworks_locations to relocation_role;
GRANT relocation_role to test;

-- смена локации работы с помощью представления artworks_locations:
SET ROLE test;

SELECT * FROM artworks_locations WHERE artwork_id = 20;

UPDATE artworks_locations
	SET location_id = 44,
	location = (SELECT title FROM storage_locations WHERE location_id = 44)
WHERE artwork_id = 20;

SELECT * FROM artworks_locations WHERE artwork_id = 20;

-- проверка контроля прав доступа
-- попробуем изменить рейтинг у работы (не получится - прав на update этого столбца у test нет)
SELECT * FROM artworks WHERE avg_rating = 1.0 LIMIT 1;

UPDATE artworks
SET avg_rating = 4.9
WHERE artwork_id = (SELECT artwork_id FROM artworks WHERE avg_rating = 1.0 LIMIT 1);