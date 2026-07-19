import { Injectable } from '@nestjs/common';
import * as argon2 from 'argon2';

@Injectable()
export class PasswordService {
  async hash(plainPassword: string): Promise<string> {
    // argon2 typings resolve loosely under our ESLint config
    const hash = (await argon2.hash(plainPassword)) as string;
    return hash;
  }

  async verify(hash: string, plainPassword: string): Promise<boolean> {
    try {
      return Boolean(await argon2.verify(hash, plainPassword));
    } catch {
      return false;
    }
  }
}
