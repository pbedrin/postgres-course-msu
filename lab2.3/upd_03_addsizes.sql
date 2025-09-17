-- Картина "В лесу. Из леса с грибами" (artworkd_id = 20)
SELECT
	artworks.artwork_id,
	artworks.title,
	artworks.width,
	artworks.height,
	artworks.length,
	artworks.measure_unit
FROM artworks
WHERE artworks.artwork_id = 20

-- Отсутствуют размеры картины. Добавим...
UPDATE artworks
SET
	width = 38,
	height = 24
WHERE artwork_id = 20
-- Ошибка. Ограничение-проверка "measure_unit_check" - нельзя добавлять размеры без указания единицы измерения

-- Укажем единицы измерения
UPDATE artworks
SET
	width = 38,
	height = 24,
	measure_unit = 'cm'
WHERE artwork_id = 20
RETURNING
	artworks.artwork_id,
	artworks.title,
	artworks.width,
	artworks.height,
	artworks.length,
	artworks.measure_unit