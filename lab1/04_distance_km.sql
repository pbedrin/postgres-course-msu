/* Подключение расширения для поиска расстояния между координатами */
CREATE EXTENSION IF NOT EXISTS cube;
CREATE EXTENSION IF NOT EXISTS earthdistance;

/* Запрашиваем столбцы: номер рейса, город отправления-прибытия, расстояние между городами */
SELECT DISTINCT f.flight_no,
				a1.city as departure_city,
				a2.city as arrival_city,
				ROUND(CAST((a1.coordinates<@>a2.coordinates)*1.609 as numeric), 3)
					as city_distance
FROM flights as f

/* Присоединяем таблицы аэропорта */
LEFT JOIN airports as a1
ON f.departure_airport = a1.airport_code
LEFT JOIN airports as a2
ON f.arrival_airport = a2.airport_code

/* Сортируем по убыванию расстоянию между городами */
ORDER BY city_distance DESC

/* Оставляем ТОП-10*/
LIMIT 10