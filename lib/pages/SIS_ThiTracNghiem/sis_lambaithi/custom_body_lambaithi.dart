import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:Thilogi/models/sis/bai_thi.dart';
import 'package:Thilogi/models/sis/cau_hoi_phan_thi_bai_thi.dart';
import 'package:Thilogi/models/sis/lua_chon.dart';
import 'package:Thilogi/pages/SIS_ThiTracNghiem/sis_ds_baithidangdienra/dsbaithidangdienra.dart';
import 'package:Thilogi/services/request_helper_sis.dart';
import 'package:Thilogi/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:sizer/sizer.dart';

// Constants
class ExamConstants {
  static const int defaultDurationSeconds = 900;
  static const Duration timerInterval = Duration(seconds: 1);
  static const Duration navigationAnimationDuration =
      Duration(milliseconds: 300);
  static const double circleAvatarSize = 56.0;
  static const double navigationOffset = 16.0;
}

// Colors
class ExamColors {
  static const Color selectedQuestion = Color(0xFFFF7043);
  static const Color answeredQuestion = Color(0xFFFFB74D);
  static const Color unansweredQuestion = Color(0xFFF5F5F5);
  static const Color submitButton = Colors.red;
  static const Color submitButtonText = Colors.white;
  static const Color questionBackground = Colors.white;
  static const Color questionText = Colors.black;

  static const LinearGradient navigationGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFE96327), Color(0xFFBC2925)],
  );
}

// Exam state management
class ExamState {
  final List<CauHoiPhanThiBaiThiModel> questions;
  final Map<String, String> selectedAnswers;
  final int currentQuestionIndex;
  final int remainingSeconds;

  const ExamState({
    required this.questions,
    required this.selectedAnswers,
    required this.currentQuestionIndex,
    required this.remainingSeconds,
  });

  ExamState copyWith({
    List<CauHoiPhanThiBaiThiModel>? questions,
    Map<String, String>? selectedAnswers,
    int? currentQuestionIndex,
    int? remainingSeconds,
  }) {
    return ExamState(
      questions: questions ?? this.questions,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
    );
  }

  CauHoiPhanThiBaiThiModel get currentQuestion =>
      questions[currentQuestionIndex];
  String? get currentSelectedAnswer => selectedAnswers[currentQuestion.id];
  bool get isLastQuestion => currentQuestionIndex == questions.length - 1;
  bool get isFirstQuestion => currentQuestionIndex == 0;
  int get totalQuestions => questions.length;
}

// Main widget
class CustomBodyLamBaiThi extends StatelessWidget {
  final String deThiId;
  final String userId;
  final String baiThiId;

  const CustomBodyLamBaiThi({
    super.key,
    required this.deThiId,
    required this.userId,
    required this.baiThiId,
  });

  @override
  Widget build(BuildContext context) {
    return ExamScreen(deThiId: deThiId, userId: userId, baiThiId: baiThiId,);
  }
}

// Exam screen with improved state management
class ExamScreen extends StatefulWidget {
  final String deThiId;
  final String userId;
  final String baiThiId;

  const ExamScreen({
    super.key,
    required this.deThiId,
    required this.userId,
    required this.baiThiId,
  });

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  final RequestHelperSIS _requestHelper = RequestHelperSIS();
  late Future<BaiThiModel> _examFuture;

  ExamState _examState = const ExamState(
    questions: [],
    selectedAnswers: {},
    currentQuestionIndex: 0,
    remainingSeconds: ExamConstants.defaultDurationSeconds,
  );

  Timer? _timer;
  
  // PageView controller
  PageController? _pageController;

  @override
  void initState() {
    super.initState();
    _examFuture = _initializeExam();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController?.dispose();
    super.dispose();
  }

  Future<BaiThiModel> _initializeExam() async {
    try {
      final examData = await _loadExamData(widget.baiThiId);

      _setupExamState(examData);
      _startTimer();

      return examData;
    } catch (e) {
      throw Exception('Failed to initialize exam: $e');
    }
  }

  Future<BaiThiModel> _loadExamData(String examId) async {
    final response = await _requestHelper.getData(
      'SIS/BaiThi/$examId/start?userId=${widget.userId}',
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load exam data: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return BaiThiModel.fromJson(decoded);
  }

  void _setupExamState(BaiThiModel exam) {
    final questions = exam.phanThiBaiThis
        .expand((section) => section.cauHoiPhanThiBaiThis)
        .toList();

    final now = DateTime.now();
    final totalSeconds = (exam.duration ?? 15) * 60;
    // đã trôi qua
    final elapsed = now.difference(exam.thoiGianBatDau).inSeconds;
    final remaining = totalSeconds - elapsed;

    setState(() {
      _examState = _examState.copyWith(
        questions: questions,
        remainingSeconds: max(0, remaining),
      );
    });
    _pageController = PageController();

    if (remaining <= 0) {
      // expired ngay khi load → show dialog sau khi UI vẽ
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showExpiredDialog('Bài thi trước đã hết giờ');
      });
    } else {
      // expired sau remaining giây → schedule one-shot
      Timer(Duration(seconds: remaining), () {
        _showExpiredDialog('Hết giờ làm bài');
      });
    } 
  }

  void _startTimer() {
    _timer = Timer.periodic(ExamConstants.timerInterval, (timer) {
      if (_examState.remainingSeconds > 0) {
        setState(() {
          _examState = _examState.copyWith(
            remainingSeconds: _examState.remainingSeconds - 1,
          );
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  void _showExpiredDialog(String text) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.info,
      barrierDismissible: false,
      text: text,
      title: 'Thông báo',
      confirmBtnText: 'Nộp bài',
      onConfirmBtnTap: _submitExam,
    );
  }

  void _selectAnswer(String questionId, String answerId) {
    //Check hết giờ thì show dialog
    if (_examState.remainingSeconds <= 0) {
      _showExpiredDialog('Hết giờ làm bài');
      return;
    }

    // Update state
    setState(() {
      final newAnswers = Map<String, String>.from(_examState.selectedAnswers);
      newAnswers[questionId] = answerId;
      _examState = _examState.copyWith(selectedAnswers: newAnswers);
    });
  }

  void _navigateToQuestion(int index) {
    if (index >= 0 && index < _examState.questions.length && _pageController != null) {
      final int currentIndex = _examState.currentQuestionIndex;
      final int distance = (index - currentIndex).abs();
      
      if (distance > 3)
      {
        _pageController!.jumpToPage(index);
      } else{
        _pageController!.animateToPage(
          index,
          duration: ExamConstants.navigationAnimationDuration,
          curve: Curves.easeInOut,
        );
      }

      // Update state
      setState(() {
        _examState = _examState.copyWith(currentQuestionIndex: index);
      });
    }
  }

  void _onPageChanged(int index) {
    // Update state when page changes (from swipe)
    setState(() {
      _examState = _examState.copyWith(currentQuestionIndex: index);
    });
  }

  void _navigateNext() {
    if (!_examState.isLastQuestion) {
      _navigateToQuestion(_examState.currentQuestionIndex + 1);
    }
  }

  void _navigatePrevious() {
    if (!_examState.isFirstQuestion) {
      _navigateToQuestion(_examState.currentQuestionIndex - 1);
    }
  }

  void _showConfirmationDialog(BuildContext context) {
    // Kiểm tra xem có câu hỏi nào chưa trả lời hay không
    final bool isAllAnswered =
        _examState.questions.length == _examState.selectedAnswers.length;
    final skipped =
        _examState.totalQuestions - _examState.selectedAnswers.length;

    const QuickAlertType alertType = QuickAlertType.confirm;

    final String message = isAllAnswered
        ? 'Bạn có chắc chắn muốn nộp bài không?'
        : 'Bạn còn $skipped câu chưa trả lời. Bạn có chắc chắn muốn nộp bài không?';

    QuickAlert.show(
        context: context,
        type: alertType,
        text: message,
        title: '',
        confirmBtnText: 'Đồng ý',
        cancelBtnText: 'Không',
        confirmBtnTextStyle: const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        cancelBtnTextStyle: const TextStyle(
          color: Colors.red,
          fontSize: 19.0,
          fontWeight: FontWeight.bold,
        ),
        onCancelBtnTap: () {
          Navigator.of(context).pop();
        },
        onConfirmBtnTap: () {
          Navigator.of(context).pop();
          _submitExam();
        });
  }

  // Nộp bài thi
  Future<void> _submitExam() async {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      text: 'Đang nộp bài…',
      barrierDismissible: false,
    );

    // 1. Chuẩn bị danh sách answers
    final answersList = _examState.selectedAnswers.entries.map((entry) {
      return {
        'cauHoiPhanThiBaiThiId': entry.key,
        'loaiCauHoi': 'single_choice',
        'yourAnswer': entry.value,
      };
    }).toList();

    try {
      final results = await Future.wait([
        _requestHelper.postMultipartData('SIS/BaiThi/${widget.baiThiId}/finish',
            {'BaiThiId': widget.baiThiId, 'Answers': jsonEncode(answersList)}),
        Future.delayed(const Duration(seconds: 2)),
      ]);

      final streamedResp = results.first;

      if (streamedResp.statusCode == 200) {
        // Sau tất cả await, kiểm tra mounted
        if (!mounted) return;
        Navigator.of(context).pop(); // close loading
        // thành công
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          barrierDismissible: false,
          text: 'Nộp bài thành công',
          title: '',
          confirmBtnText: 'OK',
          onConfirmBtnTap: () {
            Navigator.of(context).pop();
            int count = 0;
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (_) => const DanhSachBaiThiDangDienRaPage()),
              (route) => count++ == 3, // dừng khi đã pop 1 route → giữ lại route thứ 3
            );
          },
        );
      } else {
        // Sau tất cả await, kiểm tra mounted
        if (!mounted) return;
        Navigator.of(context).pop(); // close loading

        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: 'Nộp bài thất bại (${streamedResp.statusCode})',
          title: '',
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: 'Lỗi khi nộp bài: $e',
        title: '',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // chặn pop mặc định
      onPopInvoked: (didPop) async {
        if (!didPop) {
          if (_examState.questions.isNotEmpty) {
            _showConfirmationDialog(context);
          } else {
            Navigator.of(context).pop();
          }
        }
      },
      child: FutureBuilder<BaiThiModel>(
        future: _examFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingWidget(context);
          }
      
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Lỗi: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      _examFuture = _initializeExam();
                    }),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }
      
          if (!snapshot.hasData || _examState.questions.isEmpty) {
            return const Center(
              child: Text('Không có dữ liệu bài thi.'),
            );
          }

          return Column(
            children: [
              QuestionNavigator(
                examState: _examState,
                onQuestionSelected: _navigateToQuestion,
              ),
              Expanded(
                child: _pageController == null
                    ? const Center(child: CircularProgressIndicator())
                    : PageView.builder(
                        controller: _pageController!,
                        onPageChanged: _onPageChanged,
                        itemCount: _examState.questions.length,
                        itemBuilder: (context, index) {
                          return QuestionView(
                            question: _examState.questions[index],
                            selectedAnswerId: _examState.selectedAnswers[_examState.questions[index].id],
                            onAnswerSelected: (answerId) => _selectAnswer(
                              _examState.questions[index].id,
                              answerId,
                            ),
                          );
                        },
                      ),
              ),
              ExamNavigationControls(
                examState: _examState,
                onNext: _navigateNext,
                onPrevious: _navigatePrevious,
                onSubmit: () => _showConfirmationDialog(context),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Question navigator component
class QuestionNavigator extends StatefulWidget {
  final ExamState examState;
  final Function(int) onQuestionSelected;

  const QuestionNavigator({
    super.key,
    required this.examState,
    required this.onQuestionSelected,
  });

  @override
  State<QuestionNavigator> createState() => _QuestionNavigatorState();
}

class _QuestionNavigatorState extends State<QuestionNavigator> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant QuestionNavigator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.examState.currentQuestionIndex !=
        widget.examState.currentQuestionIndex) {
      _scrollToCurrentQuestion();
    }
  }

  void _scrollToCurrentQuestion() {
    if (_scrollController.hasClients) {
      final offset = (widget.examState.currentQuestionIndex *
              ExamConstants.circleAvatarSize) -
          ExamConstants.navigationOffset;

      _scrollController.animateTo(
        offset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: ExamConstants.navigationAnimationDuration,
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _openGrid() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return GridView.count(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
          crossAxisCount: 5,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: List.generate(widget.examState.totalQuestions, (index) {
            final isSelected = widget.examState.currentQuestionIndex == index;
            final isAnswered = widget.examState.selectedAnswers
                .containsKey(widget.examState.questions[index].id);

            Color backgroundColor;
            if (isSelected) {
              backgroundColor = ExamColors.selectedQuestion;
            } else if (isAnswered) {
              backgroundColor = ExamColors.answeredQuestion;
            } else {
              backgroundColor = ExamColors.unansweredQuestion;
            }

            return GestureDetector(
              onTap: () {
                Navigator.pop(context);
                widget.onQuestionSelected(index);
              },
              child: CircleAvatar(
                backgroundColor: backgroundColor,
                child: Text('${index + 1}'),
              ),
            );
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: ExamColors.navigationGradient),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: List.generate(
                  widget.examState.totalQuestions,
                  (index) => _buildQuestionCircle(index),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.grid_view, color: Colors.white),
            onPressed: _openGrid,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCircle(int index) {
    final isSelected = index == widget.examState.currentQuestionIndex;
    final questionId = widget.examState.questions[index].id;
    final isAnswered =
        widget.examState.selectedAnswers.containsKey(questionId) &&
            widget.examState.selectedAnswers[questionId]!.isNotEmpty;

    Color backgroundColor;
    Color textColor;
    if (isSelected) {
      backgroundColor = ExamColors.selectedQuestion;
      textColor = Colors.white;
    } else if (isAnswered) {
      backgroundColor = ExamColors.answeredQuestion;
      textColor = Colors.white;
    } else {
      backgroundColor = ExamColors.unansweredQuestion;
      textColor = Colors.black;
    }

    return GestureDetector(
      onTap: () => widget.onQuestionSelected(index),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: backgroundColor,
          child: Text(
            '${index + 1}',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

// Question view component
class QuestionView extends StatelessWidget {
  final CauHoiPhanThiBaiThiModel question;
  final String? selectedAnswerId;
  final Function(String) onAnswerSelected;

  const QuestionView({
    super.key,
    required this.question,
    required this.selectedAnswerId,
    required this.onAnswerSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      color: ExamColors.questionBackground,
      //Chỉ padding left and right
      padding: EdgeInsets.symmetric(horizontal: 10.sp),
      // padding: EdgeInsets.all(10.sp),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Text(
            //   'Câu hỏi ${question.thuTu} (${question.} điểm)',
            //   style: const TextStyle(
            //     fontSize: 16,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Câu hỏi ${question.thuTu}: ',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // đảm bảo đặt màu cho TextSpan gốc
                    ),
                  ),
                  TextSpan(
                    text: '(${question.diemPhanBo} điểm)',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              question.noiDung,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            AnswerChoices(
              question: question,
              selectedAnswerId: selectedAnswerId,
              onAnswerSelected: onAnswerSelected,
            ),
          ],
        ),
      ),
    );
  }
}

// Answer choices component
class AnswerChoices extends StatelessWidget {
  final CauHoiPhanThiBaiThiModel question;
  final String? selectedAnswerId;
  final Function(String) onAnswerSelected;

  const AnswerChoices({
    super.key,
    required this.question,
    required this.selectedAnswerId,
    required this.onAnswerSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: question.luaChons
          .asMap()
          .entries
          .map((entry) => _buildAnswerChoice(entry.value, entry.key))
          .toList(),
    );
  }

  Widget _buildAnswerChoice(LuaChonModel answer, int index) {
    final isSelected = answer.id == selectedAnswerId;
    final backgroundColor = isSelected
        ? ExamColors.selectedQuestion.withOpacity(0.3)
        : ExamColors.unansweredQuestion;

    return GestureDetector(
      onTap: () => onAnswerSelected(answer.id),
      child: Container(
        width: 100.w,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(
            color:
                isSelected ? ExamColors.selectedQuestion : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          '${_getAnswerLabel(index)}. ${answer.noiDung}',
          style: const TextStyle(
            fontSize: 16,
            color: ExamColors.questionText,
          ),
        ),
      ),
    );
  }

  String _getAnswerLabel(int index) {
    return String.fromCharCode(65 + index); // A, B, C, D...
  }
}

// Navigation controls component
class ExamNavigationControls extends StatelessWidget {
  final ExamState examState;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onSubmit;

  const ExamNavigationControls({
    super.key,
    required this.examState,
    required this.onNext,
    required this.onPrevious,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 1,
          ),
        ]
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildPreviousButton(),
          _buildTimer(),
          _buildNextButton(),
        ],
      ),
    );
  }

  Widget _buildPreviousButton() {
    return examState.isFirstQuestion
        ? const SizedBox(width: 100)
        : ElevatedButton(
            onPressed: onPrevious,
            child: const Text('<< Trước'),
          );
  }

  Widget _buildTimer() {
    return Text(
      '⏰ ${_formatTime(examState.remainingSeconds)}',
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildNextButton() {
    return ElevatedButton(
      onPressed: examState.isLastQuestion ? onSubmit : onNext,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            examState.isLastQuestion ? ExamColors.submitButton : null,
        foregroundColor:
            examState.isLastQuestion ? ExamColors.submitButtonText : null,
      ),
      child: Text(examState.isLastQuestion ? 'Nộp bài' : 'Tiếp >>'),
    );
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }
}