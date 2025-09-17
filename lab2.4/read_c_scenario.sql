-- Уровень изоляции READ COMMITED


-- Проверка аномалии Dirty read и Nonrepeatable read

-- Dirty read (грязное чтение)
-- -- транзакция читает данные, записанные параллельной незавершённой транзакцией

-- Nonrepeatable read (неповторяемое чтение)
-- -- транзакция повторно читает те же данные, что и раньше, и обнаруживает, что они были изменены другой транзакцией (которая завершилась после первого чтения).

SET search_path TO public;											SET search_path TO public;
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;					BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT title, cost, currency FROM artworks WHERE artwork_id = 8;	
																	UPDATE artworks SET cost = cost + 4000 WHERE artwork_id = 8;
																	-- Увеличили цену
SELECT title, cost, currency FROM artworks WHERE artwork_id = 8;
-- Чтение в 1-й транзакции даёт старую цену. Аномалия Dirty read НЕ выполняется
																	COMMIT;
-- После завершения 2-й транзакции прочтутся уже обновлённые данные. Это значит, что аномалия Nonrepeatable read ВЫПОЛНЯЕТСЯ 															
SELECT title, cost, currency FROM artworks WHERE artwork_id = 8;
COMMIT;