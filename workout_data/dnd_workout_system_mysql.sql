-- D&D Workout System - MySQL 8.0+
-- Creates the schema, seed data, and an unlocked-exercise view.

CREATE DATABASE IF NOT EXISTS dnd_workout CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE dnd_workout;

SET FOREIGN_KEY_CHECKS = 0;
DROP VIEW IF EXISTS v_unlocked_exercises;
DROP TABLE IF EXISTS workout_exercises;
DROP TABLE IF EXISTS workout_sessions;
DROP TABLE IF EXISTS characters;
DROP TABLE IF EXISTS xp_awards;
DROP TABLE IF EXISTS progression_levels;
DROP TABLE IF EXISTS dice_rules;
DROP TABLE IF EXISTS rep_styles;
DROP TABLE IF EXISTS class_exercises;
DROP TABLE IF EXISTS exercises;
DROP TABLE IF EXISTS classes;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE classes (
  class_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  class_name VARCHAR(50) NOT NULL UNIQUE,
  description VARCHAR(255) NULL
) ENGINE=InnoDB;

CREATE TABLE exercises (
  exercise_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  exercise_name VARCHAR(100) NOT NULL UNIQUE,
  default_unit ENUM('reps','seconds','distance','mixed') NOT NULL DEFAULT 'reps'
) ENGINE=InnoDB;

CREATE TABLE class_exercises (
  class_id INT UNSIGNED NOT NULL,
  exercise_id INT UNSIGNED NOT NULL,
  slot_number TINYINT UNSIGNED NOT NULL,
  unlock_level TINYINT UNSIGNED NOT NULL,
  PRIMARY KEY (class_id, exercise_id),
  UNIQUE KEY uq_class_slot (class_id, slot_number),
  CONSTRAINT fk_ce_class FOREIGN KEY (class_id) REFERENCES classes(class_id),
  CONSTRAINT fk_ce_exercise FOREIGN KEY (exercise_id) REFERENCES exercises(exercise_id),
  CONSTRAINT chk_ce_level CHECK (unlock_level BETWEEN 1 AND 10)
) ENGINE=InnoDB;

CREATE TABLE rep_styles (
  rep_style_id TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  style_name VARCHAR(30) NOT NULL UNIQUE,
  base_min TINYINT UNSIGNED NOT NULL,
  base_max TINYINT UNSIGNED NOT NULL,
  rest_seconds_min SMALLINT UNSIGNED NOT NULL,
  rest_seconds_max SMALLINT UNSIGNED NOT NULL,
  notes VARCHAR(255) NULL,
  CONSTRAINT chk_rep_range CHECK (base_min <= base_max)
) ENGINE=InnoDB;

CREATE TABLE dice_rules (
  die_code ENUM('d4','d6','d8','d10','d12','d20') PRIMARY KEY,
  purpose VARCHAR(80) NOT NULL,
  instructions VARCHAR(255) NOT NULL,
  result_details VARCHAR(500) NOT NULL,
  notes VARCHAR(255) NULL
) ENGINE=InnoDB;

CREATE TABLE progression_levels (
  level_number TINYINT UNSIGNED PRIMARY KEY,
  total_xp_required INT UNSIGNED NOT NULL UNIQUE,
  unlocks VARCHAR(255) NOT NULL,
  maximum_sets TINYINT UNSIGNED NOT NULL,
  optional_extra_exercise BOOLEAN NOT NULL DEFAULT FALSE
) ENGINE=InnoDB;

CREATE TABLE xp_awards (
  xp_award_id SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  action_name VARCHAR(80) NOT NULL UNIQUE,
  xp_value INT NULL,
  condition_text VARCHAR(255) NOT NULL,
  notes VARCHAR(255) NULL
) ENGINE=InnoDB;

CREATE TABLE characters (
  character_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  character_name VARCHAR(100) NOT NULL,
  class_id INT UNSIGNED NOT NULL,
  level_number TINYINT UNSIGNED NOT NULL DEFAULT 1,
  current_xp INT UNSIGNED NOT NULL DEFAULT 0,
  personal_quest TEXT NULL,
  best_record TEXT NULL,
  safety_note VARCHAR(500) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_character_class FOREIGN KEY (class_id) REFERENCES classes(class_id),
  CONSTRAINT fk_character_level FOREIGN KEY (level_number) REFERENCES progression_levels(level_number),
  CONSTRAINT chk_character_xp CHECK (current_xp >= 0)
) ENGINE=InnoDB;

CREATE TABLE workout_sessions (
  session_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  character_id BIGINT UNSIGNED NOT NULL,
  workout_date DATE NOT NULL,
  encounter_roll TINYINT UNSIGNED NULL,
  workout_size_roll TINYINT UNSIGNED NULL,
  encounter_name VARCHAR(30) NULL,
  exercises_completed TINYINT UNSIGNED NOT NULL DEFAULT 0,
  xp_earned INT UNSIGNED NOT NULL DEFAULT 0,
  notes TEXT NULL,
  completed BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_session_character FOREIGN KEY (character_id) REFERENCES characters(character_id) ON DELETE CASCADE,
  CONSTRAINT chk_encounter_roll CHECK (encounter_roll IS NULL OR encounter_roll BETWEEN 1 AND 20),
  CONSTRAINT chk_size_roll CHECK (workout_size_roll IS NULL OR workout_size_roll BETWEEN 1 AND 4)
) ENGINE=InnoDB;

CREATE TABLE workout_exercises (
  workout_exercise_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  session_id BIGINT UNSIGNED NOT NULL,
  exercise_id INT UNSIGNED NOT NULL,
  exercise_order TINYINT UNSIGNED NOT NULL,
  rep_style_id TINYINT UNSIGNED NULL,
  d8_roll TINYINT UNSIGNED NULL,
  d6_roll TINYINT UNSIGNED NULL,
  base_reps_min TINYINT UNSIGNED NULL,
  base_reps_max TINYINT UNSIGNED NULL,
  final_reps TINYINT UNSIGNED NULL,
  sets_assigned TINYINT UNSIGNED NULL,
  sets_completed TINYINT UNSIGNED NULL,
  resistance_notes VARCHAR(255) NULL,
  UNIQUE KEY uq_session_order (session_id, exercise_order),
  CONSTRAINT fk_we_session FOREIGN KEY (session_id) REFERENCES workout_sessions(session_id) ON DELETE CASCADE,
  CONSTRAINT fk_we_exercise FOREIGN KEY (exercise_id) REFERENCES exercises(exercise_id),
  CONSTRAINT fk_we_rep_style FOREIGN KEY (rep_style_id) REFERENCES rep_styles(rep_style_id),
  CONSTRAINT chk_we_rolls CHECK ((d8_roll IS NULL OR d8_roll BETWEEN 1 AND 8) AND (d6_roll IS NULL OR d6_roll BETWEEN 1 AND 6))
) ENGINE=InnoDB;

INSERT INTO classes (class_id, class_name) VALUES
(1, 'Wizard'),
(2, 'Rogue'),
(3, 'Paladin'),
(4, 'Bard'),
(5, 'Barbarian'),
(6, 'Fighter'),
(7, 'Monk'),
(8, 'Cleric'),
(9, 'Druid'),
(10, 'Ranger'),
(11, 'Sorcerer'),
(12, 'Warlock');

INSERT INTO exercises (exercise_id, exercise_name) VALUES
(1, 'Push-ups'),
(2, 'Goblet squats'),
(3, 'Plank'),
(4, 'Jumping jacks'),
(5, 'Pike push-ups'),
(6, 'Reverse lunges'),
(7, 'Dead bug'),
(8, 'Dumbbell shoulder press'),
(9, 'Bear crawl'),
(10, 'Turkish get-up'),
(11, 'Handstand hold'),
(12, 'Renegade row'),
(13, 'Walking lunges'),
(14, 'Mountain climbers'),
(15, 'Sit-ups'),
(16, 'Bodyweight squats'),
(17, 'Lateral shuffles'),
(18, 'Single-leg deadlift'),
(19, 'Burpees'),
(20, 'Hanging knee raises'),
(21, 'Box jumps'),
(22, 'Pistol-squat progression'),
(23, 'Pull-ups'),
(24, 'Agility shuttle'),
(25, 'Squats'),
(26, 'Farmer’s carry'),
(27, 'Dumbbell bench press'),
(28, 'Overhead press'),
(29, 'Romanian deadlift'),
(30, 'Front-rack carry'),
(31, 'Bulgarian split squat'),
(32, 'Barbell squat'),
(33, 'Sled push'),
(34, 'Dancing steps or step-ups'),
(35, 'Bicycle crunches'),
(36, 'Jumping rope'),
(37, 'Alternating lunges'),
(38, 'Kettlebell swings'),
(39, 'Squat-to-press'),
(40, 'Skater jumps'),
(41, 'Push-up to side plank'),
(42, 'Burpee broad jump'),
(43, 'Air squats'),
(44, 'Kettlebell deadlift'),
(45, 'Dumbbell clean'),
(46, 'Tire flips or sandbag lifts'),
(47, 'Front squat'),
(48, 'Deadlift'),
(49, 'Heavy sled push'),
(50, 'Rows'),
(51, 'Split squats'),
(52, 'Shoulder press'),
(53, 'Barbell bench press'),
(54, 'Lunges'),
(55, 'Hollow hold'),
(56, 'Diamond push-ups'),
(57, 'Single-leg balance'),
(58, 'Jump squats'),
(59, 'Crawling pattern'),
(60, 'Handstand progression'),
(61, 'L-sit progression'),
(62, 'Pistol squat'),
(63, 'Muscle-up progression'),
(64, 'Incline push-ups'),
(65, 'Sit-to-stand squats'),
(66, 'Bird dog'),
(67, 'Step-ups'),
(68, 'Kneeling shoulder press'),
(69, 'Glute bridge'),
(70, 'Dumbbell row'),
(71, 'Suitcase carry'),
(72, 'Overhead carry'),
(73, 'Windmill'),
(74, 'Inchworms'),
(75, 'Crab walk'),
(76, 'Kettlebell swing'),
(77, 'Cossack squat'),
(78, 'Rope climb progression'),
(79, 'Single-leg Romanian deadlift'),
(80, 'Loaded hike'),
(81, 'Squat jumps'),
(82, 'Dumbbell thrusters'),
(83, 'Devil’s press'),
(84, 'Close-grip push-ups'),
(85, 'Single-arm row'),
(86, 'Heavy carries');

INSERT INTO class_exercises (class_id, exercise_id, slot_number, unlock_level) VALUES
(1, 1, 1, 1),
(1, 2, 2, 1),
(1, 3, 3, 1),
(1, 4, 4, 1),
(1, 5, 5, 2),
(1, 6, 6, 2),
(1, 7, 7, 3),
(1, 8, 8, 3),
(1, 9, 9, 4),
(1, 10, 10, 5),
(1, 11, 11, 6),
(1, 12, 12, 8),
(2, 13, 1, 1),
(2, 14, 2, 1),
(2, 15, 3, 1),
(2, 16, 4, 1),
(2, 17, 5, 2),
(2, 18, 6, 2),
(2, 19, 7, 3),
(2, 20, 8, 3),
(2, 21, 9, 4),
(2, 22, 10, 5),
(2, 23, 11, 6),
(2, 24, 12, 8),
(3, 1, 1, 1),
(3, 25, 2, 1),
(3, 26, 3, 1),
(3, 3, 4, 1),
(3, 6, 5, 2),
(3, 27, 6, 2),
(3, 28, 7, 3),
(3, 29, 8, 3),
(3, 30, 9, 4),
(3, 31, 10, 5),
(3, 32, 11, 6),
(3, 33, 12, 8),
(4, 34, 1, 1),
(4, 16, 2, 1),
(4, 1, 3, 1),
(4, 35, 4, 1),
(4, 36, 5, 2),
(4, 37, 6, 2),
(4, 9, 7, 3),
(4, 38, 8, 3),
(4, 39, 9, 4),
(4, 40, 10, 5),
(4, 41, 11, 6),
(4, 42, 12, 8),
(5, 43, 1, 1),
(5, 1, 2, 1),
(5, 14, 3, 1),
(5, 3, 4, 1),
(5, 44, 5, 2),
(5, 13, 6, 2),
(5, 45, 7, 3),
(5, 38, 8, 3),
(5, 46, 9, 4),
(5, 47, 10, 5),
(5, 48, 11, 6),
(5, 49, 12, 8),
(6, 1, 1, 1),
(6, 25, 2, 1),
(6, 50, 3, 1),
(6, 3, 4, 1),
(6, 27, 5, 2),
(6, 51, 6, 2),
(6, 52, 7, 3),
(6, 29, 8, 3),
(6, 23, 9, 4),
(6, 53, 10, 5),
(6, 32, 11, 6),
(6, 48, 12, 8),
(7, 1, 1, 1),
(7, 54, 2, 1),
(7, 3, 3, 1),
(7, 55, 4, 1),
(7, 56, 5, 2),
(7, 57, 6, 2),
(7, 58, 7, 3),
(7, 59, 8, 3),
(7, 60, 9, 4),
(7, 61, 10, 5),
(7, 62, 11, 6),
(7, 63, 12, 8),
(8, 64, 1, 1),
(8, 65, 2, 1),
(8, 26, 3, 1),
(8, 66, 4, 1),
(8, 67, 5, 2),
(8, 68, 6, 2),
(8, 69, 7, 3),
(8, 70, 8, 3),
(8, 10, 9, 4),
(8, 71, 10, 5),
(8, 72, 11, 6),
(8, 73, 12, 8),
(9, 16, 1, 1),
(9, 9, 2, 1),
(9, 3, 3, 1),
(9, 69, 4, 1),
(9, 6, 5, 2),
(9, 74, 6, 2),
(9, 75, 7, 3),
(9, 18, 8, 3),
(9, 76, 9, 4),
(9, 77, 10, 5),
(9, 10, 11, 6),
(9, 78, 12, 8),
(10, 13, 1, 1),
(10, 1, 2, 1),
(10, 50, 3, 1),
(10, 3, 4, 1),
(10, 67, 5, 2),
(10, 26, 6, 2),
(10, 36, 7, 3),
(10, 23, 8, 3),
(10, 38, 9, 4),
(10, 79, 10, 5),
(10, 21, 11, 6),
(10, 80, 12, 8),
(11, 4, 1, 1),
(11, 16, 2, 1),
(11, 64, 3, 1),
(11, 7, 4, 1),
(11, 81, 5, 2),
(11, 5, 6, 2),
(11, 14, 7, 3),
(11, 82, 8, 3),
(11, 19, 9, 4),
(11, 60, 10, 5),
(11, 10, 11, 6),
(11, 83, 12, 8),
(12, 1, 1, 1),
(12, 6, 2, 1),
(12, 3, 3, 1),
(12, 69, 4, 1),
(12, 84, 5, 2),
(12, 85, 6, 2),
(12, 9, 7, 3),
(12, 44, 8, 3),
(12, 12, 9, 4),
(12, 10, 10, 5),
(12, 23, 11, 6),
(12, 86, 12, 8);

INSERT INTO rep_styles (style_name, base_min, base_max, rest_seconds_min, rest_seconds_max, notes) VALUES
('Strength',4,6,90,150,'Use for heavy compound lifts.'),
('Standard',8,12,60,90,'Normal workout range.'),
('Endurance',12,20,30,60,'Use for conditioning movements.'),
('Heroic effort',15,25,30,60,'Use only when safe and technically sound.');

INSERT INTO dice_rules (die_code, purpose, instructions, result_details, notes) VALUES
('d20','Encounter difficulty','Roll once per workout','1-5 Easy; 6-10 Standard; 11-15 Difficult; 16-19 Boss; 20 Critical','Difficulty changes volume or XP.'),
('d12','Exercise selection','Match the roll to the class exercise list','1-4 current-level choices; 5-8 exercises unlocked 2+ levels ago; 9-12 any unlocked exercise','Reroll if a locked exercise is selected.'),
('d10','Rep style','Roll once per exercise','1-2 Strength; 3-6 Standard; 7-9 Endurance; 10 Heroic effort','Use Heroic effort only when safe.'),
('d8','Repetition roll','Add to the d10 base range','Final reps = base reps + d8 - 1','For timed movements, use seconds instead.'),
('d6','Set roll','Roll once per exercise','Sets = 1 + CEILING(d6 / 2); apply the level maximum',''),
('d4','Workout size','Roll once per workout','1 one exercise; 2-3 two exercises; 4 three exercises','At level 5+, a 4 may produce four exercises.');

INSERT INTO progression_levels (level_number, total_xp_required, unlocks, maximum_sets, optional_extra_exercise) VALUES
(1, 0, Starting exercises, 2, 0),
(2, 100, Level 2 exercises, 2, 0),
(3, 225, Level 3 exercises, 3, 0),
(4, 375, Level 4 exercises, 3, 0),
(5, 550, Level 5 exercises; optional extra exercise, 4, 1),
(6, 750, Level 6 exercises, 4, 0),
(7, 975, Higher resistance or harder variations, 4, 0),
(8, 1225, Level 8 exercises, 5, 0),
(9, 1500, Optional additional exercise, 5, 0),
(10, 1800, Epic-tier workouts and mastery challenges, 5, 0);

INSERT INTO xp_awards (action_name, xp_value, condition_text, notes) VALUES
('Complete an exercise',10,'Per completed exercise',''),
('Complete every assigned set',10,'Workout bonus',''),
('Difficult encounter',10,'d20 result 11-15',''),
('Boss encounter',20,'d20 result 16-19',''),
('Natural 20',NULL,'d20 result 20','Double bonus XP.');

CREATE OR REPLACE VIEW v_unlocked_exercises AS
SELECT c.class_name, c.class_id, ce.slot_number, e.exercise_id, e.exercise_name, ce.unlock_level
FROM class_exercises ce
JOIN classes c ON c.class_id = ce.class_id
JOIN exercises e ON e.exercise_id = ce.exercise_id;

-- Example query: exercises available to a level 3 Wizard
-- SELECT * FROM v_unlocked_exercises WHERE class_name = 'Wizard' AND unlock_level <= 3 ORDER BY slot_number;

-- Example character
-- INSERT INTO characters (character_name, class_id, level_number) VALUES ('My Hero', (SELECT class_id FROM classes WHERE class_name = 'Wizard'), 1);
