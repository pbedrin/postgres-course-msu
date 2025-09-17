-- Уровень изоляции READ UNCOMMITED


-- Проверка аномалии Lost update

-- Lost update (аномалия потерянных изменений)
-- -- две транзакции читают одну строку таблицы, затем 1-я транзакция изменяет эту строку, затем 2-я изменяет эту строку,
-- -- не учитывая изменений, сделанных в 1-й транзакции

SET search_path TO public;											SET search_path TO public;
BEGIN TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;					BEGIN TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;														BEGIN;
SELECT title, cost, currency FROM artworks WHERE artwork_id = 8; 	SELECT title, cost, currency FROM artworks WHERE artwork_id = 8;
UPDATE artworks SET cost = cost + 1000 WHERE artwork_id = 8;			
																	UPDATE artworks SET cost = cost + 4000 WHERE artwork_id = 8;
																	-- UPDATE не выполняется, ожидание завершения 1-й транзакции
																	
COMMIT;
																	-- После завершения 1-й транзакции UPDATE выполнится
																	-- (уже на изменённых в 1-й транзакции данных)
																	COMMIT;

-- Таким образом, цена работы увеличится на 1000+4000=5000. Аномалия Lost update НЕ выполняется


-- Проверка аномалии Dirty read

-- Dirty read (грязное чтение)
-- -- транзакция читает данные, записанные параллельной незавершённой транзакцией

SET search_path TO public;											SET search_path TO public;
BEGIN TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;					BEGIN TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT title, cost, currency FROM artworks WHERE artwork_id = 8;	
																	UPDATE artworks SET cost = cost + 4000 WHERE artwork_id = 8;
																	-- Увеличили цену
SELECT title, cost, currency FROM artworks WHERE artwork_id = 8;
-- Чтение в 1-й транзакции даёт старую цену. Аномалия Dirty read НЕ выполняется.
																	COMMIT;
-- Только после завершения 2-й транзакции прочтутся уже обновлённые данные:															
SELECT title, cost, currency FROM artworks WHERE artwork_id = 8;
COMMIT;