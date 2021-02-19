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
ORDER BY gd.name;


--QUESTION 1 c.
--There seems to be a lot more female poets to male poets across the grades



--QUESTION 2.
SELECT DISTINCT p.title AS poem_title, p.text AS poem_text,
		p.char_count AS poem_length
		FROM poem AS p INNER JOIN poem_emotion AS pe
		ON p.id = pe.poem_id
		WHERE p.text ILIKE '%death'
		OR p.text ILIKE '%love';


--QUESTION 3 a.
--It looks like anger has the longest poems, while joy has the shortest
SELECT DISTINCT e.id AS emo_id, e.name AS emotion, 
		AVG(p.char_count) OVER(PARTITION BY e.id) AS avg_char_count,
		AVG(pe.intensity_percent) OVER(PARTITION BY e.id) AS avg_intensity
		FROM poem AS p INNER JOIN poem_emotion AS pe
		ON p.id = pe.poem_id INNER JOIN emotion AS e
		ON pe.emotion_id = e.id;





--QUESTION 3 b.


 WITH four_emotions AS (SELECT DISTINCT e.id AS emo_id, e.name AS emotion,
						AVG(p.char_count) OVER(PARTITION BY e.id) AS avg_char_count,
						AVG(pe.intensity_percent) OVER(PARTITION BY e.id) AS avg_intensity
						FROM poem AS p INNER JOIN poem_emotion AS pe
						ON p.id = pe.poem_id INNER JOIN emotion AS e
						ON pe.emotion_id = e.id)


	SELECT poem.title AS poem_title, poem.text AS poem_text
	FROM four_emotions
	WHERE emo_id = 1
	AND pe.intensity_percent >= avg_intensity;



