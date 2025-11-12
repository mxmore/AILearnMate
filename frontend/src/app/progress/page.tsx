'use client'

import { useState, useEffect } from 'react'
import { userAPI, studyAPI, knowledgeAPI } from '@/lib/api'
import { TrendingUp, Target, Clock, Award, Calendar, BookOpen, Brain } from 'lucide-react'

interface UserStats {
  total_questions_answered: number
  correct_answers: number
  accuracy_rate: number
  total_study_hours: number
  study_days: number
  current_streak: number
  max_streak: number
  active_study_plans: number
}

interface KnowledgeMastery {
  knowledge_point: {
    id: string
    name: string
    subject: string
  }
  mastery_level: number
  practice_count: number
  correct_count: number
}

export default function ProgressPage() {
  const [stats, setStats] = useState<UserStats | null>(null)
  const [masteryData, setMasteryData] = useState<KnowledgeMastery[]>([])
  const [weakPoints, setWeakPoints] = useState<any[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadData()
  }, [])

  const loadData = async () => {
    try {
      setLoading(true)
      const [statsRes, masteryRes, weakRes] = await Promise.all([
        userAPI.getStats(),
        knowledgeAPI.getMastery(),
        knowledgeAPI.getWeakPoints()
      ])
      
      setStats(statsRes.data)
      setMasteryData(masteryRes.data)
      setWeakPoints(weakRes.data.weak_points || [])
    } catch (error) {
      console.error('Failed to load progress data:', error)
      // Mock data for demo
      setStats({
        total_questions_answered: 245,
        correct_answers: 198,
        accuracy_rate: 80.82,
        total_study_hours: 45.5,
        study_days: 28,
        current_streak: 7,
        max_streak: 15,
        active_study_plans: 2
      })
      setMasteryData([
        {
          knowledge_point: { id: '1', name: '一元一次方程', subject: '数学' },
          mastery_level: 0.85,
          practice_count: 25,
          correct_count: 21
        },
        {
          knowledge_point: { id: '2', name: '三角形', subject: '数学' },
          mastery_level: 0.72,
          practice_count: 18,
          correct_count: 13
        },
        {
          knowledge_point: { id: '3', name: '时态', subject: '英语' },
          mastery_level: 0.45,
          practice_count: 20,
          correct_count: 9
        }
      ])
      setWeakPoints([
        { name: '英语时态', mastery_level: 0.45, subject: '英语' },
        { name: '物理力学', mastery_level: 0.52, subject: '物理' }
      ])
    } finally {
      setLoading(false)
    }
  }

  const getMasteryColor = (level: number) => {
    if (level >= 0.8) return 'bg-green-500'
    if (level >= 0.6) return 'bg-blue-500'
    if (level >= 0.4) return 'bg-yellow-500'
    return 'bg-red-500'
  }

  const getMasteryLabel = (level: number) => {
    if (level >= 0.8) return '优秀'
    if (level >= 0.6) return '良好'
    if (level >= 0.4) return '及格'
    return '需提高'
  }

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <p className="text-gray-600">加载数据中...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm border-b">
        <div className="container mx-auto px-4 py-6">
          <h1 className="text-3xl font-bold text-gray-900">学习进度</h1>
          <p className="text-gray-600 mt-2">查看你的学习统计和知识点掌握情况</p>
        </div>
      </header>

      <div className="container mx-auto px-4 py-8 max-w-7xl">
        {/* Stats Overview */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <StatCard
            icon={<BookOpen className="w-8 h-8 text-blue-600" />}
            label="已答题目"
            value={stats?.total_questions_answered || 0}
            unit="题"
            color="blue"
          />
          <StatCard
            icon={<Target className="w-8 h-8 text-green-600" />}
            label="正确率"
            value={stats?.accuracy_rate || 0}
            unit="%"
            color="green"
          />
          <StatCard
            icon={<Clock className="w-8 h-8 text-purple-600" />}
            label="学习时长"
            value={stats?.total_study_hours || 0}
            unit="小时"
            color="purple"
          />
          <StatCard
            icon={<Award className="w-8 h-8 text-orange-600" />}
            label="连续打卡"
            value={stats?.current_streak || 0}
            unit="天"
            color="orange"
          />
        </div>

        {/* Progress Chart */}
        <div className="bg-white rounded-xl shadow-sm p-6 mb-8">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">学习趋势</h2>
          <div className="h-64 flex items-end justify-around gap-2">
            {[65, 72, 68, 80, 85, 78, 90].map((value, idx) => (
              <div key={idx} className="flex-1 flex flex-col items-center">
                <div
                  className="w-full bg-blue-500 rounded-t transition-all hover:bg-blue-600"
                  style={{ height: `${value}%` }}
                ></div>
                <span className="text-xs text-gray-600 mt-2">
                  {['周一', '周二', '周三', '周四', '周五', '周六', '周日'][idx]}
                </span>
              </div>
            ))}
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          {/* Knowledge Mastery */}
          <div className="bg-white rounded-xl shadow-sm p-6">
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-xl font-semibold text-gray-900">知识点掌握度</h2>
              <Brain className="w-6 h-6 text-gray-400" />
            </div>
            
            {masteryData.length === 0 ? (
              <p className="text-center text-gray-500 py-8">暂无数据</p>
            ) : (
              <div className="space-y-4">
                {masteryData.map((item, idx) => (
                  <div key={idx} className="border-b border-gray-100 pb-4 last:border-0">
                    <div className="flex items-center justify-between mb-2">
                      <div>
                        <h3 className="font-medium text-gray-900">
                          {item.knowledge_point.name}
                        </h3>
                        <p className="text-sm text-gray-500">
                          {item.knowledge_point.subject} · 练习 {item.practice_count} 次
                        </p>
                      </div>
                      <span className={`px-3 py-1 rounded-full text-sm font-medium ${
                        item.mastery_level >= 0.8 ? 'bg-green-100 text-green-800' :
                        item.mastery_level >= 0.6 ? 'bg-blue-100 text-blue-800' :
                        item.mastery_level >= 0.4 ? 'bg-yellow-100 text-yellow-800' :
                        'bg-red-100 text-red-800'
                      }`}>
                        {getMasteryLabel(item.mastery_level)}
                      </span>
                    </div>
                    <div className="flex items-center gap-2">
                      <div className="flex-1 bg-gray-200 rounded-full h-2">
                        <div
                          className={`h-2 rounded-full ${getMasteryColor(item.mastery_level)}`}
                          style={{ width: `${item.mastery_level * 100}%` }}
                        ></div>
                      </div>
                      <span className="text-sm font-medium text-gray-700">
                        {Math.round(item.mastery_level * 100)}%
                      </span>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>

          {/* Weak Points */}
          <div className="bg-white rounded-xl shadow-sm p-6">
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-xl font-semibold text-gray-900">薄弱知识点</h2>
              <TrendingUp className="w-6 h-6 text-red-400" />
            </div>
            
            {weakPoints.length === 0 ? (
              <div className="text-center py-8">
                <p className="text-gray-500 mb-2">暂无薄弱知识点</p>
                <p className="text-sm text-gray-400">继续保持！</p>
              </div>
            ) : (
              <div className="space-y-4">
                {weakPoints.map((point, idx) => (
                  <div key={idx} className="p-4 bg-red-50 border border-red-100 rounded-lg">
                    <div className="flex items-center justify-between mb-2">
                      <h3 className="font-medium text-gray-900">{point.name}</h3>
                      <span className="text-sm text-gray-600">{point.subject}</span>
                    </div>
                    <div className="flex items-center gap-2 mb-3">
                      <div className="flex-1 bg-red-200 rounded-full h-2">
                        <div
                          className="bg-red-500 h-2 rounded-full"
                          style={{ width: `${point.mastery_level * 100}%` }}
                        ></div>
                      </div>
                      <span className="text-sm font-medium text-red-700">
                        {Math.round(point.mastery_level * 100)}%
                      </span>
                    </div>
                    <button className="text-sm text-blue-600 hover:text-blue-800 font-medium">
                      针对性练习 →
                    </button>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>

        {/* Study Calendar */}
        <div className="bg-white rounded-xl shadow-sm p-6 mt-8">
          <div className="flex items-center justify-between mb-6">
            <h2 className="text-xl font-semibold text-gray-900">学习日历</h2>
            <div className="flex items-center gap-2">
              <Calendar className="w-5 h-5 text-gray-400" />
              <span className="text-sm text-gray-600">
                本月学习 {stats?.study_days || 0} 天
              </span>
            </div>
          </div>
          
          <div className="grid grid-cols-7 gap-2">
            {Array.from({ length: 35 }).map((_, idx) => {
              const hasStudy = Math.random() > 0.5
              return (
                <div
                  key={idx}
                  className={`aspect-square rounded flex items-center justify-center text-sm ${
                    hasStudy ? 'bg-green-500 text-white font-medium' : 'bg-gray-100 text-gray-400'
                  }`}
                >
                  {idx + 1}
                </div>
              )
            })}
          </div>
          
          <div className="flex items-center justify-center gap-6 mt-6 text-sm">
            <div className="flex items-center gap-2">
              <div className="w-4 h-4 bg-gray-100 rounded"></div>
              <span className="text-gray-600">未学习</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="w-4 h-4 bg-green-500 rounded"></div>
              <span className="text-gray-600">已完成</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

function StatCard({ icon, label, value, unit, color }: {
  icon: React.ReactNode
  label: string
  value: number
  unit: string
  color: string
}) {
  return (
    <div className="bg-white rounded-xl shadow-sm p-6">
      <div className="flex items-center gap-4">
        <div className={`p-3 rounded-lg bg-${color}-50`}>
          {icon}
        </div>
        <div>
          <p className="text-sm text-gray-600">{label}</p>
          <p className="text-2xl font-bold text-gray-900">
            {typeof value === 'number' && value % 1 !== 0 ? value.toFixed(1) : value}
            <span className="text-sm font-normal text-gray-500 ml-1">{unit}</span>
          </p>
        </div>
      </div>
    </div>
  )
}
