class LichSuBaiThiModel {
  final String id;
  final String maDeThi;
  final String tenDeThi;
  final String? moTa;
  final String duration;           // “12.9 phút”
  final String thoiGianBatDau;     // “20:21 - 20/06/2025”
  final String thoiGianKetThuc;
  final bool isPass;
  final String thoiGianBatDauDate;
  final String thoiGianBatDauTime;
  final double maxScore;
  final double totalScore;
  final int totalQuestions;
  final int totalCorrect;
  final int totalWrong;
  final int totalUnanswered;
  final String maNhanVien;
  final String fullName;
  final String email;

  LichSuBaiThiModel({
    required this.id,
    required this.maDeThi,
    required this.tenDeThi,
    this.moTa,
    required this.duration,
    required this.thoiGianBatDau,
    required this.thoiGianKetThuc,
    required this.isPass,
    required this.thoiGianBatDauDate,
    required this.thoiGianBatDauTime,
    required this.maxScore,
    required this.totalScore,
    required this.totalQuestions,
    required this.totalCorrect,
    required this.totalWrong,
    required this.totalUnanswered,
    required this.maNhanVien,
    required this.fullName,
    required this.email,
  });

  factory LichSuBaiThiModel.fromJson(Map<String, dynamic> json) {
    return LichSuBaiThiModel(
      id: json['id'],
      maDeThi: json['maDeThi'],
      tenDeThi: json['tenDeThi'],
      moTa: json['moTa'],
      duration: json['duration'],
      thoiGianBatDau: json['thoiGianBatDau'],
      thoiGianKetThuc: json['thoiGianKetThuc'],
      isPass: json['isPass'],
      thoiGianBatDauDate: json['thoiGianBatDauDate'],
      thoiGianBatDauTime: json['thoiGianBatDauTime'],
      maxScore: (json['maxScore'] as num).toDouble(),
      totalScore: (json['totalScore'] as num).toDouble(),
      totalQuestions: json['totalQuestions'],
      totalCorrect: json['totalCorrect'],
      totalWrong: json['totalWrong'],
      totalUnanswered: json['totalUnanswered'],
      maNhanVien: json['maNhanVien'],
      fullName: json['fullName'],
      email: json['email'],
    );
  }
}