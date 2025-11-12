export interface User {
  id: string
  email: string
  username: string
  role: string
}

export interface Question {
  id: string
  type: string
  subject: string
  difficulty: number
  question: string
  options?: string[]
}
