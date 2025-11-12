-- AI Agent Tasks and Processing

-- AI agent tasks
CREATE TABLE ai_agent_tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    task_type agent_task_type NOT NULL,
    input_data JSONB NOT NULL,
    output_data JSONB,
    status processing_status DEFAULT 'pending',
    priority INTEGER DEFAULT 0,
    model_name VARCHAR(100),
    model_version VARCHAR(50),
    prompt_template TEXT,
    tokens_used INTEGER,
    cost_usd DECIMAL(10,6),
    execution_time_ms INTEGER,
    error_message TEXT,
    retry_count INTEGER DEFAULT 0,
    max_retries INTEGER DEFAULT 3,
    parent_task_id UUID REFERENCES ai_agent_tasks(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- AI prompt templates
CREATE TABLE ai_prompt_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(200) UNIQUE NOT NULL,
    task_type agent_task_type NOT NULL,
    description TEXT,
    template_text TEXT NOT NULL,
    system_prompt TEXT,
    variables JSONB DEFAULT '[]'::jsonb, -- list of variable names
    model_config JSONB DEFAULT '{}'::jsonb, -- temperature, max_tokens, etc.
    version INTEGER DEFAULT 1,
    is_active BOOLEAN DEFAULT true,
    performance_score DECIMAL(5,2), -- tracked performance
    usage_count INTEGER DEFAULT 0,
    success_rate DECIMAL(5,4),
    created_by UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- AI agent conversations
CREATE TABLE ai_conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(500),
    context_type VARCHAR(50), -- 'general', 'question_help', 'study_planning', 'material_discussion'
    context_id UUID, -- reference to question, material, etc.
    message_count INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- AI conversation messages
CREATE TABLE ai_conversation_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID NOT NULL REFERENCES ai_conversations(id) ON DELETE CASCADE,
    role VARCHAR(20) NOT NULL, -- 'user', 'assistant', 'system'
    content TEXT NOT NULL,
    content_type VARCHAR(50) DEFAULT 'text', -- 'text', 'code', 'image_url'
    model_name VARCHAR(100),
    tokens_used INTEGER,
    embedding vector(1536),
    is_flagged BOOLEAN DEFAULT false,
    flag_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Document processing queue
CREATE TABLE document_processing_queue (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    file_url TEXT NOT NULL,
    file_name VARCHAR(500),
    file_type VARCHAR(50),
    file_size INTEGER,
    processing_type VARCHAR(50) NOT NULL, -- 'extract_questions', 'extract_knowledge', 'summarize', 'index'
    status processing_status DEFAULT 'pending',
    priority INTEGER DEFAULT 0,
    options JSONB DEFAULT '{}'::jsonb,
    result_data JSONB,
    extracted_items_count INTEGER DEFAULT 0,
    error_message TEXT,
    retry_count INTEGER DEFAULT 0,
    max_retries INTEGER DEFAULT 3,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- AI feedback and ratings
CREATE TABLE ai_feedback (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    task_id UUID REFERENCES ai_agent_tasks(id) ON DELETE CASCADE,
    message_id UUID REFERENCES ai_conversation_messages(id) ON DELETE CASCADE,
    feedback_type VARCHAR(50) NOT NULL, -- 'thumbs_up', 'thumbs_down', 'report'
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    issue_category VARCHAR(50), -- 'incorrect', 'unhelpful', 'inappropriate', 'other'
    is_reviewed BOOLEAN DEFAULT false,
    reviewed_by UUID REFERENCES users(id) ON DELETE SET NULL,
    reviewed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- AI model usage tracking
CREATE TABLE ai_model_usage (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    model_name VARCHAR(100) NOT NULL,
    task_type agent_task_type,
    tokens_prompt INTEGER NOT NULL,
    tokens_completion INTEGER NOT NULL,
    tokens_total INTEGER NOT NULL,
    cost_usd DECIMAL(10,6),
    execution_time_ms INTEGER,
    success BOOLEAN DEFAULT true,
    error_type VARCHAR(100),
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    date DATE GENERATED ALWAYS AS (timestamp::DATE) STORED
);

-- Indexes
CREATE INDEX idx_ai_agent_tasks_user_id ON ai_agent_tasks(user_id);
CREATE INDEX idx_ai_agent_tasks_type ON ai_agent_tasks(task_type);
CREATE INDEX idx_ai_agent_tasks_status ON ai_agent_tasks(status);
CREATE INDEX idx_ai_agent_tasks_priority ON ai_agent_tasks(priority);
CREATE INDEX idx_ai_agent_tasks_parent_id ON ai_agent_tasks(parent_task_id);
CREATE INDEX idx_ai_agent_tasks_created_at ON ai_agent_tasks(created_at);
CREATE INDEX idx_ai_prompt_templates_name ON ai_prompt_templates(name);
CREATE INDEX idx_ai_prompt_templates_type ON ai_prompt_templates(task_type);
CREATE INDEX idx_ai_prompt_templates_active ON ai_prompt_templates(is_active);
CREATE INDEX idx_ai_conversations_user_id ON ai_conversations(user_id);
CREATE INDEX idx_ai_conversations_context ON ai_conversations(context_type, context_id);
CREATE INDEX idx_ai_conversations_active ON ai_conversations(is_active);
CREATE INDEX idx_ai_conversation_messages_conversation_id ON ai_conversation_messages(conversation_id);
CREATE INDEX idx_ai_conversation_messages_role ON ai_conversation_messages(role);
CREATE INDEX idx_ai_conversation_messages_created_at ON ai_conversation_messages(created_at);
CREATE INDEX idx_document_processing_queue_user_id ON document_processing_queue(user_id);
CREATE INDEX idx_document_processing_queue_status ON document_processing_queue(status);
CREATE INDEX idx_document_processing_queue_type ON document_processing_queue(processing_type);
CREATE INDEX idx_document_processing_queue_priority ON document_processing_queue(priority);
CREATE INDEX idx_ai_feedback_user_id ON ai_feedback(user_id);
CREATE INDEX idx_ai_feedback_task_id ON ai_feedback(task_id);
CREATE INDEX idx_ai_feedback_message_id ON ai_feedback(message_id);
CREATE INDEX idx_ai_feedback_type ON ai_feedback(feedback_type);
CREATE INDEX idx_ai_model_usage_user_id ON ai_model_usage(user_id);
CREATE INDEX idx_ai_model_usage_model ON ai_model_usage(model_name);
CREATE INDEX idx_ai_model_usage_date ON ai_model_usage(date);
CREATE INDEX idx_ai_model_usage_timestamp ON ai_model_usage(timestamp);

-- Vector similarity search index
CREATE INDEX idx_ai_conversation_messages_embedding ON ai_conversation_messages USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);

-- GIN indexes for JSONB
CREATE INDEX idx_ai_agent_tasks_input_gin ON ai_agent_tasks USING gin(input_data);
CREATE INDEX idx_ai_agent_tasks_output_gin ON ai_agent_tasks USING gin(output_data);
CREATE INDEX idx_ai_prompt_templates_variables_gin ON ai_prompt_templates USING gin(variables);
CREATE INDEX idx_ai_prompt_templates_config_gin ON ai_prompt_templates USING gin(model_config);
CREATE INDEX idx_ai_conversations_metadata_gin ON ai_conversations USING gin(metadata);
CREATE INDEX idx_document_processing_queue_options_gin ON document_processing_queue USING gin(options);
CREATE INDEX idx_document_processing_queue_result_gin ON document_processing_queue USING gin(result_data);

-- Comments
COMMENT ON TABLE ai_agent_tasks IS 'AI agent task execution tracking';
COMMENT ON TABLE ai_prompt_templates IS 'Reusable prompt templates for AI tasks';
COMMENT ON TABLE ai_conversations IS 'AI chatbot conversations with users';
COMMENT ON TABLE ai_conversation_messages IS 'Individual messages in AI conversations';
COMMENT ON TABLE document_processing_queue IS 'Queue for document processing tasks';
COMMENT ON TABLE ai_feedback IS 'User feedback on AI responses';
COMMENT ON TABLE ai_model_usage IS 'AI model usage tracking for cost and analytics';

COMMENT ON COLUMN ai_agent_tasks.input_data IS 'Task input parameters as JSON';
COMMENT ON COLUMN ai_agent_tasks.output_data IS 'Task results as JSON';
COMMENT ON COLUMN ai_prompt_templates.variables IS 'List of template variable names';
COMMENT ON COLUMN ai_prompt_templates.performance_score IS 'Tracked performance score (0-100)';
COMMENT ON COLUMN document_processing_queue.processing_type IS 'Type of document processing to perform';
