export type View = 'chat' | 'content' | 'exercises' | 'resources';

export interface ChatMessage {
  role: 'user' | 'model';
  text: string;
  image?: string;
  isLoading?: boolean;
}

export interface GeneratedContent {
  html: string;
}

export interface ExerciseOption {
  text: string;
}

export interface ExerciseContent {
  question: string;
  options: ExerciseOption[];
  correctAnswerIndex: number;
  explanation: string;
}

export type NodeType = 'concept' | 'practice' | 'game' | 'playground';

export interface RoadmapNode {
  id: string;
  type: NodeType;
  title: string;
  topic: string;
  requires?: string[];
  requiredScore?: number;
}

export interface RoadmapSection {
  title: string;
  nodes: RoadmapNode[];
}

export interface UserProgressNode {
    completed: boolean;
    score?: number;
}

export type UserProgress = Record<string, UserProgressNode>;

export interface PracticeResults {
    correct: number;
    incorrect: number;
}