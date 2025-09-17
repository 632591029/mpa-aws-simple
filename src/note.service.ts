import { Injectable } from '@nestjs/common';
import { PrismaService } from './prisma.service';

export class CreateNoteDto {
  title: string;
  content: string;
}

@Injectable()
export class NoteService {
  constructor(private prisma: PrismaService) {}

  // 获取所有笔记
  async findAll() {
    return this.prisma.note.findMany({
      orderBy: { createdAt: 'desc' }, // 按创建时间降序排列
    });
  }

  // 创建笔记
  async create(data: CreateNoteDto) {
    return this.prisma.note.create({
      data,
    });
  }

  // 删除笔记
  async remove(id: number) {
    return this.prisma.note.delete({
      where: { id },
    });
  }
}