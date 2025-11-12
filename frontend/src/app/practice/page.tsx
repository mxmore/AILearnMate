'use client'

import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { questionAPI } from '@/lib/api'
import { BookOpen, CheckCircle, XCircle, Clock, TrendingUp } from 'lucide-react'

interface Question {
  id: string
  type: string
  subject: string
  difficulty: number
  question: string
  options?: string[]
  images?: string[]
}

interface AnswerResult {
  is_correct: boolean
  correct_answer: string
  explanation: string
  time_spent: number
}

export default function PracticePage() {
  const router = useRouter()
  const [loading, setLoading] = useState(true)
  const [questions, setQuestions] = useState<Question[]>([])
  const [currentIndex, setCurrentIndex] = useState(0)
  const [selectedAnswer, setSelectedAnswer] = useState<string>('')
  const [showResult, setShowResult] = useState(false)
  const [result, setResult] = useState<AnswerResult | null>(null)
  const [startTime, setStartTime] = useState<number>(Date.now())
  const [stats, setStats] = useState({ correct: 0, total: 0 })

  useEffect(() => {
    loadQuestions()
  }, [])

  const loadQuestions = async () => {
    try {
      setLoading(true)
      // Try to get adaptive questions
      const response = await questionAPI.getAdaptive(10)
      if (response.data.questions && response.data.questions.length > 0) {
        setQuestions(response.data.questions)
      } else {
        // Fallback to regular question list
        const listResponse = await questionAPI.list({ limit: 10 })
        setQuestions(listResponse.data)
      }
    } catch (error) {
      console.error('Failed to load questions:', error)
      // Use mock data for demo
      setQuestions([
        {
          id: '1',
          type: 'single_choice',
          subject: '数学',
          difficulty: 3,
          question: '方程 2x + 5 = 13 的解是？',
          options: ['A. x = 3', 'B. x = 4', 'C. x = 5', 'D. x = 6']
        }
      ])
    } finally {
      setLoading(false)
    }
  }

  const handleSubmitAnswer = async () => {
    if (!selectedAnswer) return

    const timeSpent = Math.floor((Date.now() - startTime) / 1000)
    
    try {
      const response = await questionAPI.submitAnswer({
        question_id: currentQuestion.id,
        answer: selectedAnswer,
        time_spent: timeSpent
      })
      setResult(response.data)
      setShowResult(true)
      
      if (response.data.is_correct) {
        setStats(prev => ({ correct: prev.correct + 1, total: prev.total + 1 }))
      } else {
        setStats(prev => ({ ...prev, total: prev.total + 1 }))
      }
    } catch (error) {
      console.error('Failed to submit answer:', error)
      // Mock result for demo
      const isCorrect = selectedAnswer === 'B'
      setResult({
        is_correct: isCorrect,
        correct_answer: 'B',
        explanation: '2x + 5 = 13，移项得 2x = 8，两边同时除以2，得 x = 4',
        time_spent: timeSpent
      })
      setShowResult(true)
      setStats(prev => ({ 
        correct: prev.correct + (isCorrect ? 1 : 0), 
        total: prev.total + 1 
      }))
    }
  }

  const handleNextQuestion = () => {
    if (currentIndex < questions.length - 1) {
      setCurrentIndex(currentIndex + 1)
      setSelectedAnswer('')
      setShowResult(false)
      setResult(null)
      setStartTime(Date.now())
    } else {
      // Practice session completed
      router.push('/progress')
    }
  }

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <p className="text-gray-600">加载题目中...</p>
        </div>
      </div>
    )
  }

  if (questions.length === 0) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <BookOpen className="w-16 h-16 text-gray-400 mx-auto mb-4" />
          <p className="text-gray-600 mb-4">暂无可用题目</p>
          <button
            onClick={() => router.push('/')}
            className="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
          >
            返回首页
          </button>
        </div>
      </div>
    )
  }

  const currentQuestion = questions[currentIndex]

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm border-b">
        <div className="container mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <h1 className="text-2xl font-bold text-gray-900">智能刷题</h1>
            <div className="flex items-center gap-6">
              <div className="flex items-center gap-2">
                <Clock className="w-5 h-5 text-gray-500" />
                <span className="text-sm text-gray-600">
                  {currentIndex + 1} / {questions.length}
                </span>
              </div>
              <div className="flex items-center gap-2">
                <TrendingUp className="w-5 h-5 text-green-600" />
                <span className="text-sm font-semibold">
                  准确率: {stats.total > 0 ? Math.round((stats.correct / stats.total) * 100) : 0}%
                </span>
              </div>
            </div>
          </div>
        </div>
      </header>

      {/* Question Content */}
      <div className="container mx-auto px-4 py-8 max-w-4xl">
        <div className="bg-white rounded-xl shadow-lg p-8">
          {/* Question Info */}
          <div className="flex items-center gap-4 mb-6">
            <span className="px-3 py-1 bg-blue-100 text-blue-800 rounded-full text-sm font-medium">
              {currentQuestion.subject}
            </span>
            <span className="px-3 py-1 bg-purple-100 text-purple-800 rounded-full text-sm font-medium">
              难度: {currentQuestion.difficulty}/5
            </span>
            <span className="px-3 py-1 bg-gray-100 text-gray-800 rounded-full text-sm font-medium">
              {currentQuestion.type === 'single_choice' ? '单选题' : 
               currentQuestion.type === 'multiple_choice' ? '多选题' : '判断题'}
            </span>
          </div>

          {/* Question Text */}
          <div className="mb-8">
            <h2 className="text-xl font-semibold text-gray-900 mb-4">
              {currentQuestion.question}
            </h2>
            {currentQuestion.images && currentQuestion.images.length > 0 && (
              <div className="space-y-2">
                {currentQuestion.images.map((img, idx) => (
                  <img key={idx} src={img} alt="Question" className="max-w-full rounded" />
                ))}
              </div>
            )}
          </div>

          {/* Options */}
          {currentQuestion.options && (
            <div className="space-y-3 mb-8">
              {currentQuestion.options.map((option, idx) => (
                <button
                  key={idx}
                  onClick={() => !showResult && setSelectedAnswer(option.charAt(0))}
                  disabled={showResult}
                  className={`w-full text-left p-4 rounded-lg border-2 transition-all ${
                    selectedAnswer === option.charAt(0)
                      ? showResult
                        ? result?.is_correct
                          ? 'border-green-500 bg-green-50'
                          : 'border-red-500 bg-red-50'
                        : 'border-blue-500 bg-blue-50'
                      : showResult && result?.correct_answer === option.charAt(0)
                      ? 'border-green-500 bg-green-50'
                      : 'border-gray-200 hover:border-gray-300 hover:bg-gray-50'
                  } ${showResult ? 'cursor-not-allowed' : 'cursor-pointer'}`}
                >
                  <div className="flex items-center gap-3">
                    {showResult && selectedAnswer === option.charAt(0) && (
                      result?.is_correct ? (
                        <CheckCircle className="w-5 h-5 text-green-600" />
                      ) : (
                        <XCircle className="w-5 h-5 text-red-600" />
                      )
                    )}
                    {showResult && result?.correct_answer === option.charAt(0) && (
                      <CheckCircle className="w-5 h-5 text-green-600" />
                    )}
                    <span className="font-medium">{option}</span>
                  </div>
                </button>
              ))}
            </div>
          )}

          {/* Result & Explanation */}
          {showResult && result && (
            <div className={`p-6 rounded-lg mb-6 ${
              result.is_correct ? 'bg-green-50 border-2 border-green-200' : 'bg-red-50 border-2 border-red-200'
            }`}>
              <div className="flex items-center gap-3 mb-4">
                {result.is_correct ? (
                  <>
                    <CheckCircle className="w-8 h-8 text-green-600" />
                    <div>
                      <h3 className="text-lg font-bold text-green-900">回答正确！</h3>
                      <p className="text-sm text-green-700">用时: {result.time_spent} 秒</p>
                    </div>
                  </>
                ) : (
                  <>
                    <XCircle className="w-8 h-8 text-red-600" />
                    <div>
                      <h3 className="text-lg font-bold text-red-900">回答错误</h3>
                      <p className="text-sm text-red-700">正确答案: {result.correct_answer}</p>
                    </div>
                  </>
                )}
              </div>
              <div className="bg-white p-4 rounded-lg">
                <h4 className="font-semibold text-gray-900 mb-2">答案解析：</h4>
                <p className="text-gray-700">{result.explanation}</p>
              </div>
            </div>
          )}

          {/* Action Buttons */}
          <div className="flex gap-4">
            {!showResult ? (
              <button
                onClick={handleSubmitAnswer}
                disabled={!selectedAnswer}
                className="flex-1 py-3 bg-blue-600 text-white rounded-lg font-semibold hover:bg-blue-700 disabled:bg-gray-300 disabled:cursor-not-allowed transition"
              >
                提交答案
              </button>
            ) : (
              <button
                onClick={handleNextQuestion}
                className="flex-1 py-3 bg-blue-600 text-white rounded-lg font-semibold hover:bg-blue-700 transition"
              >
                {currentIndex < questions.length - 1 ? '下一题' : '完成练习'}
              </button>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
