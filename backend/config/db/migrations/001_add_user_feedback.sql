-- Migration: Add user_feedback column to emotions table
-- Date: 2025-10-25
-- Description: Adds user_feedback boolean column to track whether user agrees with detected emotion

-- Add user_feedback column (nullable, defaults to NULL which means no feedback yet)
ALTER TABLE emotions
ADD COLUMN IF NOT EXISTS user_feedback BOOLEAN DEFAULT NULL;

-- Add comment to document the column
COMMENT ON COLUMN emotions.user_feedback IS 'User feedback on emotion detection: true = agrees, false = disagrees, null = no feedback yet';
