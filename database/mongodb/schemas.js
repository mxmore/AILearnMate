/**
 * MongoDB Schema Definitions for AILearnMate
 * 
 * MongoDB is used for flexible document storage, logs, and high-write analytics.
 * These schemas are defined using Mongoose-style syntax for documentation purposes.
 */

// User Activity Logs - High-write volume data
const userActivityLogSchema = {
  collection: 'user_activity_logs',
  schema: {
    userId: { type: 'UUID', required: true, index: true },
    sessionId: { type: 'String', index: true },
    activityType: { 
      type: 'String', 
      required: true,
      enum: ['page_view', 'click', 'search', 'question_view', 'material_view', 'answer_submit', 'chat_message'],
      index: true
    },
    activityData: { type: 'Object' },
    url: { type: 'String' },
    duration: { type: 'Number' }, // milliseconds
    deviceInfo: {
      deviceType: { type: 'String' }, // 'mobile', 'tablet', 'desktop'
      os: { type: 'String' },
      browser: { type: 'String' },
      screenResolution: { type: 'String' }
    },
    location: {
      ip: { type: 'String' },
      country: { type: 'String' },
      city: { type: 'String' }
    },
    timestamp: { type: 'Date', required: true, index: true },
    metadata: { type: 'Object' }
  },
  indexes: [
    { userId: 1, timestamp: -1 },
    { activityType: 1, timestamp: -1 },
    { sessionId: 1 },
    { timestamp: 1 }, // TTL index - expire after 90 days
  ],
  ttl: { field: 'timestamp', expireAfterSeconds: 7776000 } // 90 days
};

// Question Metadata and Variations
const questionMetadataSchema = {
  collection: 'question_metadata',
  schema: {
    questionId: { type: 'UUID', required: true, unique: true },
    variations: [{
      variationId: { type: 'UUID' },
      language: { type: 'String' },
      difficulty: { type: 'String' },
      context: { type: 'String' },
      questionText: { type: 'String' },
      options: { type: 'Object' },
      usage: {
        views: { type: 'Number', default: 0 },
        attempts: { type: 'Number', default: 0 },
        avgTimeSpent: { type: 'Number' }
      }
    }],
    analytics: {
      totalAttempts: { type: 'Number', default: 0 },
      correctAttempts: { type: 'Number', default: 0 },
      avgTimeSpent: { type: 'Number' },
      difficultyRating: { type: 'Number' }, // user-perceived difficulty
      confusionMetrics: {
        commonWrongAnswers: [{ 
          answer: { type: 'String' },
          count: { type: 'Number' }
        }],
        hintRequestRate: { type: 'Number' }
      }
    },
    similarQuestions: [{
      questionId: { type: 'UUID' },
      similarityScore: { type: 'Number' }
    }],
    aiGenerationData: {
      sourcePrompt: { type: 'String' },
      model: { type: 'String' },
      generatedAt: { type: 'Date' },
      qualityScores: {
        clarity: { type: 'Number' },
        relevance: { type: 'Number' },
        difficulty: { type: 'Number' }
      }
    },
    lastUpdated: { type: 'Date', default: Date.now }
  },
  indexes: [
    { questionId: 1 },
    { 'analytics.totalAttempts': -1 },
    { 'analytics.difficultyRating': 1 },
    { lastUpdated: -1 }
  ]
};

// AI Chat Conversations - Full context storage
const aiChatConversationSchema = {
  collection: 'ai_chat_conversations',
  schema: {
    conversationId: { type: 'UUID', required: true, unique: true },
    userId: { type: 'UUID', required: true, index: true },
    title: { type: 'String' },
    contextType: { 
      type: 'String',
      enum: ['general', 'question_help', 'study_planning', 'material_discussion', 'problem_solving']
    },
    contextReference: {
      type: { type: 'String' }, // 'question', 'material', 'knowledge_point'
      id: { type: 'UUID' }
    },
    messages: [{
      messageId: { type: 'UUID' },
      role: { 
        type: 'String',
        enum: ['user', 'assistant', 'system'],
        required: true
      },
      content: { type: 'String', required: true },
      contentType: { 
        type: 'String',
        default: 'text',
        enum: ['text', 'code', 'image', 'mixed']
      },
      tokens: { type: 'Number' },
      model: { type: 'String' },
      functionCalls: [{ type: 'Object' }],
      timestamp: { type: 'Date', default: Date.now }
    }],
    metadata: {
      messageCount: { type: 'Number', default: 0 },
      totalTokens: { type: 'Number', default: 0 },
      avgResponseTime: { type: 'Number' }, // milliseconds
      userSatisfaction: { type: 'Number' }, // 1-5 rating
      tags: [{ type: 'String' }]
    },
    isArchived: { type: 'Boolean', default: false },
    createdAt: { type: 'Date', default: Date.now, index: true },
    updatedAt: { type: 'Date', default: Date.now }
  },
  indexes: [
    { conversationId: 1 },
    { userId: 1, createdAt: -1 },
    { contextType: 1 },
    { 'contextReference.type': 1, 'contextReference.id': 1 },
    { isArchived: 1 }
  ]
};

// Learning Journey - User learning path tracking
const learningJourneySchema = {
  collection: 'learning_journeys',
  schema: {
    userId: { type: 'UUID', required: true, unique: true },
    journeyStages: [{
      stageId: { type: 'UUID' },
      stageName: { type: 'String' },
      startDate: { type: 'Date' },
      endDate: { type: 'Date' },
      goals: [{ type: 'String' }],
      achievements: [{
        achievementId: { type: 'UUID' },
        name: { type: 'String' },
        earnedAt: { type: 'Date' }
      }],
      metrics: {
        studyTime: { type: 'Number' },
        questionsCompleted: { type: 'Number' },
        masteredTopics: { type: 'Number' }
      }
    }],
    milestones: [{
      milestoneId: { type: 'UUID' },
      title: { type: 'String' },
      description: { type: 'String' },
      achievedAt: { type: 'Date' },
      subjectId: { type: 'UUID' },
      significance: { type: 'String', enum: ['minor', 'major', 'critical'] }
    }],
    learningStyle: {
      primaryStyle: { type: 'String' }, // 'visual', 'auditory', 'kinesthetic', 'reading'
      preferences: {
        videosOverText: { type: 'Number' }, // -1 to 1
        examplesOverTheory: { type: 'Number' },
        practiceOverReading: { type: 'Number' }
      },
      confidenceScore: { type: 'Number' } // 0-100
    },
    strengthsAndWeaknesses: {
      strengths: [{
        area: { type: 'String' },
        score: { type: 'Number' },
        evidence: [{ type: 'String' }]
      }],
      weaknesses: [{
        area: { type: 'String' },
        score: { type: 'Number' },
        recommendedActions: [{ type: 'String' }]
      }]
    },
    lastUpdated: { type: 'Date', default: Date.now }
  },
  indexes: [
    { userId: 1 },
    { lastUpdated: -1 }
  ]
};

// Real-time Study Session State
const activeStudySessionSchema = {
  collection: 'active_study_sessions',
  schema: {
    sessionId: { type: 'UUID', required: true, unique: true },
    userId: { type: 'UUID', required: true, index: true },
    sessionType: { 
      type: 'String',
      enum: ['practice', 'exam', 'review', 'adaptive'],
      required: true
    },
    currentState: {
      currentQuestionIndex: { type: 'Number', default: 0 },
      currentQuestionId: { type: 'UUID' },
      startedAt: { type: 'Date' },
      lastActivityAt: { type: 'Date' },
      isPaused: { type: 'Boolean', default: false }
    },
    questions: [{
      questionId: { type: 'UUID' },
      displayOrder: { type: 'Number' },
      isCompleted: { type: 'Boolean', default: false },
      timeSpent: { type: 'Number' }, // seconds
      attempts: [{ type: 'Object' }]
    }],
    performance: {
      questionsAnswered: { type: 'Number', default: 0 },
      correctAnswers: { type: 'Number', default: 0 },
      currentStreak: { type: 'Number', default: 0 },
      longestStreak: { type: 'Number', default: 0 }
    },
    configuration: {
      subjectId: { type: 'UUID' },
      difficulty: { type: 'String' },
      knowledgePoints: [{ type: 'UUID' }],
      timeLimit: { type: 'Number' },
      questionCount: { type: 'Number' }
    },
    expiresAt: { type: 'Date', index: true }, // Session cleanup
    createdAt: { type: 'Date', default: Date.now }
  },
  indexes: [
    { sessionId: 1 },
    { userId: 1, createdAt: -1 },
    { expiresAt: 1 }, // TTL index
    { 'currentState.lastActivityAt': -1 }
  ],
  ttl: { field: 'expiresAt', expireAfterSeconds: 0 }
};

// Document Processing Logs
const documentProcessingLogSchema = {
  collection: 'document_processing_logs',
  schema: {
    processingId: { type: 'UUID', required: true, unique: true },
    userId: { type: 'UUID', required: true, index: true },
    documentInfo: {
      fileName: { type: 'String' },
      fileUrl: { type: 'String' },
      fileType: { type: 'String' },
      fileSize: { type: 'Number' }
    },
    processingSteps: [{
      stepName: { type: 'String' },
      status: { type: 'String', enum: ['pending', 'running', 'completed', 'failed'] },
      startTime: { type: 'Date' },
      endTime: { type: 'Date' },
      duration: { type: 'Number' }, // milliseconds
      result: { type: 'Object' },
      error: { type: 'String' },
      metadata: { type: 'Object' }
    }],
    extractedData: {
      questionsExtracted: { type: 'Number', default: 0 },
      knowledgePointsIdentified: [{ type: 'String' }],
      keyTerms: [{ type: 'String' }],
      summary: { type: 'String' }
    },
    aiModelsUsed: [{
      modelName: { type: 'String' },
      taskType: { type: 'String' },
      tokensUsed: { type: 'Number' },
      cost: { type: 'Number' }
    }],
    overallStatus: { 
      type: 'String',
      enum: ['pending', 'processing', 'completed', 'failed'],
      default: 'pending',
      index: true
    },
    totalCost: { type: 'Number' },
    createdAt: { type: 'Date', default: Date.now, index: true },
    completedAt: { type: 'Date' }
  },
  indexes: [
    { processingId: 1 },
    { userId: 1, createdAt: -1 },
    { overallStatus: 1 },
    { createdAt: -1 }
  ]
};

// Notification Queue
const notificationQueueSchema = {
  collection: 'notification_queue',
  schema: {
    notificationId: { type: 'UUID', required: true, unique: true },
    userId: { type: 'UUID', required: true, index: true },
    notificationType: { 
      type: 'String',
      enum: ['reminder', 'achievement', 'streak', 'recommendation', 'system'],
      required: true
    },
    priority: { type: 'Number', default: 0, index: true }, // Higher = more urgent
    title: { type: 'String', required: true },
    body: { type: 'String', required: true },
    actionUrl: { type: 'String' },
    actionData: { type: 'Object' },
    channels: [{ 
      type: 'String',
      enum: ['in_app', 'email', 'push', 'sms']
    }],
    status: { 
      type: 'String',
      enum: ['pending', 'sent', 'failed', 'cancelled'],
      default: 'pending',
      index: true
    },
    scheduledFor: { type: 'Date', index: true },
    sentAt: { type: 'Date' },
    readAt: { type: 'Date' },
    deliveryAttempts: { type: 'Number', default: 0 },
    lastError: { type: 'String' },
    metadata: { type: 'Object' },
    expiresAt: { type: 'Date', index: true },
    createdAt: { type: 'Date', default: Date.now }
  },
  indexes: [
    { notificationId: 1 },
    { userId: 1, status: 1, createdAt: -1 },
    { status: 1, scheduledFor: 1 },
    { priority: -1, createdAt: 1 },
    { expiresAt: 1 } // TTL index
  ],
  ttl: { field: 'expiresAt', expireAfterSeconds: 0 }
};

// Cache for expensive computations
const computationCacheSchema = {
  collection: 'computation_cache',
  schema: {
    cacheKey: { type: 'String', required: true, unique: true },
    cacheType: { 
      type: 'String',
      enum: ['recommendation', 'analytics', 'search', 'similarity'],
      required: true,
      index: true
    },
    userId: { type: 'UUID', index: true },
    parameters: { type: 'Object' },
    result: { type: 'Object', required: true },
    computationTime: { type: 'Number' }, // milliseconds
    hitCount: { type: 'Number', default: 0 },
    lastAccessedAt: { type: 'Date', default: Date.now },
    expiresAt: { type: 'Date', required: true, index: true },
    createdAt: { type: 'Date', default: Date.now }
  },
  indexes: [
    { cacheKey: 1 },
    { cacheType: 1, userId: 1 },
    { expiresAt: 1 }, // TTL index
    { lastAccessedAt: 1 }
  ],
  ttl: { field: 'expiresAt', expireAfterSeconds: 0 }
};

module.exports = {
  userActivityLogSchema,
  questionMetadataSchema,
  aiChatConversationSchema,
  learningJourneySchema,
  activeStudySessionSchema,
  documentProcessingLogSchema,
  notificationQueueSchema,
  computationCacheSchema
};
