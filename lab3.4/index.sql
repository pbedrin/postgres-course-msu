-- Показать все индексы в схеме
SELECT tablename, indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'public'


-- 1. Запрос к таблице artworks, фильтрация по id локации и названию области искусства
DROP INDEX IF EXISTS artw_loc_area;
SET enable_seqscan = ON;

EXPLAIN ANALYZE
SELECT * FROM artworks
WHERE location_id = 82 AND art_area = 'живопись'
/*
"QUERY PLAN"
"Gather  (cost=1000.00..159786.31 rows=113 width=544) (actual time=192.403..3632.755 rows=101 loops=1)"
"  Workers Planned: 2"
"  Workers Launched: 2"
"  ->  Parallel Seq Scan on artworks  (cost=0.00..158775.01 rows=47 width=544) (actual time=174.840..3610.996 rows=34 loops=3)"
"        Filter: ((location_id = 82) AND (art_area = 'живопись'::text))"
"        Rows Removed by Filter: 345194"
"Planning Time: 0.248 ms"
-- Время планирования

"Execution Time: 3633.589 ms"
-- включает продолжительность запуска и остановки исполнителя запроса, время выполнения всех сработавших триггеров,
-- не включает время разбора, перезаписи и планирования запроса 
*/

-- составной индекс для двух полей фильтрации
-- тип индекса по умолчанию - B-дерево
CREATE INDEX artw_loc_area ON artworks (location_id, art_area);
-- Query returned successfully in 3 secs 676 msec.
SET enable_seqscan = FALSE;

EXPLAIN ANALYZE
SELECT * FROM artworks
WHERE location_id = 82 AND art_area = 'живопись'
/*
"QUERY PLAN"
"Index Scan using artw_loc_area on artworks  (cost=0.42..215.69 rows=113 width=544) (actual time=0.875..1.522 rows=101 loops=1)"
"  Index Cond: ((location_id = 82) AND (art_area = 'живопись'::text))"
"Planning Time: 0.938 ms"
"Execution Time: 1.562 ms"
*/

-- 2. К таблице artworks присоединяем storage_locations, фильтрация по рейтингу и типу локации
DROP INDEX IF EXISTS top_museums_artw_rating;
DROP INDEX IF EXISTS top_museums_artw_loctype;
SET enable_seqscan = ON;

EXPLAIN ANALYZE
SELECT artworks.artwork_id,
	   artworks.title,
	   artworks.avg_rating,
	   storage_locations.location_id,
	   storage_locations.type,
	   storage_locations.title,
	   storage_locations.contact_data
FROM artworks JOIN storage_locations USING(location_id)
WHERE avg_rating > 4.0 AND storage_locations.type = 'музей'
/*
"QUERY PLAN"
"Gather  (cost=1034.30..160025.93 rows=11590 width=185) (actual time=44.249..3831.361 rows=11564 loops=1)"
"  Workers Planned: 2"
"  Workers Launched: 2"
"  ->  Hash Join  (cost=34.30..157866.93 rows=4829 width=185) (actual time=19.075..3799.720 rows=3855 loops=3)"
"        Hash Cond: (artworks.location_id = storage_locations.location_id)"
"        ->  Parallel Seq Scan on artworks  (cost=0.00..157696.18 rows=51741 width=33) (actual time=0.716..3786.902 rows=40878 loops=3)"
"              Filter: (avg_rating > 4.0)"
"              Rows Removed by Filter: 304350"
"        ->  Hash  (cost=33.25..33.25 rows=84 width=156) (actual time=0.567..0.593 rows=84 loops=3)"
"              Buckets: 1024  Batches: 1  Memory Usage: 23kB"
"              ->  Seq Scan on storage_locations  (cost=0.00..33.25 rows=84 width=156) (actual time=0.091..0.524 rows=84 loops=3)"
"                    Filter: (type = 'музей'::text)"
"                    Rows Removed by Filter: 816"
"Planning Time: 17.188 ms"
"Execution Time: 3831.936 ms"
*/

CREATE INDEX top_museums_artw_rating ON artworks (avg_rating);
CREATE INDEX top_museums_artw_loctype ON storage_locations (type);
-- Query returned successfully in 4 secs 647 msec.
SET enable_seqscan = FALSE;

EXPLAIN ANALYZE
SELECT artworks.artwork_id,
	   artworks.title,
	   artworks.avg_rating,
	   storage_locations.location_id,
	   storage_locations.type,
	   storage_locations.title,
	   storage_locations.contact_data
FROM artworks JOIN storage_locations USING(location_id)
WHERE avg_rating > 4.0 AND storage_locations.type = 'музей'
/*
"QUERY PLAN"
"Gather  (cost=3355.83..159732.08 rows=11590 width=185) (actual time=148.747..1501.991 rows=11564 loops=1)"
"  Workers Planned: 2"
"  Workers Launched: 2"
"  ->  Hash Join  (cost=2355.83..157573.08 rows=4829 width=185) (actual time=130.439..1474.188 rows=3855 loops=3)"
"        Hash Cond: (artworks.location_id = storage_locations.location_id)"
"        ->  Parallel Bitmap Heap Scan on artworks  (cost=2326.80..157407.60 rows=51741 width=33) (actual time=36.169..1461.744 rows=40878 loops=3)"
"              Recheck Cond: (avg_rating > 4.0)"
"              Heap Blocks: exact=20818"
"              ->  Bitmap Index Scan on top_museums_artw_rating  (cost=0.00..2295.76 rows=124178 width=0) (actual time=40.676..40.677 rows=122633 loops=1)"
"                    Index Cond: (avg_rating > 4.0)"
"        ->  Hash  (cost=27.98..27.98 rows=84 width=156) (actual time=0.471..0.479 rows=84 loops=3)"
"              Buckets: 1024  Batches: 1  Memory Usage: 23kB"
"              ->  Bitmap Heap Scan on storage_locations  (cost=4.93..27.98 rows=84 width=156) (actual time=0.280..0.361 rows=84 loops=3)"
"                    Recheck Cond: (type = 'музей'::text)"
"                    Heap Blocks: exact=21"
"                    ->  Bitmap Index Scan on top_museums_artw_loctype  (cost=0.00..4.91 rows=84 width=0) (actual time=0.197..0.198 rows=84 loops=3)"
"                          Index Cond: (type = 'музей'::text)"
"Planning Time: 16.017 ms"
"Execution Time: 1504.056 ms"
*/

-- 3. Фильтрация с массивом. Ищем работы, имеющие нужные теги.
DROP INDEX IF EXISTS tags_selector; 
SET enable_seqscan = ON;

EXPLAIN ANALYZE
SELECT * FROM artworks WHERE (tags @> ARRAY['природа', 'солнце']::varchar(50)[])
/*
"QUERY PLAN"
"Gather  (cost=1000.00..158697.58 rows=14 width=544) (actual time=6.104..2746.209 rows=25 loops=1)"
"  Workers Planned: 2"
"  Workers Launched: 2"
"  ->  Parallel Seq Scan on artworks  (cost=0.00..157696.18 rows=6 width=544) (actual time=263.617..2723.869 rows=8 loops=3)"
"        Filter: (tags @> '{природа,солнце}'::character varying(50)[])"
"        Rows Removed by Filter: 345219"
"Planning Time: 0.431 ms"
"Execution Time: 2746.282 ms"
*/

CREATE INDEX tags_selector ON artworks USING GIN(tags);
-- Query returned successfully in 3 secs 6 msec.
SET enable_seqscan = FALSE;

EXPLAIN ANALYZE
SELECT * FROM artworks WHERE (tags @> ARRAY['природа', 'солнце']::varchar(50)[])
/*
"QUERY PLAN"
"Bitmap Heap Scan on artworks  (cost=36.11..91.88 rows=14 width=544) (actual time=3.374..5.483 rows=25 loops=1)"
"  Recheck Cond: (tags @> '{природа,солнце}'::character varying(50)[])"
"  Heap Blocks: exact=25"
"  ->  Bitmap Index Scan on tags_selector  (cost=0.00..36.11 rows=14 width=0) (actual time=3.029..3.029 rows=25 loops=1)"
"        Index Cond: (tags @> '{природа,солнце}'::character varying(50)[])"
"Planning Time: 2.863 ms"
"Execution Time: 5.562 ms"
*/

-- 4. Фильтрация с JSON. Ищем работы в локации, которые по измерениям не превышают 1 м
DROP INDEX IF EXISTS sizes_filter; 
DROP INDEX IF EXISTS location_id_ind; 
SET enable_seqscan = ON;

EXPLAIN ANALYZE
SELECT * FROM artworks
WHERE (((sizes->>'measure' = 'mm') and ((sizes->>'width')::integer < 1000) and ((sizes->>'height')::integer < 1000) and ((sizes->>'length')::integer < 1000)) OR
	  ((sizes->>'measure' = 'cm') and ((sizes->>'width')::integer < 100) and ((sizes->>'height')::integer < 100) and ((sizes->>'length')::integer < 100)) OR
	  ((sizes->>'measure' = 'm') and ((sizes->>'width')::integer < 1) and ((sizes->>'height')::integer < 1) and ((sizes->>'length')::integer < 1))) AND
	  location_id = 42;
/*
"QUERY PLAN"
"Gather  (cost=1000.00..204007.36 rows=1 width=544) (actual time=60.746..3703.033 rows=369 loops=1)"
"  Workers Planned: 2"
"  Workers Launched: 2"
"  ->  Parallel Seq Scan on artworks  (cost=0.00..203007.26 rows=1 width=544) (actual time=37.892..3676.761 rows=123 loops=3)"
"        Filter: ((location_id = 42) AND ((((sizes ->> 'measure'::text) = 'mm'::text) AND (((sizes ->> 'width'::text))::integer < 1000) AND (((sizes ->> 'height'::text))::integer < 1000) AND (((sizes ->> 'length'::text))::integer < 1000)) OR (((sizes ->> 'measure'::text) = 'cm'::text) AND (((sizes ->> 'width'::text))::integer < 100) AND (((sizes ->> 'height'::text))::integer < 100) AND (((sizes ->> 'length'::text))::integer < 100)) OR (((sizes ->> 'measure'::text) = 'm'::text) AND (((sizes ->> 'width'::text))::integer < 1) AND (((sizes ->> 'height'::text))::integer < 1) AND (((sizes ->> 'length'::text))::integer < 1))))"
"        Rows Removed by Filter: 345104"
"Planning Time: 0.717 ms"
"Execution Time: 3703.184 ms"
*/
	  
CREATE INDEX sizes_filter ON artworks USING GIN(sizes);
CREATE INDEX location_id_ind ON artworks (location_id);
-- Query returned successfully in 9 secs 92 msec.
SET enable_seqscan = FALSE;

EXPLAIN ANALYZE
SELECT * FROM artworks
WHERE (((sizes->>'measure' = 'mm') and ((sizes->>'width')::integer < 1000) and ((sizes->>'height')::integer < 1000) and ((sizes->>'length')::integer < 1000)) OR
	  ((sizes->>'measure' = 'cm') and ((sizes->>'width')::integer < 100) and ((sizes->>'height')::integer < 100) and ((sizes->>'length')::integer < 100)) OR
	  ((sizes->>'measure' = 'm') and ((sizes->>'width')::integer < 1) and ((sizes->>'height')::integer < 1) and ((sizes->>'length')::integer < 1))) AND
	  location_id = 42;
/*
"QUERY PLAN"
"Index Scan using location_id_ind on artworks  (cost=0.42..321.50 rows=1 width=544) (actual time=0.664..9.766 rows=369 loops=1)"
"  Index Cond: (location_id = 42)"
"  Filter: ((((sizes ->> 'measure'::text) = 'mm'::text) AND (((sizes ->> 'width'::text))::integer < 1000) AND (((sizes ->> 'height'::text))::integer < 1000) AND (((sizes ->> 'length'::text))::integer < 1000)) OR (((sizes ->> 'measure'::text) = 'cm'::text) AND (((sizes ->> 'width'::text))::integer < 100) AND (((sizes ->> 'height'::text))::integer < 100) AND (((sizes ->> 'length'::text))::integer < 100)) OR (((sizes ->> 'measure'::text) = 'm'::text) AND (((sizes ->> 'width'::text))::integer < 1) AND (((sizes ->> 'height'::text))::integer < 1) AND (((sizes ->> 'length'::text))::integer < 1)))"
"  Rows Removed by Filter: 704"
"Planning Time: 1.872 ms"
"Execution Time: 9.903 ms"
*/

-- 5. Полнотекстовый поиск. 
-- tsvector - документ, tsquery - запрос
DROP INDEX IF EXISTS description_search;
SET enable_seqscan = ON;

EXPLAIN ANALYZE
SELECT * FROM artworks
WHERE to_tsvector('russian', description) @@ to_tsquery('russian', 'космос & пространство');
/*
"QUERY PLAN"
"Seq Scan on artworks  (cost=10000000000.00..10000424168.52 rows=26 width=544) (actual time=31.609..15216.117 rows=985 loops=1)"
"  Filter: (to_tsvector('russian'::regconfig, description) @@ '''космос'' & ''пространств'''::tsquery)"
"  Rows Removed by Filter: 1034697"
"Planning Time: 0.378 ms"
"Execution Time: 15217.061 ms"
*/

CREATE INDEX description_search ON artworks USING GIN(to_tsvector('russian', description));
-- Query returned successfully in 47 secs 605 msec.
SET enable_seqscan = FALSE;

EXPLAIN ANALYZE
SELECT * FROM artworks
WHERE to_tsvector('russian', description) @@ to_tsquery('russian', 'космос & пространство');
/*
"QUERY PLAN"
"Bitmap Heap Scan on artworks  (cost=20.20..130.01 rows=26 width=544) (actual time=5.376..135.875 rows=985 loops=1)"
"  Recheck Cond: (to_tsvector('russian'::regconfig, description) @@ '''космос'' & ''пространств'''::tsquery)"
"  Heap Blocks: exact=980"
"  ->  Bitmap Index Scan on description_search  (cost=0.00..20.19 rows=26 width=0) (actual time=4.545..4.546 rows=985 loops=1)"
"        Index Cond: (to_tsvector('russian'::regconfig, description) @@ '''космос'' & ''пространств'''::tsquery)"
"Planning Time: 7.450 ms"
"Execution Time: 136.309 ms"
*/

-- 6. Секционирование таблицы
EXPLAIN ANALYZE
SELECT * FROM interactions
WHERE week_id >= 21 AND week_id <= 25
/*
"QUERY PLAN"
"Seq Scan on interactions  (cost=10000000000.00..10002791227.24 rows=20685945 width=56) (actual time=0.228..11358.418 rows=20713640 loops=1)"
"  Filter: ((week_id >= 21) AND (week_id <= 25))"
"  Rows Removed by Filter: 82854560"
"Planning Time: 0.132 ms"
"Execution Time: 11983.803 ms"
*/

CREATE TABLE IF NOT EXISTS "interactions_part" (
  "interaction_id" serial,
  "week_id" integer,
  "artwork_id" integer,
  "user_id" integer,
  "user_locatlity" text,
  "views" integer,
  "views_duration" interval,
  "rating" smallint,
  "is_favorite" boolean
) PARTITION BY RANGE (week_id);

ALTER TABLE interactions_part add PRIMARY KEY(week_id, interaction_id);

ALTER TABLE interactions_part
ADD FOREIGN KEY (artwork_id)
REFERENCES artworks(artwork_id)
ON DELETE CASCADE;

ALTER TABLE interactions_part
ADD FOREIGN KEY (user_id)
REFERENCES users(user_id)
ON DELETE SET NULL;

ALTER TABLE interactions_part
ADD FOREIGN KEY (week_id)
REFERENCES weeks_for_analysis(week_id)
ON DELETE CASCADE;

ALTER TABLE interactions_part ALTER COLUMN artwork_id SET NOT NULL;
ALTER TABLE interactions_part ALTER COLUMN week_id SET NOT NULL;
ALTER TABLE interactions_part ALTER COLUMN views SET DEFAULT 0;
ALTER TABLE interactions_part ALTER COLUMN views_duration SET DEFAULT '0:0:0';
ALTER TABLE interactions_part ALTER COLUMN is_favorite SET DEFAULT False;

CREATE TABLE IF NOT EXISTS interactions_1_2021 PARTITION OF interactions_part
    FOR VALUES FROM (1) TO (6);
CREATE TABLE IF NOT EXISTS interactions_2_2021 PARTITION OF interactions_part
    FOR VALUES FROM (6) TO (11);
CREATE TABLE IF NOT EXISTS interactions_3_2021 PARTITION OF interactions_part
    FOR VALUES FROM (11) TO (16);
CREATE TABLE IF NOT EXISTS interactions_4_2021 PARTITION OF interactions_part
    FOR VALUES FROM (16) TO (21);
CREATE TABLE IF NOT EXISTS interactions_5_2021 PARTITION OF interactions_part
    FOR VALUES FROM (21) TO (26);
	
INSERT INTO interactions_part SELECT * FROM interactions;
-- Query returned successfully in 36 min 14 secs.

CREATE INDEX interactions_part_wid_ind ON interactions_part (week_id);
-- Query returned successfully in 1 min 31 secs

EXPLAIN ANALYZE
SELECT * FROM interactions_part
WHERE week_id >= 21 AND week_id <= 25
/*
"QUERY PLAN"
"Gather  (cost=3198.01..285382.12 rows=103568 width=71) (actual time=1209.990..6136.937 rows=20713640 loops=1)"
"  Workers Planned: 2"
"  Workers Launched: 2"
"  ->  Parallel Append  (cost=2198.01..274025.32 rows=43153 width=71) (actual time=1195.555..5060.542 rows=6904547 loops=3)"
"        ->  Parallel Bitmap Heap Scan on interactions_5_2021  (cost=2198.01..273809.55 rows=43153 width=71) (actual time=1195.460..4657.866 rows=6904547 loops=3)"
"              Recheck Cond: ((week_id >= 21) AND (week_id <= 25))"
"              Heap Blocks: exact=7446 lossy=32303"
"              ->  Bitmap Index Scan on interactions_5_2021_week_id_idx  (cost=0.00..2172.12 rows=103568 width=0) (actual time=1197.540..1197.543 rows=20713640 loops=1)"
"                    Index Cond: ((week_id >= 21) AND (week_id <= 25))"
"Planning Time: 10.514 ms"
"Execution Time: 6819.591 ms"
*/