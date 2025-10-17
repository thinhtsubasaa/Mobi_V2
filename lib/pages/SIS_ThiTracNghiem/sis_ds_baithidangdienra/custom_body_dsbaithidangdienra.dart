import 'dart:convert';
import 'package:Thilogi/blocs/user_bloc.dart';
import 'package:Thilogi/models/sis/de_thi.dart';
import 'package:Thilogi/models/sis/lich_su_bai_thi.dart';
import 'package:Thilogi/pages/SIS_ThiTracNghiem/sis_lambaithi/lambaithi.dart';
import 'package:Thilogi/services/request_helper_sis.dart';
import 'package:Thilogi/utils/next_screen.dart';
import 'package:Thilogi/widgets/loading.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class CustomBodyDSBaiThiDangDienRa extends StatelessWidget {
  const CustomBodyDSBaiThiDangDienRa({super.key});

  @override
  Widget build(BuildContext context) {
    return const BodyDSBaiThiDangDienRaScreen();
  }
}

class BodyDSBaiThiDangDienRaScreen extends StatefulWidget {
  const BodyDSBaiThiDangDienRaScreen({super.key});

  @override
  _BodyDSBaiThiDangDienRaScreenState createState() =>
      _BodyDSBaiThiDangDienRaScreenState();
}

// Loại bỏ "with ChangeNotifier" không cần thiết
class _BodyDSBaiThiDangDienRaScreenState extends State<BodyDSBaiThiDangDienRaScreen> with TickerProviderStateMixin {
  static RequestHelperSIS requestHelper = RequestHelperSIS();
  bool _loading = false;
  List<DeThiModel>? _deThiList;
  List<DeThiModel>? get deThiList => _deThiList;

  List<LichSuBaiThiModel>? _lichSuBaiThiList;
  List<LichSuBaiThiModel>? get lichSuBaiThiList => _lichSuBaiThiList;

  bool _hasError = false;
  bool get hasError => _hasError;
  String? _errorCode;
  String? get errorCode => _errorCode;

  late Future<List<DeThiModel>> _futureDeThis;
  late UserBloc? _ub;

  @override
  void initState() {
    super.initState();
    _ub = Provider.of<UserBloc>(context, listen: false);
    _futureDeThis = _loadDeThis();
  }

  Future<List<DeThiModel>> _loadDeThis() async {
    final res = await requestHelper.getData('SIS/DeThi/dang-dien-ra-theo-nguoi-dung');
      if (res.statusCode == 200) {
        final list = (jsonDecode(res.body) as List)
            .map((j) => DeThiModel.fromJson(j))
            .toList();

        return list;
      }
    throw Exception('Status ${res.statusCode}');
  }

  Future<String?> _createExamSession(deThiId, userId) async {
    try {
      final response = await requestHelper.postData(
        'SIS/BaiThi/Start',
        {'DeThiId': deThiId, 'UserId': userId},
      );

      // Thêm kiểm tra 'mounted' trước khi hiển thị dialog
      if (!mounted) return null;

      if (response.statusCode != 201) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Thất bại',
          text: response.body.replaceAll('"', ''),
          confirmBtnText: 'Đồng ý',
        );
        return null;
      }

      return jsonDecode(response.body)['id'] as String;
    } catch (e) {
      // Thêm kiểm tra 'mounted' trước khi hiển thị dialog
      if (!mounted) return null;
      // Bắt ngoại lệ mạng hoặc parse
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Lỗi kết nối',
        text: e.toString(),
        confirmBtnText: 'Đóng',
      );
      return null;
    }
  }

  Future<List<LichSuBaiThiModel>> _fetchLichSuTheoDeThi(String deThiId) async {
    try {
      final res = await requestHelper.getData('SIS/BaiThi/de-thi/{$deThiId}/bai-thi-ca-nhan');
      if (res.statusCode == 200) {
        final list = (jsonDecode(res.body) as List)
            .map((j) => LichSuBaiThiModel.fromJson(j))
            .toList();

        return list;
      }
      throw Exception('Status ${res.statusCode}');
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
      return [];
    }
  }

  void _showLichSuDialog(BuildContext context, List<LichSuBaiThiModel> items) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE96327), Color(0xFFBC2925)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.history,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Lịch sử làm bài',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: items.isEmpty 
                  ? _buildEmptyState(context, 'Bạn chưa thi lần nào', 'Kết quả của các lần thi sẽ hiển thị tại đây', onRefresh: null, isError: false) 
                  : _buildTimelineList(items),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message, String detail, {required bool isError, VoidCallback? onRefresh}) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.quiz_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              detail,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
            isError && onRefresh != null 
              ? TextButton(
                onPressed: () {
                  onRefresh();
                },
                child: const Text(
                  'Tải lại',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ) 
              : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  // Thêm helper parse DateTime
  DateTime _parseAttemptTime(LichSuBaiThiModel it) {
    // ví dụ "09:15 - 21/07/2025"
    final parts = it.thoiGianBatDau.split(' - ');
    final time = parts[0];            // "09:15"
    final date = parts[1];            // "21/07/2025"
    return DateFormat("HH:mm dd/MM/yyyy", "vi_VN").parse("$time $date");
  }

  Widget _buildTimelineList(List<LichSuBaiThiModel> items) {
    // Sắp xếp theo thời gian mới nhất
    final sortedItems = [...items];
    sortedItems.sort((a, b) =>
      _parseAttemptTime(b).compareTo(_parseAttemptTime(a))
    );

    //Limit 10 item và group theo ngày
    final limitedItems = sortedItems.take(10).toList();
    final groupedByDate = _groupByDate(limitedItems);
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: groupedByDate.entries.length,
      itemBuilder: (context, dateIndex) {
        final dateEntry = groupedByDate.entries.elementAt(dateIndex);
        final dateKey = dateEntry.key;
        final attemptsOnDate = dateEntry.value;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header

            Center(child: _buildDateHeader(dateKey)),
            const SizedBox(height: 8),
            
            // Timeline items for this date
            ...attemptsOnDate.asMap().entries.map((entry) {
              final attempt = entry.value;
              return _buildTimelineItem(attempt);
            }).toList(),
            
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildDateHeader(String dateKey) {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    
    String displayDate = dateKey;
    
    // Format hiển thị thân thiện
    try {
      final date = DateTime.parse('${dateKey}T00:00:00');
      if (_isSameDate(date, today)) {
        displayDate = 'Hôm nay';
      } else if (_isSameDate(date, yesterday)) {
        displayDate = 'Hôm qua';
      } else {
        displayDate = DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(date);
      }
    } catch (e) {
      // Fallback to original string
      displayDate = dateKey;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today,
            size: 16,
            color: Colors.blue.shade600,
          ),
          const SizedBox(width: 6),
          Text(
            displayDate,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(LichSuBaiThiModel attempt) {
    final isPass = attempt.isPass;
    final scorePercentage = (attempt.totalScore / attempt.maxScore * 100).round();
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [      
        // Content
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with time and status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _extractTime(attempt.thoiGianBatDau),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPass ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isPass ? 'ĐẠT' : 'KHÔNG ĐẠT',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Score section
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isPass ? Colors.green.shade50 : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.stars,
                            size: 16,
                            color: isPass ? Colors.green[600] : Colors.red[600],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${attempt.totalScore.toInt()}/${attempt.maxScore.toInt()}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isPass ? Colors.green[700] : Colors.red[700],
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '($scorePercentage%)',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: isPass ? Colors.green[600] : Colors.red[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Details
                Row(
                  children: [
                    _buildDetailItem(
                      icon: Icons.check_circle,
                      label: '${attempt.totalCorrect} đúng',
                      color: Colors.green.shade600,
                    ),
                    const SizedBox(width: 16),
                    _buildDetailItem(
                      icon: Icons.cancel,
                      label: '${attempt.totalWrong} sai',
                      color: Colors.red.shade600,
                    ),
                    if (attempt.totalUnanswered > 0) ...[
                      const SizedBox(width: 16),
                      _buildDetailItem(
                        icon: Icons.help_outline,
                        label: '${attempt.totalUnanswered} bỏ trống',
                        color: Colors.orange.shade600,
                      ),
                    ],
                  ],
                ),
                
                // Duration
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Thời gian: ${attempt.duration}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem({ required IconData icon, required String label, required Color color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Map<String, List<LichSuBaiThiModel>> _groupByDate(List<LichSuBaiThiModel> items) {
    final map = <String, List<LichSuBaiThiModel>>{};
    
    for (var item in items) {
      final dateKey = _extractDate(item.thoiGianBatDauDate);
      map.putIfAbsent(dateKey, () => []).add(item);
    }
    
    return map;
  }

  String _extractDate(String dateTimeString) {
    try {
      // Nếu có format "18/07/2025"
      if (dateTimeString.contains('/') && !dateTimeString.contains(' - ')) {
        final parts = dateTimeString.split('/');
        if (parts.length == 3) {
          return '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
        }
      }
      
      // Nếu có format "08:00 - 18/07/2025"
      if (dateTimeString.contains(' - ')) {
        final datePart = dateTimeString.split(' - ').last;
        final parts = datePart.split('/');
        if (parts.length == 3) {
          return '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
        }
      }
    
      return dateTimeString.split(' ')[0]; // fallback
    } catch (e) {
      return dateTimeString;
    }
  }

  String _extractTime(String dateTimeString) {
    try {
      // Nếu có format "08:00 - 18/07/2025"
      if (dateTimeString.contains(' - ')) {
        return dateTimeString.split(' - ').first;
      }
      
      // Fallback
      return dateTimeString.split(' ').first;
    } catch (e) {
      return dateTimeString;
    }
  }

  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
          date1.month == date2.month &&
          date1.day == date2.day;
  }

  Widget _buildStatusChip(DeThiModel deThi) {
    final isCompleted = deThi.isPassed;
    final canStart = deThi.isAllowed && !deThi.isPassed;
    
    Color backgroundColor;
    Color textColor;
    String statusText;
    IconData iconData;
    
    if (isCompleted) {
      backgroundColor = Colors.green.shade50;
      textColor = Colors.green.shade700;
      statusText = 'Hoàn thành';
      iconData = Icons.verified;
    } else if (canStart) {
      backgroundColor = Colors.blue.shade50;
      textColor = Colors.blue.shade700;
      statusText = 'Có thể thi';
      iconData = Icons.play_arrow_rounded;
    } else {
      backgroundColor = Colors.orange.shade50;
      textColor = Colors.orange.shade700;
      statusText = 'Đợi lượt tiếp theo';
      iconData = Icons.access_time_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: textColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            color: textColor,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget infoText( String label, String value, { double fontSize = 15, TextStyle? labelStyle, TextStyle? valueStyle, int? maxLines, TextOverflow? overflow}) {
    final baseStyle = DefaultTextStyle.of(context)
        .style
        .copyWith(fontSize: fontSize);

    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: [
          TextSpan(
            text: label,
            style: labelStyle ??
                baseStyle.copyWith(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: value,
            style: valueStyle ?? baseStyle,
          ),
        ],
      ),
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _futureDeThis,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingWidget(context);
        } else if (snapshot.hasError) {
          final errMsg = snapshot.error.toString();
          return _buildEmptyState(context, 'Lỗi tải dữ liệu', errMsg, 
          onRefresh: () {
            setState(() {
              _futureDeThis = _loadDeThis();
            });
          }, isError: true);
        } else if (snapshot.hasData && snapshot.data!.isEmpty) {
          return _buildEmptyState(context, 'Không có đề thi nào', 'Các đề thi sẽ hiển thị tại đây', 
          onRefresh: () {
            setState(() {
              _futureDeThis = _loadDeThis();
            });
          }, isError: false);
        } else {
          var deThis = snapshot.data!;
          return Container(
            color: Colors.white,
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _futureDeThis = _loadDeThis();
                });
                await _futureDeThis;
              },
              child: ListView.builder(
                itemCount: deThis.length,
                itemBuilder: (context, index) {
                  final deThi = deThis[index];
                  // xác định trạng thái hiển thị
                  String statusLabel;
                  Color statusColor;
                  bool canStart = false;
                  // FIX: Thêm kiểm tra null cho nextAvailableTime để an toàn hơn
                  if (deThi.isPassed) {
                    if (deThi.nextAvailableTime != null) {
                      final dtLocal = deThi.nextAvailableTime!.toLocal();
                      statusLabel = 'Lần thi tiếp theo: ${DateFormat("HH:mm dd/MM/yyyy").format(dtLocal)}';
                    } else {
                      statusLabel = 'Đã hoàn thành';
                    }
                    statusColor = Colors.green;
                  } else if (!deThi.isAllowed) {
                    if (deThi.nextAvailableTime != null) {
                      final dtLocal = deThi.nextAvailableTime!.toLocal();
                      statusLabel = 'Lần thi tiếp theo: ${DateFormat("HH:mm dd/MM/yyyy").format(dtLocal)}';
                    } else {
                      statusLabel = 'Chưa đủ điều kiện';
                    }
                    statusColor = Colors.orange;
                  } else {
                    statusLabel = 'Đã sẵn sàng';
                    statusColor = Colors.blue;
                    canStart = true;
                  }
                  return Card(
                    color: Colors.grey.shade50,
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(  // hoặc Flexible
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      WidgetSpan(
                                        alignment: PlaceholderAlignment.middle,
                                        child: Icon(
                                          deThi.isPassed 
                                            ? Icons.check_circle 
                                            : (deThi.isAllowed ? Icons.play_circle_outline : Icons.lock),
                                          color: statusColor,
                                          size: 20,
                                        ),
                                      ),
                                      const WidgetSpan(child: SizedBox(width: 8)),
                                      TextSpan(
                                        text: deThi.tenDeThi,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,  // hiển thị “…” nếu quá dài
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.history),
                                tooltip: 'Xem lịch sử',
                                onPressed: () async {
                                  final lichSuDeThis = await _fetchLichSuTheoDeThi(deThi.id);
                                  if (!mounted) return;
                                  _showLichSuDialog(context, lichSuDeThis);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(children: [
                            const Icon(Icons.tag, size: 18),
                            const SizedBox(width: 6),
                            infoText('Mã đề: ', deThi.maDeThi),
                          ]),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info_outline, size: 18),
                              const SizedBox(width: 6),
                              Expanded(
                                child: infoText(
                                  'Mô tả: ',
                                  deThi.moTa ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 18),
                              const SizedBox(width: 6),
                              infoText('Thời gian: ', '${deThi.duration} phút'),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.description_outlined, size: 18),
                              const SizedBox(width: 6),
                              infoText('Số câu hỏi: ', '${deThi.totalQuestions} câu'),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.star, size: 18),
                              const SizedBox(width: 6),
                              infoText('Yêu cầu đạt: ', '${deThi.diemDat}/${deThi.diemToiDa} điểm'),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // FIX: Cấu trúc lại layout để không bị lỗi render
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Icon(Icons.play_circle_outline, size: 18, color: statusColor),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(statusLabel,
                                          style: TextStyle(
                                              color: statusColor,
                                              fontWeight:
                                                  FontWeight.w600)),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              canStart 
                                ? ElevatedButton(
                                    onPressed: () async { 
                                      final baiThiId = await _createExamSession(deThi.id, _ub!.id);
                                          // FIX: Thêm kiểm tra mounted
                                        if (baiThiId != null && mounted) {
                                          nextScreen(
                                            context, 
                                            LamBaiThiPage(deThiId: deThi.id, userId: _ub!.id, baiThiId: baiThiId)
                                          );
                                        }
                                      },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    ),
                                    child: const Text('Vào thi'),
                                  )
                                : _buildStatusChip(deThi),
                            ],
                          ),
                        ],
                      ),
                    )
                  );
                }
              ),
            ),
          );
        }
      },
    );
  }
}
