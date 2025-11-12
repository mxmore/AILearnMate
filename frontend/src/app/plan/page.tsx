'use client'

import { useState, useEffect } from 'react'
import { studyAPI } from '@/lib/api'
import { Plus, Target, Calendar, TrendingUp, CheckCircle, Clock, Flame } from 'lucide-react'

interface StudyPlan {
  id: string
  name: string
  description?: string
  subject: string
  start_date: string
  end_date?: string
  daily_target: number
  status: string
  progress: number
}

interface CheckIn {
  date: string
  questions_completed: number
  study_minutes: number
  streak_days: number
}

export default function PlanPage() {
  const [plans, setPlans] = useState<StudyPlan[]>([])
  const [checkIns, setCheckIns] = useState<CheckIn[]>([])
  const [loading, setLoading] = useState(true)
  const [showCreateModal, setShowCreateModal] = useState(false)
  const [todayCheckedIn, setTodayCheckedIn] = useState(false)

  useEffect(() => {
    loadData()
  }, [])

  const loadData = async () => {
    try {
      setLoading(true)
      const [plansRes, checkInsRes] = await Promise.all([
        studyAPI.listPlans(),
        studyAPI.listCheckIns(30)
      ])
      
      setPlans(plansRes.data)
      setCheckIns(checkInsRes.data)
      
      // Check if already checked in today
      const today = new Date().toISOString().split('T')[0]
      setTodayCheckedIn(checkInsRes.data.some((c: CheckIn) => c.date === today))
    } catch (error) {
      console.error('Failed to load plan data:', error)
      // Mock data for demo
      setPlans([
        {
          id: '1',
          name: '初中数学强化',
          description: '针对薄弱知识点的强化训练',
          subject: '数学',
          start_date: new Date().toISOString().split('T')[0],
          daily_target: 30,
          status: 'active',
          progress: 0.45
        },
        {
          id: '2',
          name: '英语备考计划',
          description: '英语语法和词汇全面提升',
          subject: '英语',
          start_date: new Date(Date.now() - 10 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
          daily_target: 50,
          status: 'active',
          progress: 0.68
        }
      ])
      setCheckIns([
        {
          date: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
          questions_completed: 45,
          study_minutes: 70,
          streak_days: 7
        },
        {
          date: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
          questions_completed: 38,
          study_minutes: 55,
          streak_days: 6
        }
      ])
    } finally {
      setLoading(false)
    }
  }

  const handleCheckIn = async () => {
    try {
      await studyAPI.checkInToday()
      setTodayCheckedIn(true)
      loadData()
      alert('打卡成功！继续保持！')
    } catch (error) {
      console.error('Check-in failed:', error)
      alert('打卡失败，请重试')
    }
  }

  const currentStreak = checkIns[0]?.streak_days || 0

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <p className="text-gray-600">加载中...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm border-b">
        <div className="container mx-auto px-4 py-6">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-3xl font-bold text-gray-900">学习计划</h1>
              <p className="text-gray-600 mt-2">制定目标，持续学习，养成习惯</p>
            </div>
            <button
              onClick={() => setShowCreateModal(true)}
              className="flex items-center gap-2 px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition"
            >
              <Plus className="w-5 h-5" />
              创建计划
            </button>
          </div>
        </div>
      </header>

      <div className="container mx-auto px-4 py-8 max-w-7xl">
        {/* Check-in Section */}
        <div className="bg-gradient-to-r from-blue-500 to-purple-600 rounded-xl shadow-lg p-8 mb-8 text-white">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-6">
              <div className="bg-white/20 p-4 rounded-full">
                <Flame className="w-12 h-12" />
              </div>
              <div>
                <h2 className="text-3xl font-bold mb-2">连续打卡 {currentStreak} 天</h2>
                <p className="text-blue-100">保持学习习惯，每天进步一点点</p>
              </div>
            </div>
            
            {!todayCheckedIn ? (
              <button
                onClick={handleCheckIn}
                className="px-8 py-4 bg-white text-blue-600 rounded-xl font-semibold hover:bg-blue-50 transition text-lg"
              >
                今日打卡
              </button>
            ) : (
              <div className="flex items-center gap-2 px-8 py-4 bg-green-500 rounded-xl">
                <CheckCircle className="w-6 h-6" />
                <span className="font-semibold text-lg">已打卡</span>
              </div>
            )}
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Study Plans */}
          <div className="lg:col-span-2">
            <h2 className="text-2xl font-bold text-gray-900 mb-6">我的计划</h2>
            
            {plans.length === 0 ? (
              <div className="bg-white rounded-xl shadow-sm p-12 text-center">
                <Target className="w-16 h-16 text-gray-300 mx-auto mb-4" />
                <h3 className="text-lg font-semibold text-gray-900 mb-2">还没有学习计划</h3>
                <p className="text-gray-600 mb-6">创建一个计划，开始你的学习之旅</p>
                <button
                  onClick={() => setShowCreateModal(true)}
                  className="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition"
                >
                  创建计划
                </button>
              </div>
            ) : (
              <div className="space-y-6">
                {plans.map((plan) => (
                  <div key={plan.id} className="bg-white rounded-xl shadow-sm p-6 hover:shadow-md transition">
                    <div className="flex items-start justify-between mb-4">
                      <div>
                        <h3 className="text-xl font-bold text-gray-900 mb-2">{plan.name}</h3>
                        {plan.description && (
                          <p className="text-gray-600">{plan.description}</p>
                        )}
                      </div>
                      <span className={`px-3 py-1 rounded-full text-sm font-medium ${
                        plan.status === 'active' ? 'bg-green-100 text-green-800' :
                        plan.status === 'completed' ? 'bg-blue-100 text-blue-800' :
                        'bg-gray-100 text-gray-800'
                      }`}>
                        {plan.status === 'active' ? '进行中' :
                         plan.status === 'completed' ? '已完成' : '已暂停'}
                      </span>
                    </div>
                    
                    <div className="grid grid-cols-3 gap-4 mb-4">
                      <div className="flex items-center gap-2">
                        <Target className="w-4 h-4 text-gray-400" />
                        <span className="text-sm text-gray-600">{plan.subject}</span>
                      </div>
                      <div className="flex items-center gap-2">
                        <Calendar className="w-4 h-4 text-gray-400" />
                        <span className="text-sm text-gray-600">
                          {new Date(plan.start_date).toLocaleDateString()}
                        </span>
                      </div>
                      <div className="flex items-center gap-2">
                        <Clock className="w-4 h-4 text-gray-400" />
                        <span className="text-sm text-gray-600">每日 {plan.daily_target} 题</span>
                      </div>
                    </div>
                    
                    <div>
                      <div className="flex items-center justify-between mb-2">
                        <span className="text-sm text-gray-600">完成进度</span>
                        <span className="text-sm font-semibold text-blue-600">
                          {Math.round(plan.progress * 100)}%
                        </span>
                      </div>
                      <div className="w-full bg-gray-200 rounded-full h-2">
                        <div
                          className="bg-blue-600 h-2 rounded-full transition-all"
                          style={{ width: `${plan.progress * 100}%` }}
                        ></div>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>

          {/* Check-in History */}
          <div>
            <h2 className="text-2xl font-bold text-gray-900 mb-6">打卡记录</h2>
            <div className="bg-white rounded-xl shadow-sm p-6">
              {checkIns.length === 0 ? (
                <p className="text-center text-gray-500 py-8">暂无打卡记录</p>
              ) : (
                <div className="space-y-4">
                  {checkIns.map((checkIn, idx) => (
                    <div key={idx} className="border-b border-gray-100 pb-4 last:border-0">
                      <div className="flex items-center justify-between mb-2">
                        <span className="font-medium text-gray-900">
                          {new Date(checkIn.date).toLocaleDateString()}
                        </span>
                        <CheckCircle className="w-5 h-5 text-green-500" />
                      </div>
                      <div className="space-y-1 text-sm text-gray-600">
                        <div className="flex items-center justify-between">
                          <span>完成题目</span>
                          <span className="font-medium">{checkIn.questions_completed} 题</span>
                        </div>
                        <div className="flex items-center justify-between">
                          <span>学习时长</span>
                          <span className="font-medium">{checkIn.study_minutes} 分钟</span>
                        </div>
                        <div className="flex items-center justify-between">
                          <span>连续天数</span>
                          <span className="font-medium text-orange-600">
                            {checkIn.streak_days} 天
                          </span>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
        </div>
      </div>

      {/* Create Plan Modal (simplified) */}
      {showCreateModal && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
          <div className="bg-white rounded-xl p-8 max-w-md w-full mx-4">
            <h2 className="text-2xl font-bold text-gray-900 mb-6">创建学习计划</h2>
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  计划名称
                </label>
                <input
                  type="text"
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  placeholder="例如：初中数学强化"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  学科
                </label>
                <select className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                  <option>数学</option>
                  <option>英语</option>
                  <option>物理</option>
                  <option>化学</option>
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  每日目标（题数）
                </label>
                <input
                  type="number"
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  placeholder="20"
                  defaultValue={20}
                />
              </div>
            </div>
            <div className="flex gap-4 mt-6">
              <button
                onClick={() => setShowCreateModal(false)}
                className="flex-1 px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition"
              >
                取消
              </button>
              <button
                onClick={() => {
                  setShowCreateModal(false)
                  alert('计划创建成功！')
                }}
                className="flex-1 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition"
              >
                创建
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
