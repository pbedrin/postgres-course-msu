-- Представление "произведение - место хранения"
CREATE TEMP VIEW artwork_location AS
    SELECT
        artworks.artwork_id,
        artworks.title,
        (SELECT location_id FROM storage_locations WHERE artworks.location_id = storage_locations.location_id) location_id,
        (SELECT title FROM storage_locations WHERE artworks.location_id = storage_locations.location_id) location_title
    FROM artworks;
	
SELECT * FROM artwork_location

-- Реализуем с помощью триггера проверку на существование локации при её обновлении у произведения

-- Создаём триггерную функцию
CREATE OR REPLACE FUNCTION artwork_relocation() RETURNS trigger AS $artwork_relocation$
	DECLARE new_location_id integer;
    BEGIN
		BEGIN
			SELECT location_id INTO STRICT new_location_id
			FROM storage_locations
			WHERE location_id = NEW.location_id;
		EXCEPTION
			WHEN no_data_found THEN
				RAISE EXCEPTION 'Не существует локации с location_id=%', NEW.location_id;
		END;
		UPDATE artworks
		SET location_id = new_location_id
		WHERE artwork_id = OLD.artwork_id;
        RETURN NEW;
    END;
$artwork_relocation$ LANGUAGE plpgsql;

-- Создаём триггер
CREATE TRIGGER artwork_relocation INSTEAD OF UPDATE ON artwork_location
FOR EACH ROW EXECUTE FUNCTION artwork_relocation();


-- Ошибка. Нет такой локации (44)
UPDATE artwork_location SET location_id = 44 WHERE artwork_id = 13;

-- Корректное изменение. "Аллигатор": ArtNow (8) -> Галерист Роберт Саймон (4)
UPDATE artwork_location SET location_id = 4 WHERE artwork_id = 13;

SELECT * FROM artwork_location WHERE artwork_id = 13