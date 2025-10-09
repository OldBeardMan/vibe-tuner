
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'recommendation_source') THEN
    CREATE TYPE recommendation_source AS ENUM ('manual','image');
  END IF;
END
$$;

-- Users
CREATE TABLE IF NOT EXISTS "Users" (
  "idUser" SERIAL PRIMARY KEY,
  "email" VARCHAR(255) NOT NULL UNIQUE,
  "login" VARCHAR(45) NOT NULL,
  "password" VARCHAR(255) NOT NULL,
  "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  "updated_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Track
CREATE TABLE IF NOT EXISTS "Track" (
  "idTrack" SERIAL PRIMARY KEY,
  "spotify_track_id" VARCHAR(255) NOT NULL UNIQUE,
  "track_name" VARCHAR(255) NOT NULL,
  "artist_name" VARCHAR(255) NOT NULL,
  "duration_ms" INT NOT NULL
);

-- Recommendaction (one row per recommendation)
CREATE TABLE IF NOT EXISTS "Recommendaction" (
  "idRecommendaction" SERIAL PRIMARY KEY,
  "time" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  "source" recommendation_source NOT NULL,
  "emotion_code" INT NOT NULL,
  "Users_idUser" INT NOT NULL,
  CONSTRAINT fk_recommendaction_users
    FOREIGN KEY ("Users_idUser") REFERENCES "Users"("idUser")
    ON DELETE NO ACTION ON UPDATE NO ACTION
);

-- Recommendaction_Track : join table (many tracks per recommendation)
CREATE TABLE IF NOT EXISTS "Recommendaction_Track" (
  "idRecommendactionTrack" SERIAL PRIMARY KEY,
  "Recommendaction_id" INT NOT NULL,
  "Track_idTrack" INT NOT NULL,
  CONSTRAINT fk_rat_recommendaction
    FOREIGN KEY ("Recommendaction_id") REFERENCES "Recommendaction"("idRecommendaction")
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_rat_track
    FOREIGN KEY ("Track_idTrack") REFERENCES "Track"("idTrack")
    ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT uq_recommendaction_track UNIQUE ("Recommendaction_id","Track_idTrack")
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_users_email ON "Users" ("email");
CREATE INDEX IF NOT EXISTS idx_track_spotify ON "Track" ("spotify_track_id");
CREATE INDEX IF NOT EXISTS idx_recommendation_user ON "Recommendaction" ("Users_idUser");
CREATE INDEX IF NOT EXISTS idx_recommendation_track_fk ON "Recommendaction_Track" ("Recommendaction_id","Track_idTrack");


--------------------------------------------
-- ADD DATA (idempotent)
--------------------------------------------

-- Tracks
INSERT INTO "Track" ("spotify_track_id","track_name","artist_name","duration_ms") VALUES
  ('spotify:track:001','Sunny Day','Sunband',210000),
  ('spotify:track:002','Happy Heart','Sunband',200000),
  ('spotify:track:003','Joyful Ride','Sunband',195000),
  ('spotify:track:004','Smile','Bright Crew',205000),
  ('spotify:track:005','Blue Rain','Melancholy Trio',220000),
  ('spotify:track:006','Longing','Melancholy Trio',230000),
  ('spotify:track:007','Tearful Night','Sad Strings',240000),
  ('spotify:track:008','Quiet Lament','Sad Strings',215000),
  ('spotify:track:009','Rage','Fire Beats',180000),
  ('spotify:track:010','Breakdown','Angry Rhythms',175000),
  ('spotify:track:011','Storm','Angry Rhythms',190000),
  ('spotify:track:012','Surprise Intro','Oddities',150000),
  ('spotify:track:013','Unexpected','Oddities',170000),
  ('spotify:track:014','Wow Moment','Oddities',160000),
  ('spotify:track:015','Calm Sea','Quiet Quartet',240000),
  ('spotify:track:016','Peaceful Mind','Quiet Quartet',250000),
  ('spotify:track:017','Soft Breeze','Quiet Quartet',230000),
  ('spotify:track:018','Serene','Calm Ensemble',245000),
  ('spotify:track:019','Tension','Edge Orchestra',220000),
  ('spotify:track:020','Anxiety','Edge Orchestra',210000),
  ('spotify:track:021','Pressure','Edge Orchestra',200000),
  ('spotify:track:022','Bright Morning','Sunband',202000),
  ('spotify:track:023','Gentle Smile','Bright Crew',198000),
  ('spotify:track:024','Mild Shock','Oddities',165000)
ON CONFLICT ("spotify_track_id") DO NOTHING;


-- Users (single INSERT with ON CONFLICT for the whole statement)
INSERT INTO "Users" ("email","login","password") VALUES
  ('alice@example.com','alice','$2b$10$fakehashalice'),
  ('bob@example.com','bob','$2b$10$fakehashbob'),
  ('carol@example.com','carol','$2b$10$fakehashcarol')
ON CONFLICT ("email") DO NOTHING;


-- Recommendactions + mappings
-- All occurrences of 'system' replaced with 'manual' (enum only manual|image)

-- Alice
WITH u AS (SELECT "idUser" FROM "Users" WHERE "email" = 'alice@example.com'),
 r1 AS (
  INSERT INTO "Recommendaction" ("time","source","emotion_code","Users_idUser")
  SELECT now() - interval '25 minutes', 'manual', 1, u."idUser" FROM u
  RETURNING "idRecommendaction"
)
INSERT INTO "Recommendaction_Track" ("Recommendaction_id","Track_idTrack")
SELECT r1."idRecommendaction", t."idTrack"
FROM r1 CROSS JOIN LATERAL (
  SELECT "idTrack" FROM "Track" WHERE "spotify_track_id" IN ('spotify:track:001','spotify:track:002','spotify:track:003','spotify:track:004','spotify:track:022')
) AS t
ON CONFLICT DO NOTHING;

WITH u AS (SELECT "idUser" FROM "Users" WHERE "email" = 'alice@example.com'),
 r2 AS (
  INSERT INTO "Recommendaction" ("time","source","emotion_code","Users_idUser")
  SELECT now() - interval '20 minutes', 'image', 4, u."idUser" FROM u
  RETURNING "idRecommendaction"
)
INSERT INTO "Recommendaction_Track" ("Recommendaction_id","Track_idTrack")
SELECT r2."idRecommendaction", t."idTrack"
FROM r2 CROSS JOIN LATERAL (
  SELECT "idTrack" FROM "Track" WHERE "spotify_track_id" IN ('spotify:track:012','spotify:track:013','spotify:track:014','spotify:track:024','spotify:track:004')
) AS t
ON CONFLICT DO NOTHING;

WITH u AS (SELECT "idUser" FROM "Users" WHERE "email" = 'alice@example.com'),
 r3 AS (
  INSERT INTO "Recommendaction" ("time","source","emotion_code","Users_idUser")
  SELECT now() - interval '15 minutes', 'manual', 5, u."idUser" FROM u
  RETURNING "idRecommendaction"
)
INSERT INTO "Recommendaction_Track" ("Recommendaction_id","Track_idTrack")
SELECT r3."idRecommendaction", t."idTrack"
FROM r3 CROSS JOIN LATERAL (
  SELECT "idTrack" FROM "Track" WHERE "spotify_track_id" IN ('spotify:track:015','spotify:track:016','spotify:track:017','spotify:track:018','spotify:track:023')
) AS t
ON CONFLICT DO NOTHING;

WITH u AS (SELECT "idUser" FROM "Users" WHERE "email" = 'alice@example.com'),
 r4 AS (
  INSERT INTO "Recommendaction" ("time","source","emotion_code","Users_idUser")
  SELECT now() - interval '10 minutes', 'manual', 6, u."idUser" FROM u
  RETURNING "idRecommendaction"
)
INSERT INTO "Recommendaction_Track" ("Recommendaction_id","Track_idTrack")
SELECT r4."idRecommendaction", t."idTrack"
FROM r4 CROSS JOIN LATERAL (
  SELECT "idTrack" FROM "Track" WHERE "spotify_track_id" IN ('spotify:track:019','spotify:track:020','spotify:track:021','spotify:track:006','spotify:track:011')
) AS t
ON CONFLICT DO NOTHING;

WITH u AS (SELECT "idUser" FROM "Users" WHERE "email" = 'alice@example.com'),
 r5 AS (
  INSERT INTO "Recommendaction" ("time","source","emotion_code","Users_idUser")
  SELECT now() - interval '5 minutes', 'image', 2, u."idUser" FROM u
  RETURNING "idRecommendaction"
)
INSERT INTO "Recommendaction_Track" ("Recommendaction_id","Track_idTrack")
SELECT r5."idRecommendaction", t."idTrack"
FROM r5 CROSS JOIN LATERAL (
  SELECT "idTrack" FROM "Track" WHERE "spotify_track_id" IN ('spotify:track:005','spotify:track:006','spotify:track:008','spotify:track:002','spotify:track:007')
) AS t
ON CONFLICT DO NOTHING;


-- Bob
WITH u AS (SELECT "idUser" FROM "Users" WHERE "email" = 'bob@example.com'),
 r1 AS (
  INSERT INTO "Recommendaction" ("time","source","emotion_code","Users_idUser")
  SELECT now() - interval '28 minutes', 'manual', 2, u."idUser" FROM u
  RETURNING "idRecommendaction"
)
INSERT INTO "Recommendaction_Track" ("Recommendaction_id","Track_idTrack")
SELECT r1."idRecommendaction", t."idTrack"
FROM r1 CROSS JOIN LATERAL (
  SELECT "idTrack" FROM "Track" WHERE "spotify_track_id" IN ('spotify:track:005','spotify:track:008','spotify:track:006','spotify:track:002','spotify:track:007')
) AS t
ON CONFLICT DO NOTHING;

WITH u AS (SELECT "idUser" FROM "Users" WHERE "email" = 'bob@example.com'),
 r2 AS (
  INSERT INTO "Recommendaction" ("time","source","emotion_code","Users_idUser")
  SELECT now() - interval '23 minutes', 'image', 1, u."idUser" FROM u
  RETURNING "idRecommendaction"
)
INSERT INTO "Recommendaction_Track" ("Recommendaction_id","Track_idTrack")
SELECT r2."idRecommendaction", t."idTrack"
FROM r2 CROSS JOIN LATERAL (
  SELECT "idTrack" FROM "Track" WHERE "spotify_track_id" IN ('spotify:track:001','spotify:track:022','spotify:track:003','spotify:track:023','spotify:track:004')
) AS t
ON CONFLICT DO NOTHING;

WITH u AS (SELECT "idUser" FROM "Users" WHERE "email" = 'bob@example.com'),
 r3 AS (
  INSERT INTO "Recommendaction" ("time","source","emotion_code","Users_idUser")
  SELECT now() - interval '18 minutes', 'manual', 3, u."idUser" FROM u
  RETURNING "idRecommendaction"
)
INSERT INTO "Recommendaction_Track" ("Recommendaction_id","Track_idTrack")
SELECT r3."idRecommendaction", t."idTrack"
FROM r3 CROSS JOIN LATERAL (
  SELECT "idTrack" FROM "Track" WHERE "spotify_track_id" IN ('spotify:track:009','spotify:track:010','spotify:track:011','spotify:track:003','spotify:track:019')
) AS t
ON CONFLICT DO NOTHING;

WITH u AS (SELECT "idUser" FROM "Users" WHERE "email" = 'bob@example.com'),
 r4 AS (
  INSERT INTO "Recommendaction" ("time","source","emotion_code","Users_idUser")
  SELECT now() - interval '13 minutes', 'image', 5, u."idUser" FROM u
  RETURNING "idRecommendaction"
)
INSERT INTO "Recommendaction_Track" ("Recommendaction_id","Track_idTrack")
SELECT r4."idRecommendaction", t."idTrack"
FROM r4 CROSS JOIN LATERAL (
  SELECT "idTrack" FROM "Track" WHERE "spotify_track_id" IN ('spotify:track:015','spotify:track:016','spotify:track:017','spotify:track:018','spotify:track:023')
) AS t
ON CONFLICT DO NOTHING;

WITH u AS (SELECT "idUser" FROM "Users" WHERE "email" = 'bob@example.com'),
 r5 AS (
  INSERT INTO "Recommendaction" ("time","source","emotion_code","Users_idUser")
  SELECT now() - interval '8 minutes', 'manual', 6, u."idUser" FROM u
  RETURNING "idRecommendaction"
)
INSERT INTO "Recommendaction_Track" ("Recommendaction_id","Track_idTrack")
SELECT r5."idRecommendaction", t."idTrack"
FROM r5 CROSS JOIN LATERAL (
  SELECT "idTrack" FROM "Track" WHERE "spotify_track_id" IN ('spotify:track:019','spotify:track:020','spotify:track:021','spotify:track:006','spotify:track:011')
) AS t
ON CONFLICT DO NOTHING;


-- Carol
WITH u AS (SELECT "idUser" FROM "Users" WHERE "email" = 'carol@example.com'),
 r1 AS (
  INSERT INTO "Recommendaction" ("time","source","emotion_code","Users_idUser")
  SELECT now() - interval '30 minutes', 'image', 4, u."idUser" FROM u
  RETURNING "idRecommendaction"
)
INSERT INTO "Recommendaction_Track" ("Recommendaction_id","Track_idTrack")
SELECT r1."idRecommendaction", t."idTrack"
FROM r1 CROSS JOIN LATERAL (
  SELECT "idTrack" FROM "Track" WHERE "spotify_track_id" IN ('spotify:track:012','spotify:track:013','spotify:track:014','spotify:track:024','spotify:track:022')
) AS t
ON CONFLICT DO NOTHING;

WITH u AS (SELECT "idUser" FROM "Users" WHERE "email" = 'carol@example.com'),
 r2 AS (
  INSERT INTO "Recommendaction" ("time","source","emotion_code","Users_idUser")
  SELECT now() - interval '25 minutes', 'manual', 1, u."idUser" FROM u
  RETURNING "idRecommendaction"
)
INSERT INTO "Recommendaction_Track" ("Recommendaction_id","Track_idTrack")
SELECT r2."idRecommendaction", t."idTrack"
FROM r2 CROSS JOIN LATERAL (
  SELECT "idTrack" FROM "Track" WHERE "spotify_track_id" IN ('spotify:track:001','spotify:track:002','spotify:track:007','spotify:track:022','spotify:track:023')
) AS t
ON CONFLICT DO NOTHING;

WITH u AS (SELECT "idUser" FROM "Users" WHERE "email" = 'carol@example.com'),
 r3 AS (
  INSERT INTO "Recommendaction" ("time","source","emotion_code","Users_idUser")
  SELECT now() - interval '20 minutes', 'manual', 2, u."idUser" FROM u
  RETURNING "idRecommendaction"
)
INSERT INTO "Recommendaction_Track" ("Recommendaction_id","Track_idTrack")
SELECT r3."idRecommendaction", t."idTrack"
FROM r3 CROSS JOIN LATERAL (
  SELECT "idTrack" FROM "Track" WHERE "spotify_track_id" IN ('spotify:track:005','spotify:track:008','spotify:track:006','spotify:track:002','spotify:track:004')
) AS t
ON CONFLICT DO NOTHING;

WITH u AS (SELECT "idUser" FROM "Users" WHERE "email" = 'carol@example.com'),
 r4 AS (
  INSERT INTO "Recommendaction" ("time","source","emotion_code","Users_idUser")
  SELECT now() - interval '15 minutes', 'image', 3, u."idUser" FROM u
  RETURNING "idRecommendaction"
)
INSERT INTO "Recommendaction_Track" ("Recommendaction_id","Track_idTrack")
SELECT r4."idRecommendaction", t."idTrack"
FROM r4 CROSS JOIN LATERAL (
  SELECT "idTrack" FROM "Track" WHERE "spotify_track_id" IN ('spotify:track:009','spotify:track:010','spotify:track:011','spotify:track:019','spotify:track:003')
) AS t
ON CONFLICT DO NOTHING;

WITH u AS (SELECT "idUser" FROM "Users" WHERE "email" = 'carol@example.com'),
 r5 AS (
  INSERT INTO "Recommendaction" ("time","source","emotion_code","Users_idUser")
  SELECT now() - interval '5 minutes', 'manual', 5, u."idUser" FROM u
  RETURNING "idRecommendaction"
)
INSERT INTO "Recommendaction_Track" ("Recommendaction_id","Track_idTrack")
SELECT r5."idRecommendaction", t."idTrack"
FROM r5 CROSS JOIN LATERAL (
  SELECT "idTrack" FROM "Track" WHERE "spotify_track_id" IN ('spotify:track:015','spotify:track:016','spotify:track:017','spotify:track:018','spotify:track:023')
) AS t
ON CONFLICT DO NOTHING;
