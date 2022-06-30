-- /* Везде, где необходимо данные придумать самостоятельно. */
--Для каждого задания (кроме 4-го) можете использовать конструкцию
-------------------------
-- начать транзакцию
begin transaction
-- проверка до изменений
SELECT * FROM EXAM_MARKS
-- изменения
-- insert into SUBJECTS (ID,NAME,HOURS,SEMESTER) values (25,'Этика',58,2),(26,'Астрономия',34,1)
-- insert into EXAM_MARKS ...
-- delete from EXAM_MARKS where SUBJ_ID in (...)
-- проверка после изменений
SELECT * FROM EXAM_MARKS --WHERE STUDENT_ID > 120
-- отменить транзакцию
rollback


-- 1. Необходимо добавить двух новых студентов для нового учебного 
--    заведения "Винницкий Медицинский Университет".
BEGIN TRANSACTION
SELECT * FROM UNIVERSITIES
INSERT INTO UNIVERSITIES
VALUES (16,'ВМУ',NULL, 'Винница')
SELECT * FROM UNIVERSITIES WHERE ID>15
INSERT INTO STUDENTS
VALUES (46, 'Демков', 'Андрей', 'm', 500, 1, NULL, '1990-12-01 00:00:00.000', 16), 
(47, 'Ивашова', 'Анастасия', 'f', 550, 2, 'Хмельницкий', '1999-12-28 00:00:00.000', 16)
SELECT *FROM STUDENTS WHERE ID>45
ROLLBACK


-- 2. Добавить еще один институт для города Ивано-Франковск, 
--    1-2 преподавателей, преподающих в нем, 1-2 студента,
--    а так же внести новые данные в экзаменационную таблицу.
BEGIN TRANSACTION
SELECT * FROM UNIVERSITIES
INSERT INTO UNIVERSITIES
VALUES (16,'ИФНМУ', 530, 'Ивано-Франковск')
SELECT * FROM UNIVERSITIES WHERE ID>15

SELECT *FROM LECTURERS
INSERT INTO LECTURERS
VALUES (26,'Кирилюк', 'СВ', 'Тернополь', 16),
(27, 'Егорова', 'АМ', 'Киев', 16)
SELECT * FROM LECTURERS WHERE UNIV_ID=16

SELECT * FROM STUDENTS
INSERT INTO STUDENTS
VALUES (46, 'Нестерчук', 'Диана', 'f', 650, 2, 'Львов', '2001-07-15', 16),
(47, 'Никитина', 'София', 'f', 600, 3, 'Луцк', NULL, 16)
SELECT * FROM STUDENTS WHERE UNIV_ID=16

SELECT * FROM EXAM_MARKS
INSERT INTO EXAM_MARKS
VALUES (46, 3,4, '2022-01-11'),
(46,1,3,'2022-01-08'),
(47,6,5,'2022-01-05'),
(47,3,5,'2021-12-27')
SELECT * FROM EXAM_MARKS WHERE ID>120

ROLLBACK
-- 3. Известно, что студенты Павленко и Пименчук перевелись в КПИ. 
--    Модифицируйте соответствующие таблицы и поля.
BEGIN TRANSACTION 
UPDATE STUDENTS
SET UNIV_ID = 1
WHERE SURNAME IN ('Павленко', 'Пименчук') 
SELECT UNIV_ID FROM STUDENTS WHERE SURNAME IN ('Павленко', 'Пименчук') 
ROLLBACK

-- 4. В учебных заведениях Украины проведена реформа и все студенты, 
--    у которых средний бал не превышает 3.5 балла - отчислены из институтов. 
--    Сделайте все необходимые удаления из БД.
--    Примечание: предварительно "отчисляемых" сохранить в архивационной таблице
BEGIN TRANSACTION
SELECT* FROM STUDENTS_ARCHIVE

INSERT INTO STUDENTS_ARCHIVE
SELECT * FROM STUDENTS S WHERE EXISTS
(SELECT  AVG(MARK) FROM EXAM_MARKS EM
GROUP BY STUDENT_ID
HAVING AVG(MARK)<=3.5 AND S.ID=EM.STUDENT_ID)

SELECT* FROM STUDENTS_ARCHIVE

DELETE FROM EXAM_MARKS WHERE STUDENT_ID IN (SELECT ID FROM STUDENTS_ARCHIVE) 
DELETE FROM STUDENTS WHERE ID IN (SELECT ID FROM STUDENTS_ARCHIVE) 
ROLLBACK


-- 5. Студентам со средним балом 4.75 начислить 12.5% к стипендии,
--    со средним балом 5 добавить 200 грн.
--    Выполните соответствующие изменения в БД.
BEGIN TRANSACTION
SELECT * FROM STUDENTS S WHERE EXISTS
(SELECT STUDENT_ID, AVG(MARK) FROM EXAM_MARKS EM
GROUP BY STUDENT_ID
HAVING AVG(MARK)=4.75 AND S.ID=EM.STUDENT_ID)

UPDATE STUDENTS
SET STIPEND=STIPEND*(100+12.5)/100
WHERE
ID IN (SELECT  STUDENT_ID FROM EXAM_MARKS EM
GROUP BY STUDENT_ID
HAVING AVG(MARK)=4.75)

SELECT * FROM STUDENTS S WHERE EXISTS
(SELECT STUDENT_ID, AVG(MARK) FROM EXAM_MARKS EM
GROUP BY STUDENT_ID
HAVING AVG(MARK)=5 AND S.ID=EM.STUDENT_ID)

UPDATE STUDENTS
SET STIPEND = STIPEND+200
WHERE
ID IN (SELECT  STUDENT_ID FROM EXAM_MARKS EM
GROUP BY STUDENT_ID
HAVING AVG(MARK)=5)

update students 
set STIPEND = case
				when id in (select student_id from EXAM_MARKS group by STUDENT_ID having avg(mark)=4.75) then stipend *1.125
				when id in (select student_id from EXAM_MARKS group by STUDENT_ID having avg(mark)=5) then stipend + 200
				else STIPEND
			end

SELECT * FROM STUDENTS WHERE ID IN(4,9,30,35)
ROLLBACK 

-- 6. Необходимо удалить все предметы, по котором не было получено ни одной оценки.
--    Если таковые отсутствуют, попробуйте смоделировать данную ситуацию. 
BEGIN TRANSACTION
INSERT INTO SUBJECTS (ID,NAME,HOURS,SEMESTER) VALUES (8,'Этика',58,2),(9,'Астрономия',34,1)

SELECT ID FROM SUBJECTS WHERE ID NOT IN (SELECT SUBJ_ID FROM EXAM_MARKS GROUP BY SUBJ_ID)

DELETE FROM SUBJECTS WHERE ID NOT IN (SELECT SUBJ_ID FROM EXAM_MARKS GROUP BY SUBJ_ID)

SELECT * FROM SUBJECTS

ROLLBACK 

-- 7. Лектор 3 ушел на пенсию, необходимо корректно удалить о нем данные.
BEGIN TRANSACTION
SELECT * FROM SUBJ_LECT

DELETE FROM SUBJ_LECT 
WHERE LECTURER_ID =(SELECT ID FROM LECTURERS WHERE ID=3)
DELETE FROM LECTURERS
WHERE SURNAME = 'Телегин'

SELECT* FROM LECTURERS 

ROLLBACK 
