--QUESTION 1 a.
SELECT gd.name AS grade,
COUNT(CASE WHEN gd.id = 1 THEN '1'
WHEN gd.id = 2 THEN '2'
WHEN gd.id = 3 THEN '3'
WHEN gd.id = 4 THEN '4'
WHEN gd.id = 5 THEN '5' END) as students
FROM poem AS p INNER JOIN author AS a
ON p.author_id = a.id INNER JOIN grade AS gd
ON a.grade_id = gd.id INNER JOIN gender AS gr
ON a.gender_id = gr.id
GROUP BY gd.name
ORDER BY gd.name;



--QUESTION 1 b.

SELECT gd.name AS grade, gr.name AS gender,
COUNT(CASE WHEN gd.id = 1 THEN '1'
WHEN gd.id = 2 THEN '2'
WHEN gd.id = 3 THEN '3'
WHEN gd.id = 4 THEN '4'
WHEN gd.id = 5 THEN '5' END) as students
FROM poem AS p INNER JOIN author AS a
ON p.author_id = a.id INNER JOIN grade AS gd
ON a.grade_id = gd.id INNER JOIN gender AS gr
ON a.gender_id = gr.id
WHERE gr.name <> 'NA'
AND gr.name <> 'Ambiguous'
GROUP BY gd.name, gr.name
ORDER BY gd.name, gr.name;


--QUESTION 1 c.
--There seems to be a lot more female poets to male poets across the grades



--QUESTION 2.
SELECT COUNT(CASE WHEN text ILIKE '%death%' THEN 'death' END) AS death_poem_count, 
		COUNT(CASE WHEN text ILIKE '%love%' THEN 'love' END) AS love_poem_count,
		ROUND(AVG(CASE WHEN text ILIKE '%death%' THEN char_count END), 2) AS avg_death_poem_char,
		ROUND(AVG(CASE WHEN text ILIKE '%love%' THEN char_count END), 2) AS avg_love_poem_char
			FROM poem;



--QUESTION 3 a.
--It looks like anger has the longest poems, while joy has the shortest
SELECT DISTINCT e.id AS emo_id, e.name AS emotion, 
		AVG(p.char_count) OVER(PARTITION BY e.id) AS avg_char_count,
		AVG(pe.intensity_percent) OVER(PARTITION BY e.id) AS avg_intensity
		FROM poem AS p INNER JOIN poem_emotion AS pe
		ON p.id = pe.poem_id INNER JOIN emotion AS e
		ON pe.emotion_id = e.id;





--QUESTION 3 b. the most joyful poem is about a dog.
--I do not believe they were all classified correctly.


 WITH four_emotions AS (SELECT DISTINCT e.id AS emo_id, e.name AS emotion,
						AVG(p.char_count) OVER(PARTITION BY e.id) AS avg_char_count,
						AVG(pe.intensity_percent) OVER(PARTITION BY e.id) AS avg_intensity
						FROM poem AS p INNER JOIN poem_emotion AS pe
						ON p.id = pe.poem_id INNER JOIN emotion AS e
						ON pe.emotion_id = e.id)


	SELECT ROUND(fe.avg_char_count, 2) AS avg_char_count, p.char_count, 
	p.title AS poem_title, p.text AS poem_text, e.name AS emo, 
	pe.intensity_percent AS poem_intensity,
	CASE WHEN p.char_count >= fe.avg_char_count THEN 'longer than avg'
		ELSE 'shorter than avg' END AS poem_length
		FROM poem AS p INNER JOIN poem_emotion AS pe
		ON p.id = pe.poem_id INNER JOIN emotion AS e
		ON pe.emotion_id = e.id INNER JOIN four_emotions AS fe
		ON e.id = fe.emo_id
			WHERE e.name = 'Joy'
			ORDER BY poem_intensity DESC
			LIMIT 5;






--QUESTION 4 a. 5th graders write the angriest poems
WITH top_5_angry_poems_5th_grade AS (SELECT p.title, p.text, pe.intensity_percent, grade.name AS grade, 
									gender.name AS gender
									FROM poem AS p INNER JOIN poem_emotion AS pe
									ON p.id = pe.poem_id INNER JOIN emotion AS e
									ON pe.emotion_id = e.id INNER JOIN author AS a
									ON p.author_id = a.id INNER JOIN grade
									ON a.grade_id = grade.id INNER JOIN gender
									ON a.gender_id = gender.id
									WHERE e.name = 'Anger'
									AND grade.name = '5th Grade'
									ORDER BY pe.intensity_percent DESC
									LIMIT 5),


top_5_angry_poems_1st_grade		AS  (SELECT p.title, p.text, pe.intensity_percent, grade.name AS grade, 
									gender.name AS gender
									FROM poem AS p INNER JOIN poem_emotion AS pe
									ON p.id = pe.poem_id INNER JOIN emotion AS e
									ON pe.emotion_id = e.id INNER JOIN author AS a
									ON p.author_id = a.id INNER JOIN grade 
									ON a.grade_id = grade.id INNER JOIN gender
									ON a.gender_id = gender.id
									WHERE e.name = 'Anger'
									AND grade.name = '1st Grade'
									ORDER BY pe.intensity_percent DESC
									LIMIT 5)

SELECT brian.grade
FROM (SELECT ROUND(AVG(intensity_percent), 2) AS avg_intensity,  grade
		FROM top_5_angry_poems_5th_grade
		GROUP BY grade
		UNION ALL
		SELECT ROUND(AVG(intensity_percent), 2) AS avg_intensity, grade
		FROM top_5_angry_poems_1st_grade
		GROUP BY grade) AS brian
		ORDER BY avg_intensity DESC
		LIMIT 1;

--QUESTION 4 b.
WITH top_5_angry_poems_5th_grade AS (SELECT p.title, p.text, 
									pe.intensity_percent, grade.name AS grade, gender.name AS gender
									FROM poem AS p INNER JOIN poem_emotion AS pe
									ON p.id = pe.poem_id INNER JOIN emotion AS e
									ON pe.emotion_id = e.id INNER JOIN author AS a
									ON p.author_id = a.id INNER JOIN grade
									ON a.grade_id = grade.id INNER JOIN gender
									ON a.gender_id = gender.id
									WHERE e.name = 'Anger'
									AND grade.name = '5th Grade'
									ORDER BY pe.intensity_percent DESC
									LIMIT 5),


top_5_angry_poems_1st_grade		AS  (SELECT p.title, p.text,
									 pe.intensity_percent, grade.name AS grade, gender.name AS gender
									FROM poem AS p INNER JOIN poem_emotion AS pe
									ON p.id = pe.poem_id INNER JOIN emotion AS e
									ON pe.emotion_id = e.id INNER JOIN author AS a
									ON p.author_id = a.id INNER JOIN grade 
									ON a.grade_id = grade.id INNER JOIN gender
									ON a.gender_id = gender.id
									WHERE e.name = 'Anger'
									AND grade.name = '1st Grade'
									ORDER BY pe.intensity_percent DESC
									LIMIT 5)


SELECT grade, COUNT(CASE WHEN gender = 'Male' THEN 'male' END) AS male_studends,
	COUNT(CASE WHEN gender = 'Female' THEN 'female' END) AS female_students,
	COUNT(CASE WHEN gender = 'NA' THEN 'na' END) AS unknown
	FROM top_5_angry_poems_5th_grade
	GROUP BY grade
	UNION ALL
SELECT grade, COUNT(CASE WHEN gender = 'Male' THEN 'male' END) AS male_studends,
	COUNT(CASE WHEN gender = 'Female' THEN 'female' END) AS female_students,
	COUNT(CASE WHEN gender = 'NA' THEN 'na' END) AS unknown
	FROM top_5_angry_poems_1st_grade
	GROUP BY grade;



--QUESTION 4 c. CHEESE?




--QUESTION 5.
