-- Study Materials and Resources

-- Study materials
CREATE TABLE study_materials (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    subject_id UUID REFERENCES subjects(id) ON DELETE SET NULL,
    title VARCHAR(500) NOT NULL,
    description TEXT,
    material_type material_type NOT NULL,
    file_url TEXT,
    file_size INTEGER,
    duration INTEGER, -- for video/audio in seconds
    page_count INTEGER, -- for documents
    content_text TEXT, -- extracted text content
    content_html TEXT, -- formatted content
    thumbnail_url TEXT,
    difficulty_level difficulty_level,
    language VARCHAR(10) DEFAULT 'zh-CN',
    embedding vector(1536), -- content embedding for similarity
    source VARCHAR(100),
    author VARCHAR(200),
    publisher VARCHAR(200),
    publication_date DATE,
    isbn VARCHAR(20),
    view_count INTEGER DEFAULT 0,
    download_count INTEGER DEFAULT 0,
    average_rating DECIMAL(3,2),
    rating_count INTEGER DEFAULT 0,
    estimated_reading_time INTEGER, -- minutes
    is_active BOOLEAN DEFAULT true,
    is_premium BOOLEAN DEFAULT false,
    processing_status processing_status DEFAULT 'completed',
    processed_at TIMESTAMP WITH TIME ZONE,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_by UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Material-knowledge point mapping
CREATE TABLE material_knowledge_points (
    material_id UUID NOT NULL REFERENCES study_materials(id) ON DELETE CASCADE,
    knowledge_point_id UUID NOT NULL REFERENCES knowledge_points(id) ON DELETE CASCADE,
    relevance_score DECIMAL(3,2) DEFAULT 1.0,
    PRIMARY KEY (material_id, knowledge_point_id)
);

-- Material tags
CREATE TABLE material_tags (
    material_id UUID NOT NULL REFERENCES study_materials(id) ON DELETE CASCADE,
    tag_id UUID NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    PRIMARY KEY (material_id, tag_id)
);

-- Material sections/chapters (for structured content)
CREATE TABLE material_sections (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    material_id UUID NOT NULL REFERENCES study_materials(id) ON DELETE CASCADE,
    parent_section_id UUID REFERENCES material_sections(id) ON DELETE CASCADE,
    title VARCHAR(500) NOT NULL,
    content TEXT,
    start_page INTEGER,
    end_page INTEGER,
    start_time INTEGER, -- for video/audio in seconds
    end_time INTEGER,
    level INTEGER DEFAULT 1,
    display_order INTEGER DEFAULT 0,
    embedding vector(1536),
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- User material progress
CREATE TABLE user_material_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    material_id UUID NOT NULL REFERENCES study_materials(id) ON DELETE CASCADE,
    status learning_status DEFAULT 'not_started',
    progress_percentage DECIMAL(5,2) DEFAULT 0.0,
    current_page INTEGER,
    current_time INTEGER, -- for video/audio
    total_time_spent INTEGER DEFAULT 0, -- minutes
    notes_count INTEGER DEFAULT 0,
    highlights_count INTEGER DEFAULT 0,
    last_accessed_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, material_id)
);

-- User notes on materials
CREATE TABLE material_notes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    material_id UUID NOT NULL REFERENCES study_materials(id) ON DELETE CASCADE,
    section_id UUID REFERENCES material_sections(id) ON DELETE CASCADE,
    note_text TEXT NOT NULL,
    note_type VARCHAR(50) DEFAULT 'note', -- 'note', 'highlight', 'bookmark', 'question'
    page_number INTEGER,
    position_data JSONB, -- for precise positioning
    color VARCHAR(20),
    is_private BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Material ratings
CREATE TABLE material_ratings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    material_id UUID NOT NULL REFERENCES study_materials(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    helpful_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(material_id, user_id)
);

-- Indexes
CREATE INDEX idx_study_materials_subject_id ON study_materials(subject_id);
CREATE INDEX idx_study_materials_type ON study_materials(material_type);
CREATE INDEX idx_study_materials_difficulty ON study_materials(difficulty_level);
CREATE INDEX idx_study_materials_active ON study_materials(is_active);
CREATE INDEX idx_study_materials_premium ON study_materials(is_premium);
CREATE INDEX idx_study_materials_status ON study_materials(processing_status);
CREATE INDEX idx_study_materials_created_by ON study_materials(created_by);
CREATE INDEX idx_study_materials_rating ON study_materials(average_rating);
CREATE INDEX idx_material_sections_material_id ON material_sections(material_id);
CREATE INDEX idx_material_sections_parent_id ON material_sections(parent_section_id);
CREATE INDEX idx_user_material_progress_user_id ON user_material_progress(user_id);
CREATE INDEX idx_user_material_progress_material_id ON user_material_progress(material_id);
CREATE INDEX idx_user_material_progress_status ON user_material_progress(status);
CREATE INDEX idx_material_notes_user_id ON material_notes(user_id);
CREATE INDEX idx_material_notes_material_id ON material_notes(material_id);
CREATE INDEX idx_material_notes_section_id ON material_notes(section_id);
CREATE INDEX idx_material_notes_type ON material_notes(note_type);
CREATE INDEX idx_material_ratings_material_id ON material_ratings(material_id);
CREATE INDEX idx_material_ratings_user_id ON material_ratings(user_id);

-- Vector similarity search indexes
CREATE INDEX idx_study_materials_embedding ON study_materials USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);
CREATE INDEX idx_material_sections_embedding ON material_sections USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);

-- GIN indexes for JSONB
CREATE INDEX idx_study_materials_metadata_gin ON study_materials USING gin(metadata);
CREATE INDEX idx_material_sections_metadata_gin ON material_sections USING gin(metadata);
CREATE INDEX idx_material_notes_position_gin ON material_notes USING gin(position_data);

-- Full-text search indexes
CREATE INDEX idx_study_materials_text_search ON study_materials USING gin(to_tsvector('simple', coalesce(title, '') || ' ' || coalesce(description, '') || ' ' || coalesce(content_text, '')));
CREATE INDEX idx_material_notes_text_search ON material_notes USING gin(to_tsvector('simple', note_text));

-- Comments
COMMENT ON TABLE study_materials IS 'Study materials library (PDFs, videos, etc.)';
COMMENT ON TABLE material_knowledge_points IS 'Links materials to knowledge points';
COMMENT ON TABLE material_sections IS 'Hierarchical sections/chapters within materials';
COMMENT ON TABLE user_material_progress IS 'User progress through materials';
COMMENT ON TABLE material_notes IS 'User notes, highlights, and bookmarks';
COMMENT ON TABLE material_ratings IS 'User ratings and reviews for materials';

COMMENT ON COLUMN study_materials.embedding IS 'Vector embedding for content similarity search';
COMMENT ON COLUMN study_materials.processing_status IS 'Status of content extraction and processing';
COMMENT ON COLUMN material_notes.position_data IS 'JSON data for precise positioning of notes/highlights';
