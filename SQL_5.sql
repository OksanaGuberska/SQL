-- 1. Напишите запрос, выдающий список фамилий преподавателей английского
--    языка с названиями университетов, в которых они преподают.
--    Отсортируйте запрос по городу, где расположен университ, а
--    затем по фамилии лектора.

SELECT LECT. SURNAME, U.NAME
FROM LECTURERS LECT 
INNER JOIN UNIVERSITIES U 
ON LECT. UNIV_ID = U. ID
INNER JOIN SUBJ_LECT SL
ON LECT.ID = SL. LECTURER_ID 
INNER JOIN SUBJECTS S
ON S.NAME = 'Английский' AND S.ID = SL. SUBJ_ID
ORDER BY U.CITY, LECT.SURNAME 


-- 2. Напишите запрос, который выполняет вывод данных о фамилиях, сдававших экзамены 
--    студентов, учащихся в Б.Церкви, вместе с наименованием каждого сданного ими предмета, 
--    оценкой и датой сдачи.
SELECT S.SURNAME, SUBJ.NAME, EM.MARK, EM.EXAM_DATE DATE 
FROM STUDENTS S
INNER JOIN UNIVERSITIES U
ON S. UNIV_ID = U.ID AND U.CITY = 'Белая Церковь'
INNER JOIN EXAM_MARKS EM 
ON EM.STUDENT_ID = S. ID
INNER JOIN SUBJECTS SUBJ 
ON SUBJ.ID= EM.SUBJ_ID

-- 3. Используя оператор JOIN, выведите объединенный список городов с указанием количества 
--    учащихся в них студентов и преподающих там же преподавателей.

SELECT  U. CITY city, COUNT (DISTINCT S.ID)qty_stu,COUNT(DISTINCT L.ID)qty_lec
FROM UNIVERSITIES U
LEFT OUTER JOIN STUDENTS S ON U.ID = S. UNIV_ID 
LEFT OUTER JOIN LECTURERS L ON U.ID = L.UNIV_ID 
GROUP BY U.CITY

--АБО

SELECT A.*, B.qty_lec
FROM
(SELECT  U. CITY city, COUNT (S.ID)qty_stu
FROM UNIVERSITIES U
LEFT OUTER JOIN STUDENTS S 
ON U.ID = S. UNIV_ID 
GROUP BY U.CITY) A
JOIN
(SELECT  U. CITY city, COUNT(L.ID)qty_lec
FROM UNIVERSITIES U
LEFT OUTER JOIN LECTURERS L 
ON U.ID = L.UNIV_ID 
GROUP BY U.CITY) B
ON A.CITY=B.CITY

-- 4. Напишите запрос который выдает фамилии всех преподавателей и наименование предметов,
--    которые они читают в КПИ
SELECT L. SURNAME, S.NAME
FROM LECTURERS L
INNER JOIN UNIVERSITIES U
ON L. UNIV_ID = U. ID
INNER JOIN SUBJ_LECT SL
ON L.ID = SL. LECTURER_ID 
INNER JOIN SUBJECTS S 
ON S.ID = SL.SUBJ_ID AND L.UNIV_ID = U.ID
WHERE U.NAME = 'КПИ'

-- 5. Покажите всех студентов-двоешников, кто получил только неудовлетворительные оценки (2) 
--    и по каким предметам, а также тех кто не сдал ни одного экзамена. 
--    В выходных данных должны быть приведены фамилии студентов, названия предметов и 
--    оценка, если оценки нет, заменить ее на прочерк.
SELECT S.SURNAME, ISNULL(SUBJ.NAME,'-') SUBJ, ISNULL(CONVERT(VARCHAR, EM.MARK),'-') MARK
FROM STUDENTS S
LEFT OUTER JOIN EXAM_MARKS EM 
ON S.ID = EM. STUDENT_ID
LEFT OUTER JOIN SUBJECTS SUBJ
ON SUBJ.ID = EM.SUBJ_ID
WHERE 2 = ALL(SELECT EM.MARK
					FROM EXAM_MARKS EM 
					WHERE EM.STUDENT_ID = S.ID)

--АБО 
SELECT S.SURNAME, ISNULL(SJ.NAME,'-') SUBJ, ISNULL(CONVERT(VARCHAR, EM.MARK),'-') MARK
FROM STUDENTS S
	 LEFT JOIN EXAM_MARKS EM 
			ON EM.STUDENT_ID=S.ID
	 LEFT JOIN SUBJECTS SJ 
			ON SJ.ID=EM.SUBJ_ID
WHERE S.ID IN (SELECT STUDENT_ID
			   FROM EXAM_MARKS
			   GROUP BY STUDENT_ID
			   HAVING AVG(MARK)=2)
OR S.ID NOT IN (SELECT STUDENT_ID FROM EXAM_MARKS)
ORDER BY S.SURNAME

-- 6. Напишите запрос, который выполняет вывод списка университетов с рейтингом, 
--    превышающим 490, вместе со значением максимального размера стипендии, 
--    получаемой студентами в этих университетах.
SELECT U.NAME, MAX(S.STIPEND) MAX_STIPEND 
FROM UNIVERSITIES U
INNER JOIN STUDENTS S
ON U.ID = S.UNIV_ID
WHERE U.RATING > 490 
GROUP BY U.NAME 

-- 7. Расчитать средний бал по оценкам студентов для каждого университета, 
--    умноженный на 100, округленный до целого, и вычислить разницу с текущим значением
--    рейтинга университета.

SELECT U.NAME, CAST(AVG((EM.MARK)*100)AS decimal) NEW_RATING, U.RATING-(CAST(AVG((EM.MARK)*100)AS decimal)) DELTA
FROM UNIVERSITIES U
INNER JOIN STUDENTS S 
ON U.ID = S.UNIV_ID 
INNER JOIN EXAM_MARKS EM 
ON EM.STUDENT_ID=S.ID 
GROUP BY U.NAME, RATING

-- 8. Написать запрос, выдающий список всех фамилий лекторов из Киева попарно. 
--    При этом не включать в список комбинации фамилий самих с собой,
--    то есть комбинацию типа "Иванов-Иванов", а также комбинации фамилий, 
--    отличающиеся порядком следования, т.е. включать лишь одну из двух 
--    комбинаций типа "Иванов-Петров" или "Петров-Иванов".
SELECT CONCAT(A.SURNAME,' - ', B.SURNAME) PAIRS
FROM LECTURERS A, LECTURERS B  
WHERE A.CITY = 'Киев' AND B.CITY='Киев' AND A.ID>B.ID 

-- 9. Выдать информацию о всех университетах, всех предметах и фамилиях преподавателей, 
--    если в университете для конкретного предмета преподаватель отсутствует, то его фамилию
--    вывести на экран как прочерк '-' (воспользуйтесь ф-ей isnull)

SELECT U.NAME, S.NAME, ISNULL((SELECT L.SURNAME FROM LECTURERS L JOIN SUBJ_LECT SL ON SL.LECTURER_ID = L.ID
					   WHERE U.ID = L.UNIV_ID AND SL.SUBJ_ID=S.ID),'-')
FROM UNIVERSITIES U, SUBJECTS S



SELECT U.NAME, S.NAME, ISNULL(Q.SURNAME,'-') LECT_SURNAME
FROM UNIVERSITIES U 
	 CROSS JOIN SUBJECTS S
	 LEFT JOIN (SELECT * FROM LECTURERS L JOIN SUBJ_LECT SL ON SL.LECTURER_ID=L.ID)Q
	 ON Q.SUBJ_ID = S.ID AND Q.UNIV_ID = U.ID


-- 10. Кто из преподавателей и сколько поставил пятерок за свой предмет?
SELECT L.SURNAME, COUNT(EM.MARK) FIVE
FROM STUDENTS S
INNER JOIN EXAM_MARKS EM 
ON EM.STUDENT_ID= S.ID 
INNER JOIN SUBJECTS SJ
ON SJ.ID=EM.SUBJ_ID
INNER JOIN UNIVERSITIES U 
ON U.ID=S.UNIV_ID
INNER JOIN LECTURERS L
ON L.UNIV_ID=S.UNIV_ID
INNER JOIN SUBJ_LECT SL 
ON L.ID=SL.LECTURER_ID AND EM.SUBJ_ID=SL.SUBJ_ID 
GROUP BY EM.MARK, L.SURNAME
HAVING EM.MARK = 5
-- 11. Добавка для уверенных в себе студентов: показать кто из студентов какие экзамены
--     еще не сдал.
SELECT S.SURNAME, S. NAME, SUBJ.NAME SUBJECT FROM STUDENTS S, SUBJECTS SUBJ
EXCEPT 
SELECT S.SURNAME, S.NAME, SUBJ.NAME SUBJECT 
FROM STUDENTS S 
LEFT OUTER JOIN EXAM_MARKS EM
ON EM.STUDENT_ID=S.ID
LEFT OUTER JOIN SUBJECTS SUBJ
ON SUBJ.ID=EM.SUBJ_ID 
WHERE MARK>2


SELECT S.SURNAME,SJ.NAME, QWE. *
FROM STUDENTS S
	CROSS JOIN SUBJECTS SJ
	 LEFT JOIN 
(SELECT EM.STUDENT_ID, EM.SUBJ_ID
FROM EXAM_MARKS EM
WHERE EM.MARK >2)QWE 
	 ON QWE.STUDENT_ID=S.ID AND QWE.SUBJ_ID=SJ.ID
	 WHERE QWE.SUBJ_ID IS NULL




