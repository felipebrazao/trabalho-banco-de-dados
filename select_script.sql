-- Questão 1 : Quais jogos do gênero ‘RPG’ lançados nos últimos 6 meses têm ≥ 80% de avaliações positivas e ≥ 10.000 avaliações no total?

SELECT g.app_id, g.name, g.release_date, g.price, r.positive, r.negative, (r.positive + r.negative) AS total_reviews, ROUND((r.positive * 100.0) / (r.positive + r.negative), 2) AS positive_percentage
FROM games AS g
JOIN game_genres AS gg ON g.app_id = gg.app_id
JOIN genres AS gen ON gg.genre_id = gen.genre_id
JOIN reviews_data AS r ON g.app_id = r.app_id
WHERE gen.genre_name = 'RPG' AND g.release_date >= CURRENT_DATE - INTERVAL '6 months' AND (r.positive + r.negative) >= 10000 AND (r.positive * 1.0 / (r.positive + r.negative)) >= 0.80
ORDER BY positive_percentage DESC, total_reviews DESC;

-- Questão 2: Quais jogos “cross-platform” (Windows, Mac e Linux) custam ≤ 20 (na moeda do dataset) e têm média de jogo (average_playtime) ≥ 120 minutos?
SELECT g.app_id, g.name, g.price, ps.avg_playtime_forever
FROM games AS g
JOIN playtime_stats AS ps ON g.app_id = ps.app_id
WHERE g.price <= 20 AND ps.avg_playtime_forever >= 120 AND g.app_id IN 
(
SELECT gp2.app_id
FROM game_platforms AS gp2
JOIN platforms AS p2 ON gp2.platform_id = p2.platform_id
WHERE p2.platform_name IN ('Windows','Mac','Linux')
GROUP BY gp2.app_id
HAVING COUNT(DISTINCT p2.platform_name) = 3
)
GROUP BY g.app_id, g.name, g.price, ps.avg_playtime_forever
ORDER BY ps.avg_playtime_forever DESC, g.price ASC;

-- Questão 3: Quais desenvolvedores lançaram mais de 5 jogos nos últimos 12 meses e qual a média do score de avaliações desses lançamentos?
SELECT d.developer_id, d.developer_name, COUNT(DISTINCT g.app_id) AS games_launched, 
ROUND(AVG((r.positive * 100.0) /  NULLIF((r.positive + r.negative), 0))) AS avg_positive_score, ROUND(AVG(m.metacritic_score)) AS avg_metacritic_score,
SUM(r.positive + r.negative) AS total_reviews
FROM developers AS d
JOIN game_developers AS gd ON d.developer_id = gd.developer_id
JOIN games AS g ON gd.app_id = g.app_id
LEFT JOIN reviews_data AS r ON g.app_id = r.app_id
LEFT JOIN metacritic_data AS m ON g.app_id = m.app_id
WHERE g.release_date >= CURRENT_DATE - INTERVAL '12 months'
GROUP BY d.developer_id, d.developer_name
HAVING COUNT(DISTINCT g.app_id) > 5
ORDER BY avg_positive_score DESC, games_launched DESC;

-- Questão 4: Quantos jogos pagos lançados nos últimos 3 meses têm mediana de tempo de jogo (median_playtime) > 240 min, e quais são os 5 gêneros mais frequentes entre eles?
SELECT COUNT(*) AS total_games, AVG(g.price) AS avg_price, AVG(ps.median_playtime_forever) AS avg_median_playtime
FROM games g
JOIN playtime_stats ps ON g.app_id = ps.app_id
WHERE g.price > 0 AND g.release_date >= CURRENT_DATE - INTERVAL '3 months' AND ps.median_playtime_forever > 2;

SELECT gen.genre_name, COUNT(DISTINCT g.app_id) AS game_count, COUNT(DISTINCT g.app_id) * 100.0 / 
(
SELECT COUNT(*) 
FROM games AS g2
JOIN playtime_stats ps2 ON g2.app_id = ps2.app_id
WHERE g2.price > 0
AND g2.release_date >= CURRENT_DATE - INTERVAL '3 months'
AND ps2.median_playtime_forever > 240
) AS percentage
FROM games AS g
JOIN playtime_stats AS ps ON g.app_id = ps.app_id
JOIN game_genres AS gg ON g.app_id = gg.app_id
JOIN genres AS gen ON gg.genre_id = gen.genre_id
WHERE g.price > 0 AND g.release_date >= CURRENT_DATE - INTERVAL '3 months' AND ps.median_playtime_forever > 240
GROUP BY gen.genre_name
ORDER BY game_count DESC
LIMIT 5;

-- Questão 5: Qual é o “top 1” de tags mais frequente entre os 100 jogos com melhor score de avaliação (considerando proporção positivas/(positivas+negativas)) nos últimos 6 meses?
SELECT t.tag_name, COUNT(*) AS quantidade_jogos
FROM games AS g
JOIN reviews_data r ON g.app_id = r.app_id
JOIN game_tags gt ON g.app_id = gt.app_id
JOIN tags t ON gt.tag_id = t.tag_id
WHERE g.release_date >= CURRENT_DATE - INTERVAL '6 months' AND (r.positive + r.negative) >= 50 AND g.app_id IN 
(
SELECT g2.app_id
FROM games g2
JOIN reviews_data r2 ON g2.app_id = r2.app_id
WHERE g2.release_date >= CURRENT_DATE - INTERVAL '6 months'
AND (r2.positive + r2.negative) >= 50
ORDER BY (r2.positive::DECIMAL / (r2.positive + r2.negative)) DESC
LIMIT 100
)
GROUP BY t.tag_name
ORDER BY quantidade_jogos DESC
LIMIT 1;
