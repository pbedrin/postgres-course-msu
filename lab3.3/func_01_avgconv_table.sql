DROP FUNCTION IF EXISTS get_stats(text, integer);


-- get_stats: функция, возвращающая конверсию по работам в опр. регионе за опр. неделю
-- -- Аргументы: населенный пункт, id недели
-- -- Проверка на существование статистики за неделю и в регионе
CREATE OR REPLACE FUNCTION get_stats(
	locality text,
	week_id integer
)
RETURNS TABLE(aw_id integer, aw text, conv numeric)
AS $$
DECLARE
	week_id integer;
	analyze_cnt integer := 0;
	sum numeric := 0;
	conversion real;
	res numeric;
	rec record;
	cur cursor FOR 
		SELECT artwork_id,
				(SELECT title FROM artworks WHERE interactions.artwork_id = artworks.artwork_id) as artwork,
				sum(views) as view_cnt,
				COUNT(is_favorite) filter (where is_favorite) as fav_cnt FROM interactions
			WHERE interactions.week_id = get_stats.week_id AND interactions.user_locatlity = get_stats.locality GROUP BY artwork_id, artwork;
BEGIN
	BEGIN
		-- без strict: первая возвращенная строка / NULL (строк не найдено)
		-- 	   strict: ровно одна строка / NO_DATA_FOUND (строк не найдено) / TOO_MANY_ROWS (>1 строки)
		SELECT weeks_for_analysis.week_id INTO STRICT week_id
			FROM weeks_for_analysis
			WHERE weeks_for_analysis.week_id = get_stats.week_id;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				RAISE EXCEPTION 'Статистика за неделю week_id=% отсутствует', get_stats.week_id;
	END;
	
	FOR rec IN cur
	LOOP
		analyze_cnt = analyze_cnt + 1;
		IF rec.view_cnt <> 0 THEN
			conversion = cast(rec.fav_cnt as numeric) / rec.view_cnt;
			RAISE NOTICE '% / % = %', rec.fav_cnt, rec.view_cnt, conversion;
			aw_id = rec.artwork_id;
			conv = conversion;
			aw = rec.artwork;
			RETURN NEXT;
		END IF;
	END LOOP;
	
	IF analyze_cnt = 0 THEN
		RAISE EXCEPTION 'На неделе week_id=% нет данных о пользователях из %', get_stats.week_id, get_stats.locality;
	END IF;
END;
$$ LANGUAGE plpgsql;

--SELECT artwork_id, sum(views) as vc, COUNT(is_favorite) filter (where is_favorite) as fc FROM interactions
--		WHERE interactions.week_id = 25 AND interactions.user_locatlity = 'с. Углич' GROUP BY artwork_id limit 100 ;
-- select * from interactions where artwork_id = 3483 and interactions.week_id = 25 AND interactions.user_locatlity = 'с. Углич'
select * from get_stats('Henryfort', 25) ORDER BY conv DESC;

-- не показывалось при проверке, но, видимо, всё так же, как с func_01_avgconv