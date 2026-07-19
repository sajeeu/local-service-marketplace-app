import { PasswordService } from './password.service';

describe('PasswordService', () => {
  const service = new PasswordService();

  it('hashes and verifies passwords', async () => {
    const hash = await service.hash('secure-password-1');
    expect(hash).not.toContain('secure-password-1');
    await expect(service.verify(hash, 'secure-password-1')).resolves.toBe(true);
    await expect(service.verify(hash, 'wrong-password')).resolves.toBe(false);
  });
});
