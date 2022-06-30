-- 1. Создайте представление для получения сведений обо всех студентах, 
--    круглых отличниках. Напишите запрос "расжалующий" их в троешников, 
--    в каком случае сработает такой скрипт.
begin transaction

CREATE VIEW GOOD_STUDENTS AS 
SELECT S.ID, S.SURNAME, S.NAME, EM.MARK 
FROM STUDENTS S
INNER JOIN EXAM_MARKS EM
ON EM.STUDENT_ID=S.ID
WHERE 5=ALL(SELECT EM.MARK
			FROM EXAM_MARKS EM
			WHERE EM.STUDENT_ID=S.ID)


SELECT * FROM GOOD_STUDENTS

UPDATE GOOD_STUDENTS
SET MARK =3
WHERE MARK=5

--ОСКІЛЬКИ НА ЦЕЙ ЗАПИТ НАКЛАДЕНО ОБМЕЖЕННЯ (ЛИШЕ СТУДЕНТИ У ЯКИХ УСІ 5), ПІСЛЯ ВНЕСЕНИХ ЗМІН ВІН НЕ БУДЕ ВИВОДИТИ НІЧОГО -  У НАС НЕ ЗАЛИШИЛОСЬ СТУДЕНТІВ У ЯКИХ ВСІ П*ЯТІРКИ.

-- 2. Создайте представление для получения сведений о количестве студентов 
--    обучающихся в каждом городе.
CREATE VIEW CITY_STUD AS
SELECT U.CITY, COUNT (*) STUD_QUANT 
FROM STUDENTS S 
RIGHT OUTER JOIN UNIVERSITIES U
ON S.UNIV_ID=U.ID
GROUP BY U.CITY

SELECT * FROM CITY_STUD

-- 3. Создайте представление для получения сведений по каждому студенту: 
--    его ID, фамилию, имя, средний и общий баллы.
CREATE VIEW STUDENTS_INFO AS
SELECT S.ID, S.SURNAME, S.NAME, AVG(MARK) AVG_MARK, SUM (MARK) SUM_MARK
FROM STUDENTS S
INNER JOIN EXAM_MARKS EM
ON S.ID=EM.STUDENT_ID
GROUP BY S.ID, S.NAME, S.SURNAME

SELECT * FROM STUDENTS_INFO 

-- 4. Создайте представление для получения сведений о студенте фамилия, 
--    имя, а также количестве экзаменов, которые он сдал, и количество,
--    которое ему еще нужно досдать.
CREATE VIEW EXAMS_STATUS AS
SELECT TAB1.NAME, TAB1.SURNAME, PASSSED_EXAMS, EXAMS_TO_PASS
FROM
(SELECT S.ID, S.NAME,S.SURNAME, COUNT(SJ.NAME) EXAMS_TO_PASS
FROM STUDENTS S, SUBJECTS SJ
WHERE NOT EXISTS (SELECT*
				  FROM EXAM_MARKS EM
				  WHERE EM.STUDENT_ID=S.ID AND EM.SUBJ_ID=SJ.ID AND EM.MARK>2)
				  GROUP BY S.ID, S.NAME,S.SURNAME )TAB1
	LEFT OUTER JOIN 
(SELECT S1.ID, S1.NAME, S1.SURNAME, COUNT(SJ1.NAME)PASSSED_EXAMS
FROM STUDENTS S1, SUBJECTS SJ1
WHERE EXISTS (SELECT*
				  FROM EXAM_MARKS EM1
				  WHERE EM1.STUDENT_ID=S1.ID AND EM1.SUBJ_ID=SJ1.ID AND EM1.MARK>2)
				   GROUP BY S1.ID, S1.NAME,S1.SURNAME )TAB2
ON TAB1.ID=TAB2.ID


SELECT * FROM EXAMS_STATUS

-- 5. Какие из представленных ниже представлений являются обновляемыми?


-- A. CREATE VIEW DAILYEXAM AS
--    SELECT DISTINCT STUDENT_ID, SUBJ_ID, MARK, EXAM_DATE
--    FROM EXAM_MARKS


-- B. CREATE VIEW CUSTALS AS
--    SELECT SUBJECTS.ID, SUM (MARK) AS MARK1
--    FROM SUBJECTS, EXAM_MARKS
--    WHERE SUBJECTS.ID = EXAM_MARKS.SUBJ_ID
--    GROUP BY SUBJECT.ID


-- C. CREATE VIEW THIRDEXAM
--    AS SELECT *
--    FROM DAILYEXAM
--    WHERE EXAM_DATE = '2012/06/03'


-- D. CREATE VIEW NULLCITIES
--    AS SELECT ID, SURNAME, CITY
--    FROM STUDENTS
--    WHERE CITY IS NULL
--    OR SURNAME BETWEEN 'А' AND 'Д'
--    WITH CHECK OPTION


-- ТАБЛИЦІ D МОЖНА ЧАСТКОВО ЗМІНЮВАТИ, A ТА B - НІ, ОСКІЛЬКИ ТАМ Є DISTINCT I GROUP BY, С - НЕ МОЖНА ЗМІНИТИ ТОМУ ЩО ЦЕ ВИБІРКА З VIEW, ЯКА УЖЕ Є НЕМОДИФІКОВАНОЮ. 

-- 6. Создайте представление таблицы STUDENTS с именем STIP, включающее поля 
--    STIPEND и ID и позволяющее вводить или изменять значение поля 
--    стипендия, но только в пределах от 100 д о 500.

CREATE VIEW STIP AS
SELECT ID, STIPEND
FROM STUDENTS
WHERE STIPEND BETWEEN 100 AND 500
WITH CHECK OPTION

SELECT * FROM STIP