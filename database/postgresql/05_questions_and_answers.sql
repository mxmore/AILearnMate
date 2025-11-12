-- Questions and Answers Tables

-- Question bank
CREATE TABLE questions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    subject_id UUID REFERENCES subjects(id) ON DELETE SET NULL,
    question_type question_type NOT NULL,
    difficulty_level difficulty_level NOT NULL,
    question_text TEXT NOT NULL,
    question_html TEXT, -- formatted question content
    options JSONB, -- for multiple choice, multiple select, matching
    correct_answer JSONB NOT NULL, -- structured correct answer
    explanation TEXT,
    explanation_html TEXT,
    hints JSONB DEFAULT '[]'::jsonb,
    points DECIMAL(5,2) DEFAULT 1.0,
    time_limit INTEGER, -- seconds
    embedding vector(1536), -- question embedding for similarity search
    source VARCHAR(100), -- 'manual', 'ai_generated', 'imported', 'user_contributed'
    source_reference TEXT, -- original source reference
    quality_score DECIMAL(5,2), -- 0-100, AI-evaluated quality
    usage_count INTEGER DEFAULT 0,
    correct_rate DECIMAL(5,4), -- overall correct rate
    is_active BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false,
    verified_by UUID REFERENCES users(id) ON DELETE SET NULL,
    verified_at TIMESTAMP WITH TIME ZONE,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_by UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Question-knowledge point mapping (many-to-many)
CREATE TABLE question_knowledge_points (
    question_id UUID NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
    knowledge_point_id UUID NOT NULL REFERENCES knowledge_points(id) ON DELETE CASCADE,
    relevance_score DECIMAL(3,2) DEFAULT 1.0, -- 0-1
    is_primary BOOLEAN DEFAULT false,
    PRIMARY KEY (question_id, knowledge_point_id)
);

-- Question tags (many-to-many)
CREATE TABLE question_tags (
    question_id UUID NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
    tag_id UUID NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    PRIMARY KEY (question_id, tag_id)
);

-- Question media/attachments
CREATE TABLE question_attachments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    question_id UUID NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
    file_type VARCHAR(50) NOT NULL, -- 'image', 'audio', 'video', 'document'
    file_url TEXT NOT NULL,
    file_size INTEGER,
    mime_type VARCHAR(100),
    caption TEXT,
    display_order INTEGER DEFAULT 0,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Question variations (alternative versions)
CREATE TABLE question_variations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    parent_question_id UUID NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
    variation_type VARCHAR(50) NOT NULL, -- 'language', 'difficulty', 'format', 'context'
    question_id UUID NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(parent_question_id, question_id)
);

-- User question attempts
CREATE TABLE question_attempts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    question_id UUID NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
    session_id UUID, -- reference to study session
    user_answer JSONB NOT NULL,
    is_correct BOOLEAN NOT NULL,
    partial_credit DECIMAL(5,2), -- for partial scoring
    time_spent INTEGER, -- seconds
    hint_used BOOLEAN DEFAULT false,
    hints_viewed INTEGER DEFAULT 0,
    confidence_level INTEGER, -- 1-5
    ai_feedback TEXT, -- AI-generated feedback
    feedback_score DECIMAL(5,2), -- quality of AI feedback
    attempt_number INTEGER DEFAULT 1,
    attempted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Question reviews and feedback
CREATE TABLE question_reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    question_id UUID NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    feedback_type VARCHAR(50), -- 'unclear', 'incorrect', 'too_easy', 'too_hard', 'great'
    comment TEXT,
    is_resolved BOOLEAN DEFAULT false,
    resolved_by UUID REFERENCES users(id) ON DELETE SET NULL,
    resolved_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_questions_subject_id ON questions(subject_id);
CREATE INDEX idx_questions_type ON questions(question_type);
CREATE INDEX idx_questions_difficulty ON questions(difficulty_level);
CREATE INDEX idx_questions_source ON questions(source);
CREATE INDEX idx_questions_active ON questions(is_active);
CREATE INDEX idx_questions_verified ON questions(is_verified);
CREATE INDEX idx_questions_quality ON questions(quality_score);
CREATE INDEX idx_questions_correct_rate ON questions(correct_rate);
CREATE INDEX idx_questions_created_by ON questions(created_by);
CREATE INDEX idx_question_knowledge_points_question_id ON question_knowledge_points(question_id);
CREATE INDEX idx_question_knowledge_points_kp_id ON question_knowledge_points(knowledge_point_id);
CREATE INDEX idx_question_knowledge_points_primary ON question_knowledge_points(is_primary);
CREATE INDEX idx_question_attachments_question_id ON question_attachments(question_id);
CREATE INDEX idx_question_variations_parent ON question_variations(parent_question_id);
CREATE INDEX idx_question_attempts_user_id ON question_attempts(user_id);
CREATE INDEX idx_question_attempts_question_id ON question_attempts(question_id);
CREATE INDEX idx_question_attempts_session_id ON question_attempts(session_id);
CREATE INDEX idx_question_attempts_correct ON question_attempts(is_correct);
CREATE INDEX idx_question_attempts_attempted_at ON question_attempts(attempted_at);
CREATE INDEX idx_question_reviews_question_id ON question_reviews(question_id);
CREATE INDEX idx_question_reviews_user_id ON question_reviews(user_id);
CREATE INDEX idx_question_reviews_resolved ON question_reviews(is_resolved);

-- Vector similarity search index
CREATE INDEX idx_questions_embedding ON questions USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);

-- GIN indexes for JSONB columns
CREATE INDEX idx_questions_options_gin ON questions USING gin(options);
CREATE INDEX idx_questions_correct_answer_gin ON questions USING gin(correct_answer);
CREATE INDEX idx_questions_hints_gin ON questions USING gin(hints);
CREATE INDEX idx_questions_metadata_gin ON questions USING gin(metadata);
CREATE INDEX idx_question_attempts_answer_gin ON question_attempts USING gin(user_answer);

-- Full-text search indexes
CREATE INDEX idx_questions_text_search ON questions USING gin(to_tsvector('simple', question_text));
CREATE INDEX idx_questions_explanation_search ON questions USING gin(to_tsvector('simple', explanation));

-- Comments
COMMENT ON TABLE questions IS 'Question bank with various question types';
COMMENT ON TABLE question_knowledge_points IS 'Links questions to knowledge points';
COMMENT ON TABLE question_tags IS 'Tags for questions';
COMMENT ON TABLE question_attachments IS 'Media attachments for questions';
COMMENT ON TABLE question_variations IS 'Alternative versions of questions';
COMMENT ON TABLE question_attempts IS 'User attempts at answering questions';
COMMENT ON TABLE question_reviews IS 'User feedback and reviews on questions';

COMMENT ON COLUMN questions.embedding IS 'Vector embedding for semantic similarity search';
COMMENT ON COLUMN questions.quality_score IS 'AI-evaluated question quality (0-100)';
COMMENT ON COLUMN questions.correct_rate IS 'Overall correct answer rate across all users';
COMMENT ON COLUMN question_attempts.partial_credit IS 'Partial credit for partially correct answers';
COMMENT ON COLUMN question_attempts.ai_feedback IS 'AI-generated personalized feedback';
