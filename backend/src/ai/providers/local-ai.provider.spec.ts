import { LocalAiProvider } from './local-ai.provider';

describe('LocalAiProvider', () => {
  let provider: LocalAiProvider;

  beforeEach(() => {
    provider = new LocalAiProvider();
  });

  it('returns a non-empty string answer', async () => {
    const answer = await provider.generateAnswer(
      "Pomidor bargi sarg'aymoqda, nima qilish kerak?",
    );

    expect(typeof answer).toBe('string');
    expect(answer.length).toBeGreaterThan(0);
  });

  it('includes agronom or veterinarian disclaimer', async () => {
    const answer = await provider.generateAnswer(
      "Sigir yem yemayapti, nima qilish kerak?",
    );

    expect(answer).toMatch(/agronom|veterinar/i);
    expect(answer).toContain('maslahat');
  });
});
