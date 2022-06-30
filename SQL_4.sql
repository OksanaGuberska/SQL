-- 1. Напишите запрос с EXISTS, позволяющий вывести данные обо всех студентах, 
--    обучающихся в вузах с рейтингом не попадающим в диапазон от 488 до 571
SELECT * 
FROM STUDENTS S
WHERE EXISTS
(SELECT * 
FROM UNIVERSITIES U
WHERE NOT RATING BETWEEN 488 AND 571
AND U. ID = S. UNIV_ID)

-- 2. Напишите запрос с EXISTS, выбирающий всех студентов, для которых в том же городе, 
--    где живет и учится студент, существуют другие университеты, в которых он не учится.
SELECT *
FROM STUDENTS S
WHERE EXISTS 
(SELECT CITY
FROM UNIVERSITIES U
WHERE U.CITY = S.CITY AND U.ID = S. UNIV_ID)
AND EXISTS (SELECT CITY
FROM UNIVERSITIES U
WHERE U.CITY = S.CITY AND U.ID <> S. UNIV_ID)


-- 3. Напишите запрос, выбирающий из таблицы SUBJECTS данные о названиях предметов обучения, 
--    по которым были успешно сданы экзамены более чем 12 студентами, за первые 10 дней сессии. 
--    Используйте EXISTS. Примечание: по возможности выходная выборка не должна учитывать
--    пересдач.
SELECT *
FROM SUBJECTS SJ
WHERE EXISTS (
SELECT EM.SUBJ_ID, COUNT(*)
FROM EXAM_MARKS EM
WHERE EM.EXAM_DATE<(SELECT MIN(EXAM_DATE)+10 FROM EXAM_MARKS) AND EM.MARK>2AND SJ.ID=EM.SUBJ_ID
AND EXISTS (SELECT EM1.STUDENT_ID, EM1.SUBJ_ID 
FROM EXAM_MARKS EM1
WHERE EM1.SUBJ_ID=EM.SUBJ_ID AND EM.STUDENT_ID=EM1.STUDENT_ID
GROUP BY  EM1.STUDENT_ID, EM1.SUBJ_ID
HAVING COUNT (*)=1)
GROUP BY SUBJ_ID
HAVING COUNT(*)>12)

SELECT * FROM SUBJECTS SJ 
WHERE EXISTS(
SELECT *
FROM
(SELECT EM.STUDENT_ID, EM.SUBJ_ID, MIN(MARK) MARK
FROM EXAM_MARKS EM
WHERE EM.EXAM_DATE< (SELECT MIN(EXAM_DATE)+10 FROM EXAM_MARKS)
GROUP BY EM.STUDENT_ID, EM.SUBJ_ID 
HAVING MIN(MARK)>2)Q
WHERE SJ.ID=Q.SUBJ_ID
HAVING COUNT (*)>12 )

-- 4. Напишите запрос EXISTS, выбирающий фамилии всех лекторов, преподающих в университетах
--    с рейтингом, превосходящим рейтинг каждого харьковского универа.
SELECT SURNAME
FROM LECTURERS L
WHERE EXISTS 
			(SELECT *
			FROM UNIVERSITIES U
			WHERE U. ID = L. UNIV_ID
			AND RATING > ALL (SELECT RATING FROM UNIVERSITIES WHERE CITY = 'Харьков'))
			
-- 5. Напишите 2 запроса, использующий ANY и ALL, выполняющий выборку данных о студентах, 
--    у которых в городе их постоянного местожительства нет университета.
SELECT *
FROM STUDENTS S
WHERE NOT EXISTS (SELECT *
				FROM UNIVERSITIES U
				WHERE U.CITY = S. CITY)

SELECT *
FROM STUDENTS S
WHERE CITY = ALL (SELECT U. CITY
					FROM UNIVERSITIES U
					WHERE U.CITY = S. CITY)
AND NOT EXISTS (SELECT *
				FROM UNIVERSITIES U
				WHERE U.CITY = S. CITY)
-- ANY ??????



-- 6. Напишите запрос выдающий имена и фамилии студентов, которые получили
--    максимальные оценки в первый и последний день сессии.
--    Подсказка: выборка должна содержать по крайне мере 2х студентов.
SELECT * FROM STUDENTS
WHERE ID IN (
			SELECT STUDENT_ID 
			FROM EXAM_MARKS
			WHERE EXAM_DATE = (SELECT MIN(EXAM_DATE) FROM EXAM_MARKS)
			AND MARK = (
						SELECT MAX(MARK)
						FROM EXAM_MARKS
						WHERE EXAM_DATE = (SELECT MIN(EXAM_DATE) FROM EXAM_MARKS)))
		OR ID IN (
				  SELECT STUDENT_ID 
			FROM EXAM_MARKS
			WHERE EXAM_DATE = (SELECT MAX(EXAM_DATE) FROM EXAM_MARKS)
			AND MARK = (
						SELECT MAX(MARK)
						FROM EXAM_MARKS
						WHERE EXAM_DATE = (SELECT MAX(EXAM_DATE) FROM EXAM_MARKS)))

-- 7. Напишите запрос EXISTS, выводящий кол-во студентов каждого курса, которые успешно 
--    сдали экзамены, и при этом не получивших ни одной двойки.
SELECT COURSE, COUNT (ID) COUNT_OF_STUDENTS
FROM STUDENTS S
WHERE EXISTS (SELECT EM.STUDENT_ID
			FROM EXAM_MARKS EM
			WHERE EM.STUDENT_ID = S.ID
			GROUP BY EM. STUDENT_ID 
			 HAVING MIN(EM.MARK)>2)
GROUP BY COURSE
-- 8. Напишите запрос EXISTS на выдачу названий предметов обучения, 
--    по которым было получено максимальное кол-во оценок.
SELECT SJ.NAME
FROM SUBJECTS SJ
WHERE EXISTS (
				SELECT EM.SUBJ_ID
				FROM EXAM_MARKS EM
				WHERE SJ.ID=EM.SUBJ_ID
				GROUP BY EM.SUBJ_ID
				HAVING COUNT(*)= (
									SELECT MAX(TAB1.POINT)
									FROM
									(SELECT SUBJ_ID, COUNT (*) POINT
									FROM EXAM_MARKS
									GROUP BY SUBJ_ID)TAB1))

-- 9. Напишите команду, которая выдает список фамилий студентов по алфавиту, 
--    с колонкой комментарием: 'успевает' у студентов , имеющих все положительные оценки, 
--    'не успевает' для сдававших экзамены, но имеющих хотя бы одну 
--    неудовлетворительную оценку, и комментарием 'не сдавал' – для всех остальных.
--    Примечание: по возможности воспользуйтесь операторами ALL и ANY.
SELECT 'УСПЕВАЕТ' SUCCESSFUL, SURNAME SURNAME 
FROM STUDENTS S
WHERE 2 <> ALL (SELECT EM. MARK
				FROM
				EXAM_MARKS EM
				WHERE EM.STUDENT_ID = S.ID)
AND EXISTS (SELECT EM.MARK
			FROM EXAM_MARKS EM
			WHERE EM.STUDENT_ID = S.ID) 
			UNION
SELECT 'НЕ УСПЕВАЕТ' SUCCESSFUL, SURNAME SURNAME 
FROM STUDENTS S
WHERE 2 = ANY (SELECT EM. MARK
				FROM
				EXAM_MARKS EM
				WHERE EM.STUDENT_ID = S.ID)
AND EXISTS (SELECT EM.MARK
			FROM EXAM_MARKS EM
			WHERE EM.STUDENT_ID = S.ID) 
			UNION
SELECT 'НЕ СДАВАЛ' SUCCESSFUL, SURNAME SURNAME 
FROM STUDENTS S
WHERE NOT EXISTS (SELECT EM.MARK
			FROM EXAM_MARKS EM
			WHERE EM.STUDENT_ID = S.ID) 
			ORDER BY SURNAME


SELECT SURNAME,
CASE 
	WHEN ID IN(SELECT STUDENT_ID 
			   FROM EXAM_MARKS
			   GROUP BY STUDENT_ID
			   HAVING MIN (MARK)>2) THEN 'успевает'
	WHEN ID IN (SELECT STUDENT_ID
				FROM EXAM_MARKS
				WHERE MARK = 2) THEN 'не успевает'
	ELSE 'не сдавал' 
END
FROM STUDENTS
ORDER BY SURNAME
-- 10. Создайте объединение двух запросов, которые выдают значения полей 
--     NAME, CITY, RATING для всех университетов. Те из них, у которых рейтинг 
--     равен или выше 500, должны иметь комментарий 'Высокий', все остальные – 'Низкий'.
SELECT 'Высокий' Рейтинг, RATING, NAME, CITY
FROM UNIVERSITIES
WHERE RATING >=500
UNION
SELECT 'Низкий' Рейтинг, RATING, NAME, CITY
FROM UNIVERSITIES
WHERE NOT RATING >=500

-- 11. Напишите UNION запрос на выдачу списка фамилий студентов 4-5 курсов в виде 3х полей выборки:
--     SURNAME, 'студент <значение поля COURSE> курса', STIPEND
--     включив в список преподавателей в виде
--     SURNAME, 'преподаватель из <значение поля CITY>', <значение зарплаты в зависимости от города проживания (придумать самим)>
--     отсортировать по фамилии
--     Примечание: достаточно учесть 4-5 городов.
SELECT SURNAME, CONCAT('студент ', COURSE, ' курса'), STIPEND STIPEND_SALARY
FROM STUDENTS
WHERE COURSE IN(4,5)
UNION 
SELECT SURNAME, CONCAT('преподаватель из ', CITY),
CASE 
WHEN CITY = 'Днепр' THEN '5000.00'
WHEN CITY = 'Харьков' THEN '4500.00'
WHEN CITY = 'Львов' THEN '5600.00'
WHEN CITY = 'Киев' THEN '5700.00'
WHEN CITY = 'Херсон' THEN '4200.00'
ELSE '4100.00'
END SALARY
FROM LECTURERS
ORDER BY SURNAME

