-- Analytics and Reporting Tables

-- Performance analytics snapshots
CREATE TABLE performance_snapshots (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    snapshot_date DATE NOT NULL,
    snapshot_type VARCHAR(50) DEFAULT 'daily', -- 'daily', 'weekly', 'monthly'
    subject_id UUID REFERENCES subjects(id) ON DELETE SET NULL,
    knowledge_point_id UUID REFERENCES knowledge_points(id) ON DELETE SET NULL,
    metrics JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, snapshot_date, snapshot_type, subject_id, knowledge_point_id)
);

-- Learning analytics events
CREATE TABLE learning_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    event_type VARCHAR(100) NOT NULL,
    event_name VARCHAR(200) NOT NULL,
    event_category VARCHAR(50),
    properties JSONB DEFAULT '{}'::jsonb,
    session_id VARCHAR(100),
    device_type VARCHAR(50),
    platform VARCHAR(50),
    ip_address INET,
    user_agent TEXT,
    referrer TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Performance reports
CREATE TABLE performance_reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    report_type VARCHAR(50) NOT NULL, -- 'weekly', 'monthly', 'subject', 'comprehensive'
    report_period_start DATE NOT NULL,
    report_period_end DATE NOT NULL,
    subject_id UUID REFERENCES subjects(id) ON DELETE SET NULL,
    title VARCHAR(500),
    summary TEXT,
    report_data JSONB NOT NULL,
    insights TEXT[],
    recommendations TEXT[],
    strengths TEXT[],
    weaknesses TEXT[],
    overall_score DECIMAL(5,2),
    generated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Subject mastery tracking
CREATE TABLE subject_mastery_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
    mastery_level DECIMAL(5,2) NOT NULL, -- 0-100
    knowledge_points_mastered INTEGER DEFAULT 0,
    knowledge_points_total INTEGER DEFAULT 0,
    questions_correct INTEGER DEFAULT 0,
    questions_total INTEGER DEFAULT 0,
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Study time tracking
CREATE TABLE study_time_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    activity_type VARCHAR(50) NOT NULL, -- 'reading', 'practice', 'video', 'review'
    subject_id UUID REFERENCES subjects(id) ON DELETE SET NULL,
    knowledge_point_id UUID REFERENCES knowledge_points(id) ON DELETE SET NULL,
    material_id UUID REFERENCES study_materials(id) ON DELETE SET NULL,
    question_id UUID REFERENCES questions(id) ON DELETE SET NULL,
    session_id UUID REFERENCES study_sessions(id) ON DELETE CASCADE,
    duration_seconds INTEGER NOT NULL,
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE NOT NULL,
    is_focused BOOLEAN DEFAULT true, -- whether user was actively engaged
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Learning patterns and behaviors
CREATE TABLE learning_patterns (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    pattern_type VARCHAR(50) NOT NULL, -- 'time_preference', 'difficulty_preference', 'learning_style'
    pattern_data JSONB NOT NULL,
    confidence_score DECIMAL(5,2), -- 0-100
    detected_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- A/B testing experiments
CREATE TABLE ab_test_experiments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    experiment_name VARCHAR(200) UNIQUE NOT NULL,
    description TEXT,
    hypothesis TEXT,
    variants JSONB NOT NULL, -- list of variant configurations
    target_metric VARCHAR(100) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    status VARCHAR(50) DEFAULT 'active', -- 'draft', 'active', 'paused', 'completed'
    total_participants INTEGER DEFAULT 0,
    results JSONB,
    winner_variant VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- User experiment assignments
CREATE TABLE user_experiment_assignments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    experiment_id UUID NOT NULL REFERENCES ab_test_experiments(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    variant_name VARCHAR(50) NOT NULL,
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(experiment_id, user_id)
);

-- Experiment events
CREATE TABLE experiment_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    experiment_id UUID NOT NULL REFERENCES ab_test_experiments(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    variant_name VARCHAR(50) NOT NULL,
    event_name VARCHAR(100) NOT NULL,
    event_value DECIMAL(10,2),
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- System metrics and health
CREATE TABLE system_metrics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    metric_name VARCHAR(100) NOT NULL,
    metric_category VARCHAR(50), -- 'performance', 'usage', 'quality', 'cost'
    metric_value DECIMAL(12,2) NOT NULL,
    metric_unit VARCHAR(50),
    dimensions JSONB DEFAULT '{}'::jsonb,
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_performance_snapshots_user_id ON performance_snapshots(user_id);
CREATE INDEX idx_performance_snapshots_date ON performance_snapshots(snapshot_date);
CREATE INDEX idx_performance_snapshots_type ON performance_snapshots(snapshot_type);
CREATE INDEX idx_performance_snapshots_subject_id ON performance_snapshots(subject_id);
CREATE INDEX idx_learning_events_user_id ON learning_events(user_id);
CREATE INDEX idx_learning_events_type ON learning_events(event_type);
CREATE INDEX idx_learning_events_created_at ON learning_events(created_at);
CREATE INDEX idx_learning_events_session_id ON learning_events(session_id);
CREATE INDEX idx_performance_reports_user_id ON performance_reports(user_id);
CREATE INDEX idx_performance_reports_type ON performance_reports(report_type);
CREATE INDEX idx_performance_reports_period ON performance_reports(report_period_start, report_period_end);
CREATE INDEX idx_subject_mastery_history_user_id ON subject_mastery_history(user_id);
CREATE INDEX idx_subject_mastery_history_subject_id ON subject_mastery_history(subject_id);
CREATE INDEX idx_subject_mastery_history_recorded_at ON subject_mastery_history(recorded_at);
CREATE INDEX idx_study_time_logs_user_id ON study_time_logs(user_id);
CREATE INDEX idx_study_time_logs_session_id ON study_time_logs(session_id);
CREATE INDEX idx_study_time_logs_activity_type ON study_time_logs(activity_type);
CREATE INDEX idx_study_time_logs_start_time ON study_time_logs(start_time);
CREATE INDEX idx_learning_patterns_user_id ON learning_patterns(user_id);
CREATE INDEX idx_learning_patterns_type ON learning_patterns(pattern_type);
CREATE INDEX idx_ab_test_experiments_status ON ab_test_experiments(status);
CREATE INDEX idx_user_experiment_assignments_user_id ON user_experiment_assignments(user_id);
CREATE INDEX idx_user_experiment_assignments_experiment_id ON user_experiment_assignments(experiment_id);
CREATE INDEX idx_experiment_events_experiment_id ON experiment_events(experiment_id);
CREATE INDEX idx_experiment_events_user_id ON experiment_events(user_id);
CREATE INDEX idx_experiment_events_created_at ON experiment_events(created_at);
CREATE INDEX idx_system_metrics_name ON system_metrics(metric_name);
CREATE INDEX idx_system_metrics_category ON system_metrics(metric_category);
CREATE INDEX idx_system_metrics_recorded_at ON system_metrics(recorded_at);

-- GIN indexes for JSONB
CREATE INDEX idx_performance_snapshots_metrics_gin ON performance_snapshots USING gin(metrics);
CREATE INDEX idx_learning_events_properties_gin ON learning_events USING gin(properties);
CREATE INDEX idx_performance_reports_data_gin ON performance_reports USING gin(report_data);
CREATE INDEX idx_study_time_logs_metadata_gin ON study_time_logs USING gin(metadata);
CREATE INDEX idx_learning_patterns_data_gin ON learning_patterns USING gin(pattern_data);
CREATE INDEX idx_ab_test_experiments_variants_gin ON ab_test_experiments USING gin(variants);
CREATE INDEX idx_ab_test_experiments_results_gin ON ab_test_experiments USING gin(results);
CREATE INDEX idx_experiment_events_metadata_gin ON experiment_events USING gin(metadata);
CREATE INDEX idx_system_metrics_dimensions_gin ON system_metrics USING gin(dimensions);

-- Comments
COMMENT ON TABLE performance_snapshots IS 'Periodic snapshots of user performance metrics';
COMMENT ON TABLE learning_events IS 'Detailed event tracking for learning analytics';
COMMENT ON TABLE performance_reports IS 'Generated performance reports for users';
COMMENT ON TABLE subject_mastery_history IS 'Historical tracking of subject mastery levels';
COMMENT ON TABLE study_time_logs IS 'Detailed time tracking for study activities';
COMMENT ON TABLE learning_patterns IS 'Detected learning patterns and behaviors';
COMMENT ON TABLE ab_test_experiments IS 'A/B testing experiments configuration';
COMMENT ON TABLE user_experiment_assignments IS 'User assignments to experiment variants';
COMMENT ON TABLE experiment_events IS 'Events tracked for A/B test analysis';
COMMENT ON TABLE system_metrics IS 'System-wide metrics and health indicators';

COMMENT ON COLUMN performance_snapshots.metrics IS 'JSON object containing various performance metrics';
COMMENT ON COLUMN learning_patterns.pattern_data IS 'Detected pattern details and characteristics';
COMMENT ON COLUMN ab_test_experiments.variants IS 'List of experiment variants and their configurations';
