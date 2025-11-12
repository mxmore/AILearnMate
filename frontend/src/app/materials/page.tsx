'use client'

import { useState, useEffect } from 'react'
import { materialAPI } from '@/lib/api'
import { Upload, FileText, Image, File, Loader, CheckCircle, XCircle, Eye, Trash2 } from 'lucide-react'

interface Material {
  id: string
  title: string
  description?: string
  type: string
  file_url: string
  file_size: number
  page_count?: number
  processing_status: string
  created_at: string
}

export default function MaterialsPage() {
  const [materials, setMaterials] = useState<Material[]>([])
  const [loading, setLoading] = useState(true)
  const [uploading, setUploading] = useState(false)
  const [uploadProgress, setUploadProgress] = useState(0)

  useEffect(() => {
    loadMaterials()
  }, [])

  const loadMaterials = async () => {
    try {
      setLoading(true)
      const response = await materialAPI.list()
      setMaterials(response.data)
    } catch (error) {
      console.error('Failed to load materials:', error)
      // Mock data for demo
      setMaterials([
        {
          id: '1',
          title: '初中数学总复习资料',
          description: '包含代数、几何等各章节重点内容',
          type: 'pdf',
          file_url: '/materials/math_review.pdf',
          file_size: 2048576,
          page_count: 45,
          processing_status: 'completed',
          created_at: new Date().toISOString()
        },
        {
          id: '2',
          title: '高中英语语法大全',
          description: '系统总结高中英语各种语法点',
          type: 'pdf',
          file_url: '/materials/english_grammar.pdf',
          file_size: 3145728,
          page_count: 68,
          processing_status: 'completed',
          created_at: new Date().toISOString()
        }
      ])
    } finally {
      setLoading(false)
    }
  }

  const handleFileUpload = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0]
    if (!file) return

    const maxSize = 50 * 1024 * 1024 // 50MB
    if (file.size > maxSize) {
      alert('文件大小不能超过 50MB')
      return
    }

    try {
      setUploading(true)
      setUploadProgress(0)

      // Simulate upload progress
      const progressInterval = setInterval(() => {
        setUploadProgress(prev => {
          if (prev >= 90) {
            clearInterval(progressInterval)
            return 90
          }
          return prev + 10
        })
      }, 200)

      const response = await materialAPI.upload(file, file.name)
      
      clearInterval(progressInterval)
      setUploadProgress(100)
      
      setTimeout(() => {
        setUploading(false)
        setUploadProgress(0)
        loadMaterials()
        alert('文件上传成功！正在后台处理...')
      }, 500)
    } catch (error) {
      console.error('Upload failed:', error)
      alert('上传失败，请重试')
      setUploading(false)
      setUploadProgress(0)
    }
  }

  const handleDelete = async (id: string) => {
    if (!confirm('确定要删除这个资料吗？')) return

    try {
      await materialAPI.delete(id)
      loadMaterials()
    } catch (error) {
      console.error('Delete failed:', error)
      alert('删除失败，请重试')
    }
  }

  const formatFileSize = (bytes: number) => {
    if (bytes < 1024) return bytes + ' B'
    if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB'
    return (bytes / (1024 * 1024)).toFixed(1) + ' MB'
  }

  const getFileIcon = (type: string) => {
    switch (type) {
      case 'pdf':
        return <FileText className="w-8 h-8 text-red-500" />
      case 'image':
      case 'png':
      case 'jpg':
      case 'jpeg':
        return <Image className="w-8 h-8 text-blue-500" />
      default:
        return <File className="w-8 h-8 text-gray-500" />
    }
  }

  const getStatusBadge = (status: string) => {
    switch (status) {
      case 'completed':
        return (
          <span className="flex items-center gap-1 px-2 py-1 bg-green-100 text-green-800 rounded-full text-xs">
            <CheckCircle className="w-3 h-3" />
            已完成
          </span>
        )
      case 'processing':
        return (
          <span className="flex items-center gap-1 px-2 py-1 bg-blue-100 text-blue-800 rounded-full text-xs">
            <Loader className="w-3 h-3 animate-spin" />
            处理中
          </span>
        )
      case 'failed':
        return (
          <span className="flex items-center gap-1 px-2 py-1 bg-red-100 text-red-800 rounded-full text-xs">
            <XCircle className="w-3 h-3" />
            失败
          </span>
        )
      default:
        return (
          <span className="px-2 py-1 bg-gray-100 text-gray-800 rounded-full text-xs">
            {status}
          </span>
        )
    }
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm border-b">
        <div className="container mx-auto px-4 py-6">
          <h1 className="text-3xl font-bold text-gray-900">学习资料</h1>
          <p className="text-gray-600 mt-2">上传学习资料，AI 自动提取知识点并生成题目</p>
        </div>
      </header>

      <div className="container mx-auto px-4 py-8 max-w-6xl">
        {/* Upload Section */}
        <div className="bg-white rounded-xl shadow-sm p-8 mb-8">
          <h2 className="text-xl font-semibold text-gray-900 mb-4">上传新资料</h2>
          <div className="border-2 border-dashed border-gray-300 rounded-lg p-8 text-center hover:border-blue-500 transition">
            <input
              type="file"
              id="file-upload"
              className="hidden"
              accept=".pdf,.png,.jpg,.jpeg,.doc,.docx,.ppt,.pptx,.txt"
              onChange={handleFileUpload}
              disabled={uploading}
            />
            <label
              htmlFor="file-upload"
              className={`cursor-pointer ${uploading ? 'opacity-50 cursor-not-allowed' : ''}`}
            >
              <Upload className="w-12 h-12 text-gray-400 mx-auto mb-4" />
              <p className="text-lg font-medium text-gray-700 mb-2">
                {uploading ? '上传中...' : '点击上传或拖拽文件'}
              </p>
              <p className="text-sm text-gray-500">
                支持 PDF、图片、Word、PPT 等格式，最大 50MB
              </p>
            </label>
            
            {uploading && (
              <div className="mt-4">
                <div className="w-full bg-gray-200 rounded-full h-2">
                  <div
                    className="bg-blue-600 h-2 rounded-full transition-all duration-300"
                    style={{ width: `${uploadProgress}%` }}
                  ></div>
                </div>
                <p className="text-sm text-gray-600 mt-2">{uploadProgress}%</p>
              </div>
            )}
          </div>
        </div>

        {/* Materials List */}
        <div className="bg-white rounded-xl shadow-sm p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">我的资料</h2>
          
          {loading ? (
            <div className="text-center py-12">
              <Loader className="w-8 h-8 text-gray-400 animate-spin mx-auto mb-4" />
              <p className="text-gray-600">加载中...</p>
            </div>
          ) : materials.length === 0 ? (
            <div className="text-center py-12">
              <FileText className="w-16 h-16 text-gray-300 mx-auto mb-4" />
              <p className="text-gray-600">还没有上传任何资料</p>
              <p className="text-sm text-gray-500 mt-2">上传资料后，AI 会自动分析并生成练习题</p>
            </div>
          ) : (
            <div className="space-y-4">
              {materials.map((material) => (
                <div
                  key={material.id}
                  className="border border-gray-200 rounded-lg p-4 hover:shadow-md transition"
                >
                  <div className="flex items-start gap-4">
                    <div className="flex-shrink-0">
                      {getFileIcon(material.type)}
                    </div>
                    
                    <div className="flex-1 min-w-0">
                      <div className="flex items-start justify-between mb-2">
                        <div>
                          <h3 className="text-lg font-semibold text-gray-900 truncate">
                            {material.title}
                          </h3>
                          {material.description && (
                            <p className="text-sm text-gray-600 mt-1">{material.description}</p>
                          )}
                        </div>
                        {getStatusBadge(material.processing_status)}
                      </div>
                      
                      <div className="flex items-center gap-4 text-sm text-gray-500">
                        <span>{formatFileSize(material.file_size)}</span>
                        {material.page_count && (
                          <span>{material.page_count} 页</span>
                        )}
                        <span>{new Date(material.created_at).toLocaleDateString()}</span>
                      </div>
                    </div>
                    
                    <div className="flex gap-2">
                      <button
                        onClick={() => window.open(material.file_url, '_blank')}
                        className="p-2 text-blue-600 hover:bg-blue-50 rounded-lg transition"
                        title="查看"
                      >
                        <Eye className="w-5 h-5" />
                      </button>
                      <button
                        onClick={() => handleDelete(material.id)}
                        className="p-2 text-red-600 hover:bg-red-50 rounded-lg transition"
                        title="删除"
                      >
                        <Trash2 className="w-5 h-5" />
                      </button>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
