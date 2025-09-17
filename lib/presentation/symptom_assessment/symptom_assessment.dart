import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/body_part_selector_widget.dart';
import './widgets/camera_capture_widget.dart';
import './widgets/multiple_choice_widget.dart';
import './widgets/navigation_buttons_widget.dart';
import './widgets/progress_indicator_widget.dart';
import './widgets/question_card_widget.dart';
import './widgets/severity_scale_widget.dart';
import './widgets/text_input_widget.dart';
import './widgets/voice_input_widget.dart';
import './widgets/yes_no_toggle_widget.dart';

class SymptomAssessment extends StatefulWidget {
  const SymptomAssessment({Key? key}) : super(key: key);

  @override
  State<SymptomAssessment> createState() => _SymptomAssessmentState();
}

class _SymptomAssessmentState extends State<SymptomAssessment> {
  int _currentQuestionIndex = 0;
  bool _isLoading = false;
  Map<String, dynamic> _answers = {};
  final TextEditingController _textController = TextEditingController();

  // Mock assessment questions data
  final List<Map<String, dynamic>> _assessmentQuestions = [
    {
      "id": "primary_symptom",
      "type": "multiple_choice",
      "question": "What is your primary symptom?",
      "description": "Select the symptom that bothers you the most",
      "options": [
        "Headache",
        "Fever",
        "Nausea",
        "Chest pain",
        "Shortness of breath",
        "Abdominal pain",
        "Fatigue",
        "Other"
      ],
      "required": true,
      "showIllustration": true,
      "illustrationUrl":
          "https://images.unsplash.com/photo-1559757148-5c350d0d3c56?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3"
    },
    {
      "id": "symptom_severity",
      "type": "severity_scale",
      "question": "How severe is your symptom?",
      "description":
          "Rate the intensity of your primary symptom on a scale from 1 to 10",
      "required": true,
      "minLabel": "Mild",
      "maxLabel": "Severe"
    },
    {
      "id": "symptom_duration",
      "type": "multiple_choice",
      "question": "How long have you been experiencing this symptom?",
      "options": [
        "Less than 1 hour",
        "1-6 hours",
        "6-24 hours",
        "1-3 days",
        "3-7 days",
        "More than 1 week",
        "More than 1 month"
      ],
      "required": true
    },
    {
      "id": "affected_areas",
      "type": "body_part_selector",
      "question": "Which parts of your body are affected?",
      "description": "Tap on the body diagram to select all affected areas",
      "required": false,
      "showIllustration": true
    },
    {
      "id": "fever_check",
      "type": "yes_no",
      "question": "Do you have a fever?",
      "description": "Body temperature above 100.4°F (38°C)",
      "required": true
    },
    {
      "id": "additional_symptoms",
      "type": "multiple_choice",
      "question": "Are you experiencing any additional symptoms?",
      "description": "Select all that apply",
      "options": [
        "Dizziness",
        "Vomiting",
        "Difficulty breathing",
        "Chest tightness",
        "Rapid heartbeat",
        "Sweating",
        "Confusion",
        "None of the above"
      ],
      "multiSelect": true,
      "required": false
    },
    {
      "id": "symptom_description",
      "type": "text_input",
      "question": "Please describe your symptoms in detail",
      "description":
          "Include any additional information that might help with diagnosis",
      "placeholder":
          "Describe when the symptoms started, what makes them better or worse, and any other relevant details...",
      "required": false
    },
    {
      "id": "voice_description",
      "type": "voice_input",
      "question": "Would you like to add a voice description?",
      "description":
          "Use voice input to provide additional details about your symptoms",
      "required": false
    },
    {
      "id": "symptom_photo",
      "type": "camera_capture",
      "question": "Do you have any visible symptoms to photograph?",
      "description":
          "Take a photo if you have rashes, swelling, or other visible symptoms",
      "required": false
    }
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Map<String, dynamic> get _currentQuestion =>
      _assessmentQuestions[_currentQuestionIndex];

  bool get _canGoNext {
    final question = _currentQuestion;
    final questionId = question["id"] as String;
    final isRequired = question["required"] as bool? ?? false;

    if (!isRequired) return true;

    return _answers.containsKey(questionId) && _answers[questionId] != null;
  }

  bool get _canGoBack => _currentQuestionIndex > 0;

  bool get _canSkip {
    final question = _currentQuestion;
    return !(question["required"] as bool? ?? false);
  }

  String get _nextButtonText {
    if (_currentQuestionIndex == _assessmentQuestions.length - 1) {
      return 'Complete Assessment';
    }
    return 'Next';
  }

  void _handleAnswer(String questionId, dynamic answer) {
    setState(() {
      _answers[questionId] = answer;
    });
  }

  void _handleMultiSelectAnswer(String questionId, String option) {
    setState(() {
      if (!_answers.containsKey(questionId)) {
        _answers[questionId] = <String>[];
      }

      final List<String> selectedOptions =
          List<String>.from(_answers[questionId] as List);

      if (selectedOptions.contains(option)) {
        selectedOptions.remove(option);
      } else {
        selectedOptions.add(option);
      }

      _answers[questionId] = selectedOptions;
    });
  }

  void _goToPrevious() {
    if (_canGoBack) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _goToNext() async {
    if (_currentQuestionIndex == _assessmentQuestions.length - 1) {
      await _completeAssessment();
    } else {
      setState(() {
        _isLoading = true;
      });

      // Simulate AI processing
      await Future.delayed(const Duration(milliseconds: 800));

      setState(() {
        _currentQuestionIndex++;
        _isLoading = false;
      });
    }
  }

  void _skipQuestion() {
    if (_canSkip) {
      _goToNext();
    }
  }

  Future<void> _completeAssessment() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate AI analysis
    await Future.delayed(const Duration(seconds: 2));

    // Navigate to results or dashboard
    if (mounted) {
      _showAssessmentResults();
    }
  }

  void _showAssessmentResults() {
    // Mock analysis results
    final urgencyLevel = _calculateUrgencyLevel();
    final recommendations = _generateRecommendations(urgencyLevel);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                color: _getUrgencyColor(urgencyLevel),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: _getUrgencyIcon(urgencyLevel),
                  color: Colors.white,
                  size: 4.w,
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                'Assessment Complete',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.textPrimaryLight,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: _getUrgencyColor(urgencyLevel).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getUrgencyColor(urgencyLevel),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Urgency Level: ${urgencyLevel.toUpperCase()}',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: _getUrgencyColor(urgencyLevel),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    _getUrgencyDescription(urgencyLevel),
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textPrimaryLight,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Recommendations:',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.textPrimaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            ...recommendations
                .map((rec) => Padding(
                      padding: EdgeInsets.only(bottom: 0.5.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ',
                              style:
                                  TextStyle(color: AppTheme.textPrimaryLight)),
                          Expanded(
                            child: Text(
                              rec,
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: AppTheme.textPrimaryLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ],
        ),
        actions: [
          if (urgencyLevel == 'high') ...[
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to emergency services
              },
              icon: CustomIconWidget(
                iconName: 'local_hospital',
                color: Colors.white,
                size: 4.w,
              ),
              label: const Text('Emergency Services'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorLight,
              ),
            ),
          ],
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, '/dashboard');
            },
            child: const Text('Back to Dashboard'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/telemedicine-consultation');
            },
            child: const Text('Book Consultation'),
          ),
        ],
      ),
    );
  }

  String _calculateUrgencyLevel() {
    final severity = _answers["symptom_severity"] as double? ?? 0.0;
    final hasFever = _answers["fever_check"] as bool? ?? false;
    final primarySymptom = _answers["primary_symptom"] as String? ?? "";
    final additionalSymptoms =
        _answers["additional_symptoms"] as List<String>? ?? [];

    // High urgency conditions
    if (severity > 0.8 ||
        primarySymptom == "Chest pain" ||
        primarySymptom == "Shortness of breath" ||
        additionalSymptoms.contains("Difficulty breathing") ||
        additionalSymptoms.contains("Chest tightness")) {
      return "high";
    }

    // Medium urgency conditions
    if (severity > 0.5 ||
        hasFever ||
        additionalSymptoms.contains("Rapid heartbeat") ||
        additionalSymptoms.contains("Confusion")) {
      return "medium";
    }

    return "low";
  }

  List<String> _generateRecommendations(String urgencyLevel) {
    switch (urgencyLevel) {
      case "high":
        return [
          "Seek immediate medical attention",
          "Consider calling emergency services (911)",
          "Do not drive yourself to the hospital",
          "Have someone stay with you until help arrives"
        ];
      case "medium":
        return [
          "Schedule an appointment with your doctor within 24-48 hours",
          "Monitor your symptoms closely",
          "Consider telemedicine consultation",
          "Rest and stay hydrated"
        ];
      default:
        return [
          "Monitor symptoms for any changes",
          "Consider over-the-counter remedies if appropriate",
          "Schedule a routine check-up if symptoms persist",
          "Maintain good self-care practices"
        ];
    }
  }

  Color _getUrgencyColor(String urgencyLevel) {
    switch (urgencyLevel) {
      case "high":
        return AppTheme.errorLight;
      case "medium":
        return AppTheme.warningLight;
      default:
        return AppTheme.successLight;
    }
  }

  String _getUrgencyIcon(String urgencyLevel) {
    switch (urgencyLevel) {
      case "high":
        return "warning";
      case "medium":
        return "info";
      default:
        return "check_circle";
    }
  }

  String _getUrgencyDescription(String urgencyLevel) {
    switch (urgencyLevel) {
      case "high":
        return "Your symptoms require immediate medical attention.";
      case "medium":
        return "Your symptoms should be evaluated by a healthcare professional soon.";
      default:
        return "Your symptoms appear to be manageable with self-care.";
    }
  }

  Future<bool> _onWillPop() async {
    if (_currentQuestionIndex > 0) {
      return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                'Exit Assessment?',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.textPrimaryLight,
                ),
              ),
              content: Text(
                'Your progress will be saved, but you\'ll need to restart the assessment later.',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimaryLight,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Continue Assessment'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Exit'),
                ),
              ],
            ),
          ) ??
          false;
    }
    return true;
  }

  Widget _buildQuestionWidget() {
    final question = _currentQuestion;
    final questionType = question["type"] as String;
    final questionId = question["id"] as String;

    switch (questionType) {
      case "multiple_choice":
        final isMultiSelect = question["multiSelect"] as bool? ?? false;
        if (isMultiSelect) {
          return MultipleChoiceWidget(
            options: List<String>.from(question["options"] as List),
            selectedOption: null,
            onOptionSelected: (option) =>
                _handleMultiSelectAnswer(questionId, option),
          );
        } else {
          return MultipleChoiceWidget(
            options: List<String>.from(question["options"] as List),
            selectedOption: _answers[questionId] as String?,
            onOptionSelected: (option) => _handleAnswer(questionId, option),
          );
        }

      case "severity_scale":
        return SeverityScaleWidget(
          value: _answers[questionId] as double? ?? 0.1,
          onChanged: (value) => _handleAnswer(questionId, value),
          minLabel: question["minLabel"] as String? ?? "Mild",
          maxLabel: question["maxLabel"] as String? ?? "Severe",
        );

      case "body_part_selector":
        return BodyPartSelectorWidget(
          selectedParts: List<String>.from(_answers[questionId] as List? ?? []),
          onPartToggled: (part) {
            final currentParts =
                List<String>.from(_answers[questionId] as List? ?? []);
            if (currentParts.contains(part)) {
              currentParts.remove(part);
            } else {
              currentParts.add(part);
            }
            _handleAnswer(questionId, currentParts);
          },
        );

      case "yes_no":
        return YesNoToggleWidget(
          value: _answers[questionId] as bool?,
          onChanged: (value) => _handleAnswer(questionId, value),
        );

      case "text_input":
        return TextInputWidget(
          controller: _textController,
          hintText:
              question["placeholder"] as String? ?? "Enter your response...",
          onChanged: (value) => _handleAnswer(questionId, value),
        );

      case "voice_input":
        return VoiceInputWidget(
          onTranscriptionComplete: (transcription) {
            _handleAnswer(questionId, transcription);
            _textController.text = transcription;
          },
          isEnabled: true,
        );

      case "camera_capture":
        return CameraCaptureWidget(
          onImageCaptured: (image) => _handleAnswer(questionId, image.path),
          isEnabled: true,
        );

      default:
        return Container(
          padding: EdgeInsets.all(4.w),
          child: Text(
            'Question type not supported',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.errorLight,
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        body: Column(
          children: [
            // Progress indicator
            ProgressIndicatorWidget(
              currentStep: _currentQuestionIndex + 1,
              totalSteps: _assessmentQuestions.length,
              stepTitle: "Symptom Assessment",
            ),

            // Question content
            Expanded(
              child: SingleChildScrollView(
                child: QuestionCardWidget(
                  question: _currentQuestion["question"] as String,
                  description: _currentQuestion["description"] as String?,
                  showMedicalIllustration:
                      _currentQuestion["showIllustration"] as bool? ?? false,
                  illustrationUrl:
                      _currentQuestion["illustrationUrl"] as String?,
                  child: _buildQuestionWidget(),
                ),
              ),
            ),

            // Navigation buttons
            NavigationButtonsWidget(
              onPrevious: _canGoBack ? _goToPrevious : null,
              onNext: _canGoNext ? _goToNext : null,
              onSkip: _canSkip ? _skipQuestion : null,
              canGoBack: _canGoBack,
              canGoNext: _canGoNext,
              canSkip: _canSkip,
              isLoading: _isLoading,
              nextButtonText: _nextButtonText,
            ),
          ],
        ),
      ),
    );
  }
}
