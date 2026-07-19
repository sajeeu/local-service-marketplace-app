import { Injectable } from '@nestjs/common';
import { NotFoundAppError } from '../../../common/errors/app.error';
import { PrismaService } from '../../../prisma/prisma.service';
import { UpdateMeDto } from './dto/update-me.dto';
import { toPublicUser, type PublicUser } from './user.mapper';

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  async getMe(userId: string): Promise<PublicUser> {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) {
      throw new NotFoundAppError('User not found');
    }
    return toPublicUser(user);
  }

  async updateMe(userId: string, dto: UpdateMeDto): Promise<PublicUser> {
    const existing = await this.prisma.user.findUnique({
      where: { id: userId },
    });
    if (!existing) {
      throw new NotFoundAppError('User not found');
    }

    const user = await this.prisma.user.update({
      where: { id: userId },
      data: {
        displayName:
          dto.displayName === undefined
            ? undefined
            : dto.displayName?.trim() || null,
      },
    });
    return toPublicUser(user);
  }
}
