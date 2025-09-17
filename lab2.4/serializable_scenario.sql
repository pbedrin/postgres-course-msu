-- Уровень изоляции SERIALIZABLE


-- Проверка аномалии Phantom Read

-- Phantom Read (фантомное чтение)
-- -- транзакция повторно выполняет запрос, возвращающий набор строк для некоторого условия, и обнаруживает, 
-- -- что набор строк, удовлетворяющих условию, изменился из-за транзакции, завершившейся за это время

SET search_path TO public;											SET search_path TO public;
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;						BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
-- Выберем все работы из магазина ArtNow							
SELECT artworks.artwork_id, artworks.title, storage_locations.location_id, storage_locations.title FROM artworks JOIN storage_locations USING(location_id) WHERE storage_locations.title = 'ArtNow';

-- Выберем все работы у Галериста Роберта Саймона
SELECT artworks.artwork_id, artworks.title, storage_locations.location_id, storage_locations.title FROM artworks JOIN storage_locations USING(location_id) WHERE storage_locations.title = 'Галерист Роберт Саймон';
																	
																	-- [Сделать те же селекты]

																	-- Работа "Аллигатор" (artwork_id=13) из ArtNow перешла в хранение галеристу
																	UPDATE artworks SET location_id = 4 WHERE artwork_id = 13;
																	COMMIT;

-- [Сделать те же селекты]											-- [Сделать те же селекты]
-- В 1-й транзакции данные по картинам в магазине и у галериста не изменились. Аномалия Phantom Read НЕ выполняется.
COMMIT;