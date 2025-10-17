import 'package:flutter/material.dart';

class IdName {
  final int id;
  final String name;
  const IdName({required this.id, required this.name});
}

class TabFilter {
  final String label;
  final int count;
  final int? trangThai; // null = Tổng cộng, 1..5 = các trạng thái
  final String? gradeId; // id xếp loại (GUID), null nếu là tab tình trạng
  final Color bg, fg;
  const TabFilter({
    required this.label,
    required this.count,
    required this.bg,
    required this.fg,
    this.trangThai,
    this.gradeId,
  });
}
