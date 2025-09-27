-- 1) Inserir um desenvolvedor e relacionar ao jogo existente
INSERT INTO developers (developer_name, founded_year, country, website)
VALUES ('Future Games Studio', 2010, 'USA', 'https://futuregames.com')
ON CONFLICT (developer_name) DO NOTHING;

-- Relacionar desenvolvedor ao jogo existente (supondo developer_id = 1)
INSERT INTO game_developers (app_id, developer_id, role)
VALUES (1001, 1, 'primary')
ON CONFLICT (app_id, developer_id) DO NOTHING;

-- 2) Inserir uma categoria e relacionar ao jogo existente
INSERT INTO categories (category_name, category_type, description)
VALUES ('RPG', 'gameplay', 'Jogos de interpretação de personagens e narrativa.')
ON CONFLICT (category_name) DO NOTHING;

-- Relacionar categoria ao jogo (supondo category_id = 1)
INSERT INTO game_categories (app_id, category_id)
VALUES (1001, 1)
ON CONFLICT (app_id, category_id) DO NOTHING;

-- 3) Inserir um gênero e relacionar ao jogo
INSERT INTO genres (genre_name, description)
VALUES ('Sci-Fi', 'Jogos com temática de ficção científica.')
ON CONFLICT (genre_name) DO NOTHING;

INSERT INTO game_genres (app_id, genre_id, is_primary)
VALUES (1001, 1, TRUE)
ON CONFLICT (app_id, genre_id) DO NOTHING;

-- 4) Inserir uma plataforma e relacionar ao jogo
INSERT INTO platforms (platform_name, platform_code, description)
VALUES ('Windows', 'WIN', 'Plataforma Windows 10 e superiores.')

INSERT INTO game_platforms (app_id, platform_id, minimum_requirements, recommended_requirements, release_date)
VALUES (1001, 1, 'Intel i5, 8GB RAM, GTX 1050', 'Intel i7, 16GB RAM, RTX 2070', '2024-06-15')
ON CONFLICT (app_id, platform_id) DO NOTHING


-- select de jogos
SELECT * 
FROM games
WHERE app_id = 1001;
--select pra categoria de jogo 
SELECT gc.app_id, g.name AS game_name, c.category_id, c.category_name, c.category_type
FROM game_categories gc
JOIN categories c ON gc.category_id = c.category_id
JOIN games g ON gc.app_id = g.app_id
WHERE gc.app_id = 1001;

--select para generos de jogos
SELECT gg.app_id, g.name AS game_name, ge.genre_id, ge.genre_name, gg.is_primary
FROM game_genres gg
JOIN genres ge ON gg.genre_id = ge.genre_id
JOIN games g ON gg.app_id = g.app_id
WHERE gg.app_id = 1001;
--select pra componentes do PC e OS
SELECT gp.app_id, g.name AS game_name, p.platform_id, p.platform_name, gp.minimum_requirements, gp.recommended_requirements
FROM game_platforms gp
JOIN platforms p ON gp.platform_id = p.platform_id
JOIN games g ON gp.app_id = g.app_id
WHERE gp.app_id = 1001;





