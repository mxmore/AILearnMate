import Link from 'next/link'
import { BookOpen, Brain, Target, TrendingUp } from 'lucide-react'

export default function HomePage() {
  return (
    <div className="min-h-screen bg-gradient-to-b from-blue-50 to-white">
      <header className="border-b bg-white shadow-sm">
        <div className="container mx-auto px-4 py-4 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Brain className="w-8 h-8 text-blue-600" />
            <h1 className="text-2xl font-bold text-gray-900">AILearnMate</h1>
          </div>
          <nav className="hidden md:flex gap-6">
            <Link href="/practice" className="text-gray-600 hover:text-blue-600">刷题</Link>
            <Link href="/materials" className="text-gray-600 hover:text-blue-600">资料</Link>
            <Link href="/progress" className="text-gray-600 hover:text-blue-600">进度</Link>
            <Link href="/plan" className="text-gray-600 hover:text-blue-600">计划</Link>
          </nav>
          <div className="flex gap-4">
            <Link href="/login" className="text-gray-600 hover:text-blue-600">登录</Link>
            <Link href="/register" className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700">注册</Link>
          </div>
        </div>
      </header>
      <section className="container mx-auto px-4 py-20 text-center">
        <h2 className="text-5xl font-bold text-gray-900 mb-6">AI 驱动的智能学习平台</h2>
        <p className="text-xl text-gray-600 mb-8 max-w-2xl mx-auto">自适应出题 · 智能复习 · 知识图谱 · 学习分析</p>
        <div className="flex gap-4 justify-center">
          <Link href="/practice" className="px-8 py-3 bg-blue-600 text-white rounded-lg text-lg font-semibold hover:bg-blue-700 transition">开始刷题</Link>
          <Link href="/about" className="px-8 py-3 border-2 border-blue-600 text-blue-600 rounded-lg text-lg font-semibold hover:bg-blue-50 transition">了解更多</Link>
        </div>
      </section>
    </div>
  )
}
