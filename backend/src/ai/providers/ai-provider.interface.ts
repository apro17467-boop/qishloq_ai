export const AI_PROVIDER = 'AI_PROVIDER';

export interface AiProvider {
  generateAnswer(question: string): Promise<string>;
}
