CREATE TABLE articles
(
    id BIGINT
    AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR
    (255) NOT NULL,
  content TEXT,
  author VARCHAR
    (255),
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

    CREATE TABLE users
    (
        id BIGINT
        AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR
        (100) UNIQUE,
  password VARCHAR
        (255),
  email VARCHAR
        (255),
  profile_info TEXT
);

        CREATE TABLE activities
        (
            id BIGINT
            AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT,
  type VARCHAR
            (50),
  content TEXT,
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

            CREATE TABLE mood_logs
            (
                id BIGINT
                AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT,
  mood VARCHAR
                (50),
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  notes TEXT
);
