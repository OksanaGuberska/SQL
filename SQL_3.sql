-- 1. Напишите запрос для таблицы EXAM_MARKS, выдающий даты, для которых средний балл 
--    находиться в диапазоне от 4.22 до 4.77. Формат даты для вывода на экран: 
--    день месяць, например, 05 Jun.

SELECT SUBSTRING (CONVERT (VARCHAR, EXAM_DATE, 106), 1,6)
FROM EXAM_MARKS
GROUP BY EXAM_DATE 
HAVING AVG (MARK) BETWEEN 4.22 AND 4.77 


SELECT LEFT(CONVERT(VARCHAR,EXAM_DATE, 106),6)
FROM EXAM_MARKS
GROUP  BY EXAM_DATE
HAVING AVG(MARK) BETWEEN 4.22 AND 4.77

-- 2. Напишите запрос, который по таблице EXAM_MARKS позволяет найти промежуток времени (*),
--    который занял у студента в течении его сессии, кол-во всех попыток сдачи экзаменов, 
--    а также их максимальные и минимальные оценки. В выборке дожлен присутствовать 
--    идентификатор студента.
--    Примечание: таблица оценок - покрывает одну сессию, (*) промежуток времени -
--    количество дней, которые провел студент на этой сессии - от первого до последнего экзамена?

SELECT STUDENT_ID stud_id, CAST(MAX(EXAM_DATE)-MIN(EXAM_DATE)+1 AS INT) ses_days, COUNT (EXAM_DATE) count_exam, MIN (MARK)min_mark, MAX (MARK) max_mark
FROM EXAM_MARKS 
GROUP BY STUDENT_ID


-- 3. Покажите список идентификаторов студентов, которые имеют пересдачи. 
SELECT STUDENT_ID 
FROM EXAM_MARKS
GROUP BY STUDENT_ID, SUBJ_ID
HAVING COUNT (SUBJ_ID) >1
ORDER BY STUDENT_ID


-- 4. Напишите запрос, отображающий список предметов обучения, вычитываемых за самый короткий 
--    промежуток времени, отсортированный в порядке убывания семестров. Поле семестра в 
--    выходных данных должно быть первым, за ним должны следовать наименование и 
--    идентификатор предмета обучения.

SELECT SEMESTER, NAME, ID
FROM SUBJECTS
WHERE HOURS = (SELECT MIN(HOURS)
			   FROM SUBJECTS)
ORDER BY SEMESTER DESC


-- 5. Напишите запрос с подзапросом для получения данных обо всех положительных оценках(4, 5) Марины 
--    Шуст (предположим, что ее персональный номер неизвестен), идентификаторов предметов и дат 
--    их сдачи.

SELECT MARK, SUBJ_ID, CONVERT (VARCHAR,EXAM_DATE, 104)
FROM EXAM_MARKS
WHERE STUDENT_ID = 
					(SELECT ID
					FROM STUDENTS 
					WHERE SURNAME = 'Шуст' AND NAME = 'Марина') 
					AND MARK >= 4


-- 6. Покажите сумму баллов для каждой даты сдачи экзаменов, при том, что средний балл не равен 
--    среднему арифметическому между максимальной и минимальной оценкой. Данные расчитать только 
--    для студенток. Результат выведите в порядке убывания сумм баллов, а дату в формате dd/mm/yyyy.

SELECT SUM (MARK) MARKS, CONVERT(VARCHAR,EXAM_DATE, 103)
FROM EXAM_MARKS
WHERE STUDENT_ID IN 
					(SELECT ID
					 FROM STUDENTS
					 WHERE GENDER = 'F') 
GROUP BY EXAM_DATE 
HAVING AVG (MARK) <> (MIN (MARK)+MAX (MARK))/2
ORDER BY MARKS DESC

-- 7. Покажите имена и фамилии всех студентов, у которых средний балл по предметам
--    с идентификаторами 1 и 2 превышает средний балл этого же студента
--    по всем остальным предметам. Используйте вложенные подзапросы.
SELECT NAME, SURNAME 
FROM STUDENTS
WHERE ID IN (SELECT E1.STUDENT_ID
			 FROM EXAM_MARKS E1
			 WHERE  E1.SUBJ_ID IN(1,2)
			 GROUP BY E1.STUDENT_ID
			 HAVING AVG (MARK)> ISNULL(
									   (SELECT AVG(E2.MARK)
									   FROM EXAM_MARKS E2
									   WHERE E2.SUBJ_ID NOT IN(1,2)
									   GROUP BY E2.STUDENT_ID
									   HAVING E2.STUDENT_ID=E1.STUDENT_ID),0))


-- 8. Напишите запрос, выполняющий вывод общего суммарного и среднего баллов каждого 
--    экзаменованого второкурсника, его идентификатор и кол-во полученных оценок при условии, 
--    что он успешно сдал 3 и более предметов.

SELECT STUDENT_ID, SUM (MARK) TOTAL_MARK, AVG (MARK) AVG_MARK, COUNT (MARK) MARK_QTY
FROM EXAM_MARKS
WHERE STUDENT_ID IN
(SELECT ID 
FROM  STUDENTS 
WHERE COURSE = 2)
GROUP BY STUDENT_ID
HAVING SUM (MARK)  > = 12



-- 9. Вывести названия всех предметов, средний балл которых превышает средний балл по всем 
--    предметам университетов г.Днепропетровска. Используйте вложенный подзапрос.

						 


