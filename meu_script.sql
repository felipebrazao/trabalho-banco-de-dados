CREATE TYPE category_type_enum AS ENUM ('gameplay', 'platform', 'social', 'technical');
CREATE TYPE role_enum AS ENUM ('primary', 'secondary', 'contractor');
CREATE TYPE role_publisher_enum AS ENUM ('primary', 'secondary', 'distributor');
CREATE TYPE tag_category_enum AS ENUM ('gameplay', 'theme', 'feature', 'style');
CREATE TYPE platform_name_enum AS ENUM ('Windows', 'Mac', 'Linux', 'SteamOS');
CREATE TYPE movie_type_enum AS ENUM ('trailer', 'gameplay', 'cinematic');
CREATE TYPE review_summary_enum AS ENUM ('Overwhelmingly Positive', 'Very Positive', 'Positive', 'Mostly Positive', 'Mixed', 'Mostly Negative', 'Negative', 'Very Negative', 'Overwhelmingly Negative');
CREATE TYPE support_level_enum AS ENUM ('interface', 'subtitles', 'full_text');
CREATE TYPE audio_quality_enum AS ENUM ('full', 'partial', 'cutscenes_only');

CREATE TABLE games (
    app_id INTEGER PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    release_date DATE,
    estimated_owners VARCHAR(50),
    peak_ccu INTEGER DEFAULT 0,
    required_age INTEGER DEFAULT 0,
    price DECIMAL(10,2) DEFAULT 0.00,
    discount INTEGER DEFAULT 0,
    dlc_count INTEGER DEFAULT 0,
    about_game TEXT,
    notes TEXT,
    achievements INTEGER DEFAULT 0,
    header_image VARCHAR(500)
);

CREATE TABLE developers (
    developer_id SERIAL PRIMARY KEY,
    developer_name VARCHAR(255) UNIQUE NOT NULL,
    founded_year INTEGER,
    country VARCHAR(100),
    website VARCHAR(255)
);

CREATE TABLE publishers (
    publisher_id SERIAL PRIMARY KEY,
    publisher_name VARCHAR(255) UNIQUE NOT NULL,
    founded_year INTEGER,
    headquarters VARCHAR(100),
    website VARCHAR(255)
);

CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) UNIQUE NOT NULL,
    category_type category_type_enum DEFAULT 'gameplay',
    description TEXT
);

CREATE TABLE genres (
    genre_id SERIAL PRIMARY KEY,
    genre_name VARCHAR(100) UNIQUE NOT NULL,
    parent_genre_id INTEGER,
    description TEXT,
    FOREIGN KEY (parent_genre_id) REFERENCES genres(genre_id)
);

CREATE TABLE tags (
    tag_id SERIAL PRIMARY KEY,
    tag_name VARCHAR(100) UNIQUE NOT NULL,
    tag_category tag_category_enum DEFAULT 'gameplay',
    popularity_score INTEGER DEFAULT 0
);

CREATE TABLE languages (
    language_id SERIAL PRIMARY KEY,
    language_name VARCHAR(100) UNIQUE NOT NULL,
    language_code VARCHAR(10),
    native_name VARCHAR(100),
    region VARCHAR(100)
);

CREATE TABLE platforms (
    platform_id SERIAL PRIMARY KEY,
    platform_name platform_name_enum NOT NULL,
    platform_code VARCHAR(10),
    description TEXT
);

CREATE TABLE screenshots (
    screenshot_id SERIAL PRIMARY KEY,
    app_id INTEGER NOT NULL,
    screenshot_url VARCHAR(500) NOT NULL,
    screenshot_order INTEGER DEFAULT 1,
    resolution VARCHAR(20),
    FOREIGN KEY (app_id) REFERENCES games(app_id) ON DELETE CASCADE
);

CREATE TABLE movies (
    movie_id SERIAL PRIMARY KEY,
    app_id INTEGER NOT NULL,
    movie_url VARCHAR(500) NOT NULL,
    movie_type movie_type_enum DEFAULT 'trailer',
    duration INTEGER,
    resolution VARCHAR(20),
    FOREIGN KEY (app_id) REFERENCES games(app_id) ON DELETE CASCADE
);

CREATE TABLE metacritic_data (
    metacritic_id SERIAL PRIMARY KEY,
    app_id INTEGER UNIQUE NOT NULL,
    metacritic_score INTEGER DEFAULT 0,
    metacritic_url VARCHAR(255),
    user_score INTEGER DEFAULT 0,
    critic_reviews_count INTEGER DEFAULT 0,
    user_reviews_count INTEGER DEFAULT 0,
    FOREIGN KEY (app_id) REFERENCES games(app_id) ON DELETE CASCADE
);

CREATE TABLE reviews_data (
    review_id SERIAL PRIMARY KEY,
    app_id INTEGER UNIQUE NOT NULL,
    reviews TEXT,
    positive INTEGER DEFAULT 0,
    negative INTEGER DEFAULT 0,
    score_rank VARCHAR(50),
    recommendations INTEGER DEFAULT 0,
    review_summary review_summary_enum,
    FOREIGN KEY (app_id) REFERENCES games(app_id) ON DELETE CASCADE
);

CREATE TABLE playtime_stats (
    playtime_id SERIAL PRIMARY KEY,
    app_id INTEGER UNIQUE NOT NULL,
    avg_playtime_forever INTEGER DEFAULT 0,
    avg_playtime_two_weeks INTEGER DEFAULT 0,
    median_playtime_forever INTEGER DEFAULT 0,
    median_playtime_two_weeks INTEGER DEFAULT 0,
    total_players INTEGER DEFAULT 0,
    FOREIGN KEY (app_id) REFERENCES games(app_id) ON DELETE CASCADE
);

CREATE TABLE game_support (
    support_id SERIAL PRIMARY KEY,
    app_id INTEGER UNIQUE NOT NULL,
    website VARCHAR(255),
    support_url VARCHAR(255),
    support_email VARCHAR(255),
    community_forum VARCHAR(255),
    documentation_url VARCHAR(255),
    FOREIGN KEY (app_id) REFERENCES games(app_id) ON DELETE CASCADE
);

CREATE TABLE game_developers (
    app_id INTEGER,
    developer_id INTEGER,
    role role_enum DEFAULT 'primary',
    PRIMARY KEY (app_id, developer_id),
    FOREIGN KEY (app_id) REFERENCES games(app_id) ON DELETE CASCADE,
    FOREIGN KEY (developer_id) REFERENCES developers(developer_id) ON DELETE CASCADE
);

CREATE TABLE game_publishers (
    app_id INTEGER,
    publisher_id INTEGER,
    role role_publisher_enum DEFAULT 'primary',
    region VARCHAR(100),
    PRIMARY KEY (app_id, publisher_id),
    FOREIGN KEY (app_id) REFERENCES games(app_id) ON DELETE CASCADE,
    FOREIGN KEY (publisher_id) REFERENCES publishers(publisher_id) ON DELETE CASCADE
);

CREATE TABLE game_categories (
    app_id INTEGER,
    category_id INTEGER,
    PRIMARY KEY (app_id, category_id),
    FOREIGN KEY (app_id) REFERENCES games(app_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE CASCADE
);

CREATE TABLE game_genres (
    app_id INTEGER,
    genre_id INTEGER,
    is_primary BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (app_id, genre_id),
    FOREIGN KEY (app_id) REFERENCES games(app_id) ON DELETE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES genres(genre_id) ON DELETE CASCADE
);

CREATE TABLE game_tags (
    app_id INTEGER,
    tag_id INTEGER,
    relevance_score INTEGER DEFAULT 0,
    PRIMARY KEY (app_id, tag_id),
    FOREIGN KEY (app_id) REFERENCES games(app_id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES tags(tag_id) ON DELETE CASCADE
);

CREATE TABLE game_supported_languages (
    app_id INTEGER,
    language_id INTEGER,
    support_level support_level_enum DEFAULT 'interface',
    PRIMARY KEY (app_id, language_id),
    FOREIGN KEY (app_id) REFERENCES games(app_id) ON DELETE CASCADE,
    FOREIGN KEY (language_id) REFERENCES languages(language_id) ON DELETE CASCADE
);

CREATE TABLE game_audio_languages (
    app_id INTEGER,
    language_id INTEGER,
    audio_quality audio_quality_enum DEFAULT 'full',
    PRIMARY KEY (app_id, language_id),
    FOREIGN KEY (app_id) REFERENCES games(app_id) ON DELETE CASCADE,
    FOREIGN KEY (language_id) REFERENCES languages(language_id) ON DELETE CASCADE
);

CREATE TABLE game_platforms (
    app_id INTEGER,
    platform_id INTEGER,
    minimum_requirements TEXT,
    recommended_requirements TEXT,
    release_date DATE,
    PRIMARY KEY (app_id, platform_id),
    FOREIGN KEY (app_id) REFERENCES games(app_id) ON DELETE CASCADE,
    FOREIGN KEY (platform_id) REFERENCES platforms(platform_id) ON DELETE CASCADE
);