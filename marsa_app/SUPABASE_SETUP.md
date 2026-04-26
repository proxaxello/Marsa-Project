# Supabase Database Setup for Dictionary Brain

## Required Tables

### 1. Search History Table

```sql
-- Create search_history table
CREATE TABLE search_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  word TEXT NOT NULL,
  timestamp TIMESTAMPTZ DEFAULT NOW()
);

-- Create index for faster queries
CREATE INDEX idx_search_history_user_id ON search_history(user_id);
CREATE INDEX idx_search_history_timestamp ON search_history(timestamp DESC);

-- Enable Row Level Security
ALTER TABLE search_history ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their own search history
CREATE POLICY "Users can view own search history"
  ON search_history
  FOR SELECT
  USING (auth.uid() = user_id);

-- Policy: Users can insert their own search history
CREATE POLICY "Users can insert own search history"
  ON search_history
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can delete their own search history
CREATE POLICY "Users can delete own search history"
  ON search_history
  FOR DELETE
  USING (auth.uid() = user_id);
```

### 2. Vocabulary Folders Table

```sql
-- Create vocabulary_folders table
CREATE TABLE vocabulary_folders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index
CREATE INDEX idx_vocabulary_folders_user_id ON vocabulary_folders(user_id);

-- Enable Row Level Security
ALTER TABLE vocabulary_folders ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view own folders
CREATE POLICY "Users can view own folders"
  ON vocabulary_folders
  FOR SELECT
  USING (auth.uid() = user_id);

-- Policy: Users can insert own folders
CREATE POLICY "Users can insert own folders"
  ON vocabulary_folders
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update own folders
CREATE POLICY "Users can update own folders"
  ON vocabulary_folders
  FOR UPDATE
  USING (auth.uid() = user_id);

-- Policy: Users can delete own folders
CREATE POLICY "Users can delete own folders"
  ON vocabulary_folders
  FOR DELETE
  USING (auth.uid() = user_id);
```

### 3. Folder Words Table

```sql
-- Create folder_words table
CREATE TABLE folder_words (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  folder_id UUID REFERENCES vocabulary_folders(id) ON DELETE CASCADE,
  word TEXT NOT NULL,
  added_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index
CREATE INDEX idx_folder_words_folder_id ON folder_words(folder_id);

-- Enable Row Level Security
ALTER TABLE folder_words ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view words in their folders
CREATE POLICY "Users can view words in own folders"
  ON folder_words
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM vocabulary_folders
      WHERE vocabulary_folders.id = folder_words.folder_id
      AND vocabulary_folders.user_id = auth.uid()
    )
  );

-- Policy: Users can insert words into their folders
CREATE POLICY "Users can insert words into own folders"
  ON folder_words
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM vocabulary_folders
      WHERE vocabulary_folders.id = folder_words.folder_id
      AND vocabulary_folders.user_id = auth.uid()
    )
  );

-- Policy: Users can delete words from their folders
CREATE POLICY "Users can delete words from own folders"
  ON folder_words
  FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM vocabulary_folders
      WHERE vocabulary_folders.id = folder_words.folder_id
      AND vocabulary_folders.user_id = auth.uid()
    )
  );
```

## Setup Instructions

1. **Open Supabase Dashboard:**
   - Go to https://supabase.com/dashboard
   - Select your project

2. **Navigate to SQL Editor:**
   - Click on "SQL Editor" in the left sidebar
   - Click "New Query"

3. **Run SQL Scripts:**
   - Copy and paste each SQL block above
   - Run them one by one
   - Verify tables are created in "Table Editor"

4. **Verify Row Level Security:**
   - Go to "Authentication" > "Policies"
   - Ensure all policies are enabled
   - Test with a user account

## Testing

After setup, test the functionality:

1. **Search History:**
   - Search for a word in the app
   - Check if it appears in `search_history` table
   - Verify only the user's own searches are visible

2. **Vocabulary Folders:**
   - Create a folder in the app (when implemented)
   - Add words to the folder
   - Verify data in `vocabulary_folders` and `folder_words` tables

## Notes

- All tables use UUID for primary keys
- Row Level Security (RLS) is enabled for data privacy
- Timestamps are stored in UTC
- Cascade deletes ensure data consistency
- Indexes are created for performance optimization
