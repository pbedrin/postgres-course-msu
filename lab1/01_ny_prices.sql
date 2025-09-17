/* Запрос нужных столбцов */
SELECT f.flight_id,
	   ac.model as aircraft,
	   a1.city,
	   a2.city,
	   f.scheduled_departure,
	   f.scheduled_arrival,
	   f.scheduled_arrival - f.scheduled_departure as flight_time,
	   avg(tf.amount) FILTER (WHERE tf.fare_conditions = 'Economy') as avg_price
FROM flights as f

/* Присоединяем к рейсам таблицу "Аэропорты" (для выведения городов),
"Самолёты" (для выведения модели), "Билет-Рейс" для подсчёта средней стоимости */
LEFT JOIN airports as a1
ON f.departure_airport = a1.airport_code
LEFT JOIN airports as a2
ON f.arrival_airport = a2.airport_code
LEFT JOIN aircrafts_data as ac USING(aircraft_code)
LEFT JOIN ticket_flights as tf USING(flight_id)

/* Условие на интересующий маршрут и даты рейсов */
WHERE a1.city = 'Москва' AND a2.city = 'Петропавловск-Камчатский'
AND f.scheduled_arrival > timestamp '2016-12-25 00:00:00'
AND f.scheduled_arrival < timestamp '2017-01-10 00:00:00'

/* Группировка по рейсам */
GROUP BY f.flight_id, ac.model, a1.city, a2.city

/* Сортировка по возрастанию средней стоимости билета */
ORDER BY avg_price