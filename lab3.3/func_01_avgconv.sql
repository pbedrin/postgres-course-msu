DROP FUNCTION IF EXISTS get_stats(text, integer);


-- get_stats: функция, возвраща
-- -- Аргументы: id произведения, id новой локации
-- -- Проверка на существование подаваемой локации
CREATE OR REPLACE FUNCTION get_stats(
	locality text,
	week_id integer
)
RETURNS numeric
AS $$
DECLARE
	week_id integer;
	cnt integer := 0;
	analyze_cnt integer := 0;
	sum numeric := 0;
	conversion real;
	res numeric;
	cur cursor FOR 
		SELECT artwork_id, sum(views) as view_cnt, COUNT(is_favorite) filter (where is_favorite) as fav_cnt FROM interactions
			WHERE interactions.week_id = get_stats.week_id AND interactions.user_locatlity = get_stats.locality GROUP BY artwork_id;
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
	
	FOR c_row IN cur
	LOOP
		cnt = cnt + 1;
		IF c_row.view_cnt <> 0 THEN
			analyze_cnt = analyze_cnt + 1;
			conversion = cast(c_row.fav_cnt as numeric) / c_row.view_cnt;
			RAISE NOTICE '% / % = %', c_row.fav_cnt, c_row.view_cnt, conversion;
			sum = sum + conversion;
		END IF;
	END LOOP;
	
	IF cnt = 0 THEN
		RAISE EXCEPTION 'На неделе week_id=% нет данных о пользователях из %', get_stats.week_id, get_stats.locality;
	END IF;
	
	res = sum / analyze_cnt;
	RAISE NOTICE 'sum_conv = %, cnt = %, avg_conv = %', sum, analyze_cnt, res;
	
	RETURN res;
END;
$$ LANGUAGE plpgsql;


select get_stats('Henryfort', 25)
select get_stats('Henryfortt', 25)
select get_stats('Henryfortt', 225)

-- комментарий после проверки: почему мы вообще что-то считаем из таблицы, предназначенной для аналитики?
-- эту статистику надо хранить в таблице сразу
-- функция бессмысленна

-- (?) преимущества функций над представлениями
-- (?) когда использовать курсоры (почти никогда)