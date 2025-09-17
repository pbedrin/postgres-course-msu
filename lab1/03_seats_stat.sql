/* Запрашиваем модели самолётов, считаем в каждом число категорий,
   считаем количество мест каждой категории */
SELECT a.model as aircraft_model,
	   COUNT(DISTINCT s.fare_conditions) as seats_categories,
	   COUNT(s.seat_no) as seats_count,
	   COUNT(CASE WHEN s.fare_conditions = 'Economy' THEN 1 END) as economy,
	   COUNT(CASE WHEN s.fare_conditions = 'Comfort' THEN 1 END) as comfort,
	   COUNT(CASE WHEN s.fare_conditions = 'Business' THEN 1 END) as business   
FROM aircrafts_data as a

/* Присоединяем таблицу мест */
LEFT JOIN seats as s
ON s.aircraft_code = a.aircraft_code

/* Группируем по моделям самолётов */
GROUP BY aircraft_model

/* Выбрать самолёты, где число мест Бизнес удовл. условию */
/* HAVING COUNT(CASE WHEN s.fare_conditions = 'Business' THEN 1 END) > 12 */

/* Сортировка по возрастанию количества мест */
ORDER BY seats_count
