-- Migration: Add detection_source column to emotions table
-- Date: 2025-11-13
-- Description: Adds detection_source column to track whether emotion was detected from image or manually selected

-- Add detection_source column (defaults to 'image' for backward compatibility)
ALTER TABLE emotions
ADD COLUMN IF NOT EXISTS detection_source VARCHAR(20) NOT NULL DEFAULT 'image';

-- Add comment to document the column
COMMENT ON COLUMN emotions.detection_source IS 'Source of emotion detection: ''image'' = detected from photo, ''manual'' = manually selected by user';
