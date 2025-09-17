/* Составляем топ самых дорогих рейсов по стоиимости проданных билетов */
WITH flights_top_sales AS (
	SELECT flight_id,
		   SUM(amount) as flight_amount
	FROM ticket_flights
	GROUP BY flight_id
	ORDER BY flight_amount DESC
	LIMIT 100
)
/* Формируем столбцы: номер рейса, город отправления - прибытия, время, длит. полёта */
SELECT flight_id,
	   a1.city,
	   a2.city,
	   flights.actual_departure,
	   flights.actual_arrival,
	   actual_arrival - actual_departure as flight_time
FROM flights

/* Присоединяем небходимые для столбцов таблицы */
LEFT JOIN airports as a1
ON flights.departure_airport = a1.airport_code
LEFT JOIN airports as a2
ON flights.arrival_airport = a2.airport_code

/* Выбираем рейсы, входящие в топ дорогих, не отменённые */
WHERE flight_id in (SELECT flight_id FROM flights_top_sales)
AND (actual_arrival is not null)
AND (actual_departure is not null)

/* Сортировка по возрастанию времени полёта */
ORDER BY flight_time