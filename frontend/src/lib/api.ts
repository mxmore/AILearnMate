import axios from 'axios'

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'
const API_PREFIX = '/api/v1'

export const api = axios.create({
  baseURL: `${API_URL}${API_PREFIX}`,
  headers: {
    'Content-Type': 'application/json',
  },
})

api.interceptors.request.use(
  (config) => {
    if (typeof window !== 'undefined') {
      const token = localStorage.getItem('access_token')
      if (token) {
        config.headers.Authorization = `Bearer ${token}`
      }
    }
    return config
  },
  (error) => Promise.reject(error)
)

api.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config
    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true
      try {
        const refreshToken = localStorage.getItem('refresh_token')
        const response = await axios.post(`${API_URL}${API_PREFIX}/auth/refresh`, {
          refresh_token: refreshToken,
        })
        const { access_token, refresh_token } = response.data
        localStorage.setItem('access_token', access_token)
        localStorage.setItem('refresh_token', refresh_token)
        originalRequest.headers.Authorization = `Bearer ${access_token}`
        return api(originalRequest)
      } catch (refreshError) {
        localStorage.removeItem('access_token')
        localStorage.removeItem('refresh_token')
        window.location.href = '/login'
        return Promise.reject(refreshError)
      }
    }
    return Promise.reject(error)
  }
)

export const authAPI = {
  register: (data: { email: string; username: string; password: string }) =>
    api.post('/auth/register', data),
  login: (username: string, password: string) =>
    api.post('/auth/login', new URLSearchParams({ username, password }), {
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    }),
  logout: () => api.post('/auth/logout'),
}

export const userAPI = {
  getProfile: () => api.get('/users/me'),
  updateProfile: (data: { username?: string; avatar_url?: string }) =>
    api.put('/users/me', data),
  getStats: () => api.get('/users/stats'),
}

export const questionAPI = {
  list: (params?: {
    subject?: string
    difficulty?: number
    type?: string
    skip?: number
    limit?: number
  }) => api.get('/questions', { params }),
  get: (id: string) => api.get(`/questions/${id}`),
  submitAnswer: (data: {
    question_id: string
    answer: string
    time_spent: number
  }) => api.post('/questions/answer', data),
  getAdaptive: (count: number = 10, subject?: string) =>
    api.get('/questions/adaptive/generate', { params: { count, subject } }),
}

export const studyAPI = {
  listPlans: (status?: string) =>
    api.get('/study/plans', { params: { status } }),
  createPlan: (data: {
    name: string
    description?: string
    subject: string
    start_date: string
    end_date?: string
    daily_target: number
    knowledge_point_ids: string[]
  }) => api.post('/study/plans', data),
  startSession: (sessionType: string, subject?: string) =>
    api.post('/study/sessions/start', null, { params: { session_type: sessionType, subject } }),
  endSession: (sessionId: string) =>
    api.post(`/study/sessions/${sessionId}/end`),
  checkInToday: () => api.post('/study/check-ins/today'),
  listCheckIns: (days: number = 30) =>
    api.get('/study/check-ins', { params: { days } }),
  getWrongQuestions: (isMastered?: boolean) =>
    api.get('/study/wrong-questions', { params: { is_mastered: isMastered } }),
}

export const materialAPI = {
  list: (type?: string) => api.get('/materials', { params: { type } }),
  get: (id: string) => api.get(`/materials/${id}`),
  upload: (file: File, title?: string, description?: string) => {
    const formData = new FormData()
    formData.append('file', file)
    if (title) formData.append('title', title)
    if (description) formData.append('description', description)
    return api.post('/materials/upload', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    })
  },
  delete: (id: string) => api.delete(`/materials/${id}`),
  getProcessingStatus: (id: string) =>
    api.get(`/materials/${id}/processing-status`),
}

export const knowledgeAPI = {
  list: (params?: { subject?: string; level?: number; parent_id?: string }) =>
    api.get('/knowledge', { params }),
  getTree: (subject: string) =>
    api.get('/knowledge/tree', { params: { subject } }),
  getMastery: (subject?: string) =>
    api.get('/knowledge/mastery', { params: { subject } }),
  getWeakPoints: (threshold: number = 0.6, limit: number = 10) =>
    api.get('/knowledge/weak-points', { params: { threshold, limit } }),
  search: (query: string, limit: number = 10) =>
    api.get('/knowledge/search', { params: { query, limit } }),
}

export default api
