-- Study Sessions and Learning Plans

-- Study sessions
CREATE TABLE study_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_type session_type NOT NULL,
    subject_id UUID REFERENCES subjects(id) ON DELETE SET NULL,
    title VARCHAR(200),
    description TEXT,
    target_knowledge_points UUID[], -- array of knowledge point ids
    total_questions INTEGER DEFAULT 0,
    correct_answers INTEGER DEFAULT 0,
    session_score DECIMAL(5,2),
    time_spent INTEGER DEFAULT 0, -- seconds
    started_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP WITH TIME ZONE,
    is_completed BOOLEAN DEFAULT false,
    performance_data JSONB DEFAULT '{}'::jsonb,
    metadata JSONB DEFAULT '{}'::jsonb
);

-- Study plans
CREATE TABLE study_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    subject_id UUID REFERENCES subjects(id) ON DELETE SET NULL,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    goal_description TEXT,
    target_date DATE,
    difficulty_level difficulty_level,
    daily_time_commitment INTEGER, -- minutes
    weekly_schedule JSONB, -- day-wise schedule
    status VARCHAR(50) DEFAULT 'active', -- 'active', 'paused', 'completed', 'abandoned'
    progress_percentage DECIMAL(5,2) DEFAULT 0.0,
    is_ai_generated BOOLEAN DEFAULT false,
    total_sessions_planned INTEGER DEFAULT 0,
    total_sessions_completed INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE
);

-- Study plan milestones
CREATE TABLE study_plan_milestones (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    plan_id UUID NOT NULL REFERENCES study_plans(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    target_date DATE,
    knowledge_points UUID[], -- target knowledge points
    success_criteria JSONB,
    is_completed BOOLEAN DEFAULT false,
    completed_at TIMESTAMP WITH TIME ZONE,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Study plan activities (scheduled tasks)
CREATE TABLE study_plan_activities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    plan_id UUID NOT NULL REFERENCES study_plans(id) ON DELETE CASCADE,
    milestone_id UUID REFERENCES study_plan_milestones(id) ON DELETE SET NULL,
    activity_type VARCHAR(50) NOT NULL, -- 'practice', 'read_material', 'watch_video', 'review', 'test'
    title VARCHAR(200) NOT NULL,
    description TEXT,
    scheduled_date DATE NOT NULL,
    scheduled_time TIME,
    estimated_duration INTEGER, -- minutes
    knowledge_point_ids UUID[],
    material_ids UUID[],
    question_ids UUID[],
    is_completed BOOLEAN DEFAULT false,
    completed_at TIMESTAMP WITH TIME ZONE,
    session_id UUID REFERENCES study_sessions(id) ON DELETE SET NULL,
    display_order INTEGER DEFAULT 0,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Daily study records (for streak tracking and SRS)
CREATE TABLE daily_study_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    study_date DATE NOT NULL,
    total_time_spent INTEGER DEFAULT 0, -- minutes
    sessions_completed INTEGER DEFAULT 0,
    questions_attempted INTEGER DEFAULT 0,
    questions_correct INTEGER DEFAULT 0,
    materials_studied INTEGER DEFAULT 0,
    knowledge_points_practiced UUID[],
    streak_day_number INTEGER DEFAULT 1,
    daily_goal_met BOOLEAN DEFAULT false,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, study_date)
);

-- SRS review schedule (Spaced Repetition System)
CREATE TABLE srs_review_schedule (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    knowledge_point_id UUID NOT NULL REFERENCES knowledge_points(id) ON DELETE CASCADE,
    question_id UUID REFERENCES questions(id) ON DELETE CASCADE,
    review_type VARCHAR(50) NOT NULL, -- 'knowledge_point', 'question', 'material'
    scheduled_date DATE NOT NULL,
    priority_score DECIMAL(5,2) DEFAULT 0.0,
    is_reviewed BOOLEAN DEFAULT false,
    reviewed_at TIMESTAMP WITH TIME ZONE,
    next_review_date DATE,
    interval_days INTEGER,
    ease_factor DECIMAL(3,2) DEFAULT 2.5,
    repetitions INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Adaptive learning recommendations
CREATE TABLE learning_recommendations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    recommendation_type VARCHAR(50) NOT NULL, -- 'question', 'material', 'knowledge_point', 'study_plan'
    target_id UUID NOT NULL, -- id of the recommended item
    reasoning TEXT,
    confidence_score DECIMAL(5,2), -- 0-100
    priority INTEGER DEFAULT 0,
    is_dismissed BOOLEAN DEFAULT false,
    is_completed BOOLEAN DEFAULT false,
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_study_sessions_user_id ON study_sessions(user_id);
CREATE INDEX idx_study_sessions_type ON study_sessions(session_type);
CREATE INDEX idx_study_sessions_subject_id ON study_sessions(subject_id);
CREATE INDEX idx_study_sessions_started_at ON study_sessions(started_at);
CREATE INDEX idx_study_sessions_completed ON study_sessions(is_completed);
CREATE INDEX idx_study_plans_user_id ON study_plans(user_id);
CREATE INDEX idx_study_plans_subject_id ON study_plans(subject_id);
CREATE INDEX idx_study_plans_status ON study_plans(status);
CREATE INDEX idx_study_plans_target_date ON study_plans(target_date);
CREATE INDEX idx_study_plan_milestones_plan_id ON study_plan_milestones(plan_id);
CREATE INDEX idx_study_plan_milestones_completed ON study_plan_milestones(is_completed);
CREATE INDEX idx_study_plan_activities_plan_id ON study_plan_activities(plan_id);
CREATE INDEX idx_study_plan_activities_milestone_id ON study_plan_activities(milestone_id);
CREATE INDEX idx_study_plan_activities_date ON study_plan_activities(scheduled_date);
CREATE INDEX idx_study_plan_activities_completed ON study_plan_activities(is_completed);
CREATE INDEX idx_daily_study_records_user_id ON daily_study_records(user_id);
CREATE INDEX idx_daily_study_records_date ON daily_study_records(study_date);
CREATE INDEX idx_srs_review_schedule_user_id ON srs_review_schedule(user_id);
CREATE INDEX idx_srs_review_schedule_kp_id ON srs_review_schedule(knowledge_point_id);
CREATE INDEX idx_srs_review_schedule_question_id ON srs_review_schedule(question_id);
CREATE INDEX idx_srs_review_schedule_date ON srs_review_schedule(scheduled_date);
CREATE INDEX idx_srs_review_schedule_reviewed ON srs_review_schedule(is_reviewed);
CREATE INDEX idx_learning_recommendations_user_id ON learning_recommendations(user_id);
CREATE INDEX idx_learning_recommendations_type ON learning_recommendations(recommendation_type);
CREATE INDEX idx_learning_recommendations_completed ON learning_recommendations(is_completed);

-- GIN indexes for JSONB and array columns
CREATE INDEX idx_study_sessions_performance_gin ON study_sessions USING gin(performance_data);
CREATE INDEX idx_study_sessions_metadata_gin ON study_sessions USING gin(metadata);
CREATE INDEX idx_study_sessions_target_kps_gin ON study_sessions USING gin(target_knowledge_points);
CREATE INDEX idx_study_plans_schedule_gin ON study_plans USING gin(weekly_schedule);
CREATE INDEX idx_study_plan_milestones_criteria_gin ON study_plan_milestones USING gin(success_criteria);
CREATE INDEX idx_study_plan_milestones_kps_gin ON study_plan_milestones USING gin(knowledge_points);
CREATE INDEX idx_study_plan_activities_kps_gin ON study_plan_activities USING gin(knowledge_point_ids);
CREATE INDEX idx_daily_study_records_kps_gin ON daily_study_records USING gin(knowledge_points_practiced);

-- Comments
COMMENT ON TABLE study_sessions IS 'Individual study sessions with performance tracking';
COMMENT ON TABLE study_plans IS 'Long-term study plans with goals and schedules';
COMMENT ON TABLE study_plan_milestones IS 'Milestones within study plans';
COMMENT ON TABLE study_plan_activities IS 'Scheduled activities in study plans';
COMMENT ON TABLE daily_study_records IS 'Daily aggregated study records for streaks and analytics';
COMMENT ON TABLE srs_review_schedule IS 'Spaced Repetition System review schedule';
COMMENT ON TABLE learning_recommendations IS 'AI-generated personalized learning recommendations';

COMMENT ON COLUMN study_sessions.performance_data IS 'Detailed performance metrics and analytics';
COMMENT ON COLUMN study_plans.weekly_schedule IS 'Day-wise study schedule preferences';
COMMENT ON COLUMN srs_review_schedule.ease_factor IS 'Ease factor for calculating next review interval';
COMMENT ON COLUMN learning_recommendations.confidence_score IS 'AI confidence in the recommendation (0-100)';
