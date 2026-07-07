import { Injectable } from '@nestjs/common';
import { AiProvider } from './ai-provider.interface';

@Injectable()
export class LocalAiProvider implements AiProvider {
  async generateAnswer(question: string): Promise<string> {
    const trimmedQuestion = question.trim();

    return [
      'Savolingiz qabul qilindi.',
      `Savol mazmuni: "${trimmedQuestion}"`,
      "Belgilarni aniq baholash uchun ekin yoki hayvon turi, yoshi, hudud, mavsum, oxirgi ishlatilgan o'g'it yoki dori va rasm kabi qo'shimcha ma'lumotlar kerak bo'ladi.",
      "Hozircha umumiy tavsiya: zarar ko'rgan joyni kuzating, ortiqcha dori yoki o'g'it ishlatishga shoshilmang, sug'orish va oziqlantirish rejimini tekshiring.",
      "Bu javob yakuniy tashxis yoki davolash ko'rsatmasi emas. Yakuniy qaror uchun agronom yoki veterinar bilan maslahat qiling.",
    ].join(' ');
  }
}
