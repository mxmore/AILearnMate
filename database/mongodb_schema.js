// AILearnMate MongoDB 数据库架构
// 版本: 1.0
// 数据库: MongoDB 6+

// ============================================================
// 数据库配置
// ============================================================

// 使用 ailearn数据库
db = db.getSiblingDB('ailearnmate');

// ============================================================
// 集合创建和验证规则
// ============================================================

// 题目集合 (questions)
db.createCollection("questions", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["type", "subject", "difficulty", "content", "answer", "status"],
      properties: {
        type: {
          enum: ["single_choice", "multiple_choice", "true_false", "fill_blank", "short_answer", "essay"],
          description: "题目类型"
        },
        subject: {
          bsonType: "string",
          description: "学科"
        },
        difficulty: {
          bsonType: "int",
          minimum: 1,
          maximum: 5,
          description: "难度等级 1-5"
        },
        content: {
          bsonType: "object",
          required: ["question"],
          properties: {
            question: {
              bsonType: "string",
              description: "题目内容"
            },
            options: {
              bsonType: "array",
              items: {
                bsonType: "string"
              },
              description: "选择题选项"
            },
            images: {
              bsonType: "array",
              items: {
                bsonType: "string"
              },
              description: "题目图片 URLs"
            }
          }
        },
        answer: {
          bsonType: "object",
          required: ["correct"],
          properties: {
            correct: {
              bsonType: "string",
              description: "正确答案"
            },
            explanation: {
              bsonType: "string",
              description: "答案解析"
            },
            explanation_images: {
              bsonType: "array",
              items: {
                bsonType: "string"
              },
              description: "解析图片 URLs"
            }
          }
        },
        knowledge_points: {
          bsonType: "array",
          items: {
            bsonType: "string"
          },
          description: "关联的知识点 UUIDs"
        },
        tags: {
          bsonType: "array",
          items: {
            bsonType: "string"
          },
          description: "标签"
        },
        source: {
          bsonType: "string",
          description: "题目来源"
        },
        quality_score: {
          bsonType: "double",
          minimum: 0,
          maximum: 1,
          description: "AI 评估的质量分数"
        },
        usage_count: {
          bsonType: "int",
          minimum: 0,
          description: "被答题次数"
        },
        correct_rate: {
          bsonType: "double",
          minimum: 0,
          maximum: 1,
          description: "正确率"
        },
        created_by: {
          bsonType: "string",
          description: "创建者 UUID"
        },
        status: {
          enum: ["draft", "published", "archived"],
          description: "题目状态"
        }
      }
    }
  }
});

// 创建索引
db.questions.createIndex({ "subject": 1, "difficulty": 1 });
db.questions.createIndex({ "type": 1 });
db.questions.createIndex({ "status": 1 });
db.questions.createIndex({ "knowledge_points": 1 });
db.questions.createIndex({ "tags": 1 });
db.questions.createIndex({ "quality_score": -1 });
db.questions.createIndex({ "created_at": -1 });
db.questions.createIndex({ "usage_count": -1 });

// 复合索引用于高效查询
db.questions.createIndex({ "subject": 1, "difficulty": 1, "status": 1 });
db.questions.createIndex({ "knowledge_points": 1, "difficulty": 1, "status": 1 });

// ============================================================
// 学习资料集合 (materials)
// ============================================================

db.createCollection("materials", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["user_id", "title", "type", "file_url", "processing_status"],
      properties: {
        user_id: {
          bsonType: "string",
          description: "用户 UUID"
        },
        title: {
          bsonType: "string",
          description: "资料标题"
        },
        description: {
          bsonType: "string",
          description: "资料描述"
        },
        type: {
          enum: ["pdf", "image", "word", "ppt", "txt"],
          description: "文件类型"
        },
        file_url: {
          bsonType: "string",
          description: "文件存储路径"
        },
        file_size: {
          bsonType: "long",
          description: "文件大小（字节）"
        },
        page_count: {
          bsonType: "int",
          description: "页数"
        },
        processing_status: {
          enum: ["pending", "processing", "completed", "failed"],
          description: "处理状态"
        },
        extracted_content: {
          bsonType: "array",
          items: {
            bsonType: "object",
            properties: {
              page: {
                bsonType: "int"
              },
              text: {
                bsonType: "string"
              },
              images: {
                bsonType: "array",
                items: {
                  bsonType: "string"
                }
              },
              knowledge_points: {
                bsonType: "array",
                items: {
                  bsonType: "string"
                }
              },
              generated_questions: {
                bsonType: "array",
                items: {
                  bsonType: "objectId"
                }
              }
            }
          },
          description: "提取的内容"
        },
        knowledge_points: {
          bsonType: "array",
          items: {
            bsonType: "string"
          },
          description: "关联的知识点 UUIDs"
        },
        tags: {
          bsonType: "array",
          items: {
            bsonType: "string"
          },
          description: "标签"
        }
      }
    }
  }
});

// 创建索引
db.materials.createIndex({ "user_id": 1, "created_at": -1 });
db.materials.createIndex({ "processing_status": 1 });
db.materials.createIndex({ "type": 1 });
db.materials.createIndex({ "knowledge_points": 1 });
db.materials.createIndex({ "tags": 1 });

// ============================================================
// 学习会话集合 (study_sessions)
// ============================================================

db.createCollection("study_sessions", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["user_id", "session_type", "question_ids", "started_at"],
      properties: {
        user_id: {
          bsonType: "string",
          description: "用户 UUID"
        },
        session_type: {
          enum: ["practice", "review", "mock_exam", "daily_challenge"],
          description: "会话类型"
        },
        subject: {
          bsonType: "string",
          description: "学科"
        },
        question_ids: {
          bsonType: "array",
          items: {
            bsonType: "objectId"
          },
          description: "题目 IDs"
        },
        started_at: {
          bsonType: "date",
          description: "开始时间"
        },
        ended_at: {
          bsonType: "date",
          description: "结束时间"
        },
        total_questions: {
          bsonType: "int",
          minimum: 0,
          description: "题目总数"
        },
        completed_questions: {
          bsonType: "int",
          minimum: 0,
          description: "已完成题目数"
        },
        correct_count: {
          bsonType: "int",
          minimum: 0,
          description: "正确题数"
        },
        time_spent: {
          bsonType: "int",
          minimum: 0,
          description: "总用时（秒）"
        },
        avg_time_per_question: {
          bsonType: "double",
          description: "平均每题用时"
        },
        accuracy: {
          bsonType: "double",
          minimum: 0,
          maximum: 1,
          description: "正确率"
        }
      }
    }
  }
});

// 创建索引
db.study_sessions.createIndex({ "user_id": 1, "started_at": -1 });
db.study_sessions.createIndex({ "session_type": 1 });
db.study_sessions.createIndex({ "ended_at": -1 });

// ============================================================
// AI 提示词模板集合 (prompt_templates)
// ============================================================

db.createCollection("prompt_templates", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["name", "type", "template", "version"],
      properties: {
        name: {
          bsonType: "string",
          description: "模板名称"
        },
        type: {
          enum: ["extract_knowledge", "generate_question", "quality_assessment", "difficulty_assessment", "answer_evaluation"],
          description: "模板类型"
        },
        template: {
          bsonType: "string",
          description: "提示词模板"
        },
        variables: {
          bsonType: "array",
          items: {
            bsonType: "string"
          },
          description: "模板变量"
        },
        version: {
          bsonType: "string",
          description: "版本号"
        },
        is_active: {
          bsonType: "bool",
          description: "是否启用"
        },
        model: {
          bsonType: "string",
          description: "推荐使用的模型"
        },
        temperature: {
          bsonType: "double",
          minimum: 0,
          maximum: 2,
          description: "温度参数"
        },
        max_tokens: {
          bsonType: "int",
          description: "最大 token 数"
        }
      }
    }
  }
});

// 创建索引
db.prompt_templates.createIndex({ "type": 1, "is_active": 1 });
db.prompt_templates.createIndex({ "name": 1, "version": 1 }, { unique: true });

// ============================================================
// 用户反馈集合 (user_feedback)
// ============================================================

db.createCollection("user_feedback", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["user_id", "type", "content"],
      properties: {
        user_id: {
          bsonType: "string",
          description: "用户 UUID"
        },
        type: {
          enum: ["question_error", "question_quality", "feature_request", "bug_report", "general"],
          description: "反馈类型"
        },
        related_question_id: {
          bsonType: "objectId",
          description: "相关题目 ID"
        },
        content: {
          bsonType: "string",
          description: "反馈内容"
        },
        rating: {
          bsonType: "int",
          minimum: 1,
          maximum: 5,
          description: "评分"
        },
        status: {
          enum: ["pending", "in_progress", "resolved", "closed"],
          description: "处理状态"
        },
        admin_response: {
          bsonType: "string",
          description: "管理员回复"
        }
      }
    }
  }
});

// 创建索引
db.user_feedback.createIndex({ "user_id": 1, "created_at": -1 });
db.user_feedback.createIndex({ "type": 1, "status": 1 });
db.user_feedback.createIndex({ "related_question_id": 1 });

// ============================================================
// 错题本集合 (wrong_questions)
// ============================================================

db.createCollection("wrong_questions", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["user_id", "question_id"],
      properties: {
        user_id: {
          bsonType: "string",
          description: "用户 UUID"
        },
        question_id: {
          bsonType: "objectId",
          description: "题目 ID"
        },
        wrong_count: {
          bsonType: "int",
          minimum: 0,
          description: "错误次数"
        },
        first_wrong_at: {
          bsonType: "date",
          description: "首次答错时间"
        },
        last_wrong_at: {
          bsonType: "date",
          description: "最后答错时间"
        },
        is_mastered: {
          bsonType: "bool",
          description: "是否已掌握"
        },
        mastered_at: {
          bsonType: "date",
          description: "掌握时间"
        },
        notes: {
          bsonType: "string",
          description: "用户笔记"
        }
      }
    }
  }
});

// 创建索引
db.wrong_questions.createIndex({ "user_id": 1, "is_mastered": 1 });
db.wrong_questions.createIndex({ "question_id": 1 });
db.wrong_questions.createIndex({ "user_id": 1, "last_wrong_at": -1 });

// 复合唯一索引
db.wrong_questions.createIndex({ "user_id": 1, "question_id": 1 }, { unique: true });

// ============================================================
// 系统事件日志集合 (system_events)
// ============================================================

db.createCollection("system_events", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["event_type", "timestamp"],
      properties: {
        event_type: {
          bsonType: "string",
          description: "事件类型"
        },
        severity: {
          enum: ["info", "warning", "error", "critical"],
          description: "严重程度"
        },
        service: {
          bsonType: "string",
          description: "服务名称"
        },
        message: {
          bsonType: "string",
          description: "事件消息"
        },
        metadata: {
          bsonType: "object",
          description: "附加元数据"
        },
        timestamp: {
          bsonType: "date",
          description: "事件时间"
        },
        user_id: {
          bsonType: "string",
          description: "关联用户 UUID"
        }
      }
    }
  }
});

// 创建索引
db.system_events.createIndex({ "event_type": 1, "timestamp": -1 });
db.system_events.createIndex({ "severity": 1, "timestamp": -1 });
db.system_events.createIndex({ "timestamp": -1 });

// TTL 索引：30天后自动删除日志
db.system_events.createIndex({ "timestamp": 1 }, { expireAfterSeconds: 2592000 });

print("MongoDB schema created successfully!");
print("Collections created:");
print("  - questions");
print("  - materials");
print("  - study_sessions");
print("  - prompt_templates");
print("  - user_feedback");
print("  - wrong_questions");
print("  - system_events");
