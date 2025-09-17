import { Controller, Get, Post, Delete, Body, Param, ParseIntPipe } from '@nestjs/common';
import { NoteService } from './note.service';

export class CreateNoteDto {
  title: string;
  content: string;
}

@Controller('notes')
export class NoteController {
  constructor(private readonly noteService: NoteService) {}

  // 获取所有笔记
  @Get()
  async findAll() {
    return this.noteService.findAll();
  }

  // 创建笔记
  @Post()
  async create(@Body() createNoteDto: CreateNoteDto) {
    return this.noteService.create(createNoteDto);
  }

  // 删除笔记
  @Delete(':id')
  async remove(@Param('id', ParseIntPipe) id: number) {
    return this.noteService.remove(id);
  }
}