import 'package:flutter/material.dart';
import '../../services/voice_ai_service.dart';
import '../../models/voice_ai_model.dart';

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({Key? key}) : super(key: key);

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen>
    with TickerProviderStateMixin {
  final VoiceAIService _voiceService = VoiceAIService();
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;

  bool _isInitialized = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  String _currentText = '';
  List<VoiceInteraction> _interactions = [];
  VoiceAIAssistant? _assistant;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeVoiceService();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  Future<void> _initializeVoiceService() async {
    try {
      await _voiceService.initializeAssistant(
        language: 'ar',
        voiceType: VoiceType.femaleArabic,
      );
      setState(() {
        _isInitialized = true;
      });
      _showWelcomeMessage();
    } catch (e) {
      _showErrorSnackBar('فشل في تهيئة المساعد الصوتي: $e');
    }
  }

  void _showWelcomeMessage() {
    setState(() {
      _currentText = 'مرحباً! أنا سارة، مساعدتك الصوتية في تشليحكم. كيف يمكنني مساعدتك اليوم؟';
    });
  }

  Future<void> _startListening() async {
    if (!_isInitialized || _isListening) return;

    try {
      final success = await _voiceService.startListening();
      if (success) {
        setState(() {
          _isListening = true;
          _currentText = 'أستمع إليك الآن... تحدث من فضلك';
        });
        _waveController.repeat();
      }
    } catch (e) {
      _showErrorSnackBar('فشل في بدء الاستماع: $e');
    }
  }

  Future<void> _stopListening() async {
    if (!_isListening) return;

    try {
      final recognizedText = await _voiceService.stopListening();
      _waveController.stop();
      
      setState(() {
        _isListening = false;
        _currentText = 'جاري المعالجة...';
      });

      if (recognizedText != null && recognizedText.isNotEmpty) {
        await _processVoiceCommand(recognizedText);
      } else {
        setState(() {
          _currentText = 'لم أتمكن من فهم ما قلته. حاول مرة أخرى.';
        });
      }
    } catch (e) {
      _showErrorSnackBar('فشل في معالجة الصوت: $e');
      setState(() {
        _isListening = false;
        _currentText = 'حدث خطأ في معالجة الصوت';
      });
    }
  }

  Future<void> _processVoiceCommand(String command) async {
    try {
      final interaction = await _voiceService.processVoiceCommand(command);
      
      setState(() {
        _interactions.insert(0, interaction);
        _currentText = interaction.assistantResponse;
      });

      // تحويل النص إلى كلام
      await _speakResponse(interaction.assistantResponse);
    } catch (e) {
      _showErrorSnackBar('فشل في معالجة الأمر: $e');
    }
  }

  Future<void> _speakResponse(String text) async {
    setState(() {
      _isSpeaking = true;
    });

    try {
      await _voiceService.textToSpeech(text);
    } catch (e) {
      _showErrorSnackBar('فشل في تحويل النص إلى كلام: $e');
    } finally {
      setState(() {
        _isSpeaking = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المساعد الصوتي'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_voice),
            onPressed: _showVoiceSettings,
          ),
        ],
      ),
      body: Column(
        children: [
          // منطقة المساعد الصوتي
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.purple.shade100,
                    Colors.purple.shade50,
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // أفاتار المساعد
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isListening ? _pulseAnimation.value : 1.0,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.purple.shade300,
                                Colors.purple.shade600,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purple.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isListening
                                ? Icons.mic
                                : _isSpeaking
                                    ? Icons.volume_up
                                    : Icons.psychology,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  // اسم المساعد
                  Text(
                    'سارة - مساعدتك الذكية',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.purple.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // حالة المساعد
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _isInitialized ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _isInitialized
                          ? _isListening
                              ? 'أستمع...'
                              : _isSpeaking
                                  ? 'أتحدث...'
                                  : 'جاهزة للمساعدة'
                          : 'جاري التهيئة...',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // منطقة النص
          Container(
            padding: const EdgeInsets.all(20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                _currentText.isEmpty ? 'اضغط على الميكروفون للبدء' : _currentText,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          // أزرار التحكم
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // زر الميكروفون
                GestureDetector(
                  onTapDown: (_) => _startListening(),
                  onTapUp: (_) => _stopListening(),
                  onTapCancel: () => _stopListening(),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isListening ? Colors.red : Colors.purple,
                      boxShadow: [
                        BoxShadow(
                          color: (_isListening ? Colors.red : Colors.purple)
                              .withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
                
                // زر التاريخ
                IconButton(
                  onPressed: _showInteractionHistory,
                  icon: const Icon(Icons.history),
                  iconSize: 30,
                  color: Colors.purple,
                ),
                
                // زر المساعدة
                IconButton(
                  onPressed: _showHelpDialog,
                  icon: const Icon(Icons.help_outline),
                  iconSize: 30,
                  color: Colors.purple,
                ),
              ],
            ),
          ),
          
          // تاريخ التفاعلات (مختصر)
          if (_interactions.isNotEmpty)
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView.builder(
                  itemCount: _interactions.length.clamp(0, 3),
                  itemBuilder: (context, index) {
                    final interaction = _interactions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.purple.shade300,
                        ),
                        title: Text(
                          interaction.userInput,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(interaction.assistantResponse),
                        trailing: Text(
                          '${interaction.timestamp.hour}:${interaction.timestamp.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showVoiceSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'إعدادات الصوت',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('اللغة'),
              subtitle: const Text('العربية'),
              onTap: () {
                // تغيير اللغة
              },
            ),
            ListTile(
              leading: const Icon(Icons.record_voice_over),
              title: const Text('نوع الصوت'),
              subtitle: const Text('صوت أنثوي عربي'),
              onTap: () {
                // تغيير نوع الصوت
              },
            ),
            ListTile(
              leading: const Icon(Icons.speed),
              title: const Text('سرعة الكلام'),
              subtitle: const Text('عادية'),
              onTap: () {
                // تغيير سرعة الكلام
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showInteractionHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('تاريخ المحادثات'),
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _interactions.length,
            itemBuilder: (context, index) {
              final interaction = _interactions[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            color: Colors.blue.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              interaction.userInput,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.psychology,
                            color: Colors.purple.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(interaction.assistantResponse),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${interaction.timestamp.day}/${interaction.timestamp.month} - ${interaction.timestamp.hour}:${interaction.timestamp.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('كيفية الاستخدام'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'يمكنك استخدام الأوامر التالية:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text('• "ابحث عن تويوتا كامري"'),
              Text('• "اعرض السيارات في الرياض"'),
              Text('• "فلتر السيارات أقل من 100 ألف"'),
              Text('• "احسب تمويل سيارة بـ 80 ألف"'),
              Text('• "اتصل بالبائع"'),
              Text('• "احفظ هذه السيارة"'),
              Text('• "قارن بين السيارات"'),
              Text('• "مساعدة"'),
              SizedBox(height: 10),
              Text(
                'اضغط مع الاستمرار على زر الميكروفون وتحدث بوضوح.',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('فهمت'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _voiceService.dispose();
    super.dispose();
  }
}
