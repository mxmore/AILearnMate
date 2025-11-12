-- Knowledge Points and Subject Taxonomy

-- Subjects/Courses
CREATE TABLE subjects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(200) NOT NULL,
    code VARCHAR(50) UNIQUE,
    description TEXT,
    category VARCHAR(100),
    difficulty_level difficulty_level,
    icon_url TEXT,
    color VARCHAR(20),
    is_active BOOLEAN DEFAULT true,
    display_order INTEGER DEFAULT 0,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Knowledge points (hierarchical)
CREATE TABLE knowledge_points (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
    parent_id UUID REFERENCES knowledge_points(id) ON DELETE SET NULL,
    name VARCHAR(200) NOT NULL,
    code VARCHAR(100),
    description TEXT,
    learning_objectives TEXT[],
    difficulty_level difficulty_level,
    estimated_study_time INTEGER, -- minutes
    prerequisites UUID[], -- array of knowledge_point ids
    level INTEGER DEFAULT 1, -- hierarchy level
    path TEXT, -- materialized path for hierarchical queries
    embedding vector(1536), -- OpenAI ada-002 embedding dimension
    is_active BOOLEAN DEFAULT true,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Knowledge point relationships
CREATE TABLE knowledge_point_relations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    source_id UUID NOT NULL REFERENCES knowledge_points(id) ON DELETE CASCADE,
    target_id UUID NOT NULL REFERENCES knowledge_points(id) ON DELETE CASCADE,
    relation_type VARCHAR(50) NOT NULL, -- 'prerequisite', 'related', 'extends', 'alternative'
    weight DECIMAL(3,2) DEFAULT 1.0,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(source_id, target_id, relation_type)
);

-- User knowledge point mastery
CREATE TABLE user_knowledge_mastery (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    knowledge_point_id UUID NOT NULL REFERENCES knowledge_points(id) ON DELETE CASCADE,
    mastery_level DECIMAL(5,2) DEFAULT 0.0, -- 0-100
    status learning_status DEFAULT 'not_started',
    total_practice_time INTEGER DEFAULT 0, -- minutes
    correct_attempts INTEGER DEFAULT 0,
    total_attempts INTEGER DEFAULT 0,
    last_reviewed_at TIMESTAMP WITH TIME ZONE,
    next_review_at TIMESTAMP WITH TIME ZONE,
    srs_stage srs_stage DEFAULT 'new',
    srs_interval INTEGER DEFAULT 0, -- days
    srs_ease_factor DECIMAL(3,2) DEFAULT 2.5,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, knowledge_point_id)
);

-- Tags for flexible categorization
CREATE TABLE tags (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) UNIQUE NOT NULL,
    category VARCHAR(50),
    color VARCHAR(20),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Knowledge point tags (many-to-many)
CREATE TABLE knowledge_point_tags (
    knowledge_point_id UUID NOT NULL REFERENCES knowledge_points(id) ON DELETE CASCADE,
    tag_id UUID NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    PRIMARY KEY (knowledge_point_id, tag_id)
);

-- Indexes
CREATE INDEX idx_subjects_code ON subjects(code);
CREATE INDEX idx_subjects_category ON subjects(category);
CREATE INDEX idx_subjects_active ON subjects(is_active);
CREATE INDEX idx_knowledge_points_subject_id ON knowledge_points(subject_id);
CREATE INDEX idx_knowledge_points_parent_id ON knowledge_points(parent_id);
CREATE INDEX idx_knowledge_points_code ON knowledge_points(code);
CREATE INDEX idx_knowledge_points_path ON knowledge_points(path);
CREATE INDEX idx_knowledge_points_level ON knowledge_points(level);
CREATE INDEX idx_knowledge_point_relations_source ON knowledge_point_relations(source_id);
CREATE INDEX idx_knowledge_point_relations_target ON knowledge_point_relations(target_id);
CREATE INDEX idx_user_knowledge_mastery_user_id ON user_knowledge_mastery(user_id);
CREATE INDEX idx_user_knowledge_mastery_kp_id ON user_knowledge_mastery(knowledge_point_id);
CREATE INDEX idx_user_knowledge_mastery_status ON user_knowledge_mastery(status);
CREATE INDEX idx_user_knowledge_mastery_next_review ON user_knowledge_mastery(next_review_at);
CREATE INDEX idx_tags_name ON tags(name);
CREATE INDEX idx_tags_category ON tags(category);

-- Vector similarity search index
CREATE INDEX idx_knowledge_points_embedding ON knowledge_points USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);

-- GIN indexes for JSONB and array columns
CREATE INDEX idx_subjects_metadata_gin ON subjects USING gin(metadata);
CREATE INDEX idx_knowledge_points_metadata_gin ON knowledge_points USING gin(metadata);
CREATE INDEX idx_knowledge_points_objectives_gin ON knowledge_points USING gin(learning_objectives);
CREATE INDEX idx_knowledge_points_prerequisites_gin ON knowledge_points USING gin(prerequisites);

-- Comments
COMMENT ON TABLE subjects IS 'Main subjects/courses in the learning system';
COMMENT ON TABLE knowledge_points IS 'Hierarchical knowledge points within subjects';
COMMENT ON TABLE knowledge_point_relations IS 'Relationships between knowledge points';
COMMENT ON TABLE user_knowledge_mastery IS 'User mastery level for each knowledge point with SRS data';
COMMENT ON TABLE tags IS 'Flexible tags for categorization';

COMMENT ON COLUMN knowledge_points.embedding IS 'Vector embedding for semantic search';
COMMENT ON COLUMN knowledge_points.path IS 'Materialized path for efficient hierarchical queries';
COMMENT ON COLUMN user_knowledge_mastery.srs_stage IS 'Spaced Repetition System stage';
COMMENT ON COLUMN user_knowledge_mastery.srs_ease_factor IS 'SRS ease factor for interval calculation';
