import 'package:flutter/material.dart';
import 'dart:math';

class FinanceMainScreen extends StatefulWidget {
  const FinanceMainScreen({super.key});

  @override
  State<FinanceMainScreen> createState() => _FinanceMainScreenState();
}

class _FinanceMainScreenState extends State<FinanceMainScreen>
    with TickerProviderStateMixin {
  late AnimationController _calculatorController;
  late Animation<double> _calculatorAnimation;
  
  final TextEditingController _carPriceController = TextEditingController();
  final TextEditingController _downPaymentController = TextEditingController();
  int _loanPeriod = 60; // months
  double _interestRate = 3.5; // percentage
  
  Map<String, dynamic>? _calculationResult;

  @override
  void initState() {
    super.initState();
    _calculatorController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _calculatorAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _calculatorController, curve: Curves.easeInOut),
    );
    _calculatorController.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التمويل والتقسيط'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 20),
            _buildLoanCalculator(),
            const SizedBox(height: 20),
            if (_calculationResult != null) _buildCalculationResult(),
            if (_calculationResult != null) const SizedBox(height: 20),
            _buildBankPartnerships(),
            const SizedBox(height: 20),
            _buildFinancingOptions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.green[600]!, Colors.green[400]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedBuilder(
                  animation: _calculatorAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _calculatorAnimation.value,
                      child: Icon(Icons.calculate, color: Colors.white, size: 32),
                    );
                  },
                ),
                const SizedBox(width: 12),
                const Text(
                  'حلول التمويل الذكية',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'احسب قسطك الشهري واحصل على أفضل عروض التمويل',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildHeaderStat('معدل الفائدة', '3.5%'),
                const SizedBox(width: 20),
                _buildHeaderStat('البنوك الشريكة', '12'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildLoanCalculator() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calculate, color: Colors.green[600]),
                const SizedBox(width: 8),
                const Text(
                  'حاسبة القرض',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _carPriceController,
              decoration: const InputDecoration(
                labelText: 'سعر السيارة',
                border: OutlineInputBorder(),
                suffixText: 'ريال',
                prefixIcon: Icon(Icons.directions_car),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _downPaymentController,
              decoration: const InputDecoration(
                labelText: 'الدفعة المقدمة',
                border: OutlineInputBorder(),
                suffixText: 'ريال',
                prefixIcon: Icon(Icons.payment),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.schedule, color: Colors.green[600]),
                const SizedBox(width: 8),
                const Text('فترة القرض: '),
                Text(
                  '$_loanPeriod شهر',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Slider(
              value: _loanPeriod.toDouble(),
              min: 12,
              max: 84,
              divisions: 6,
              activeColor: Colors.green[600],
              onChanged: (value) {
                setState(() {
                  _loanPeriod = value.toInt();
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.percent, color: Colors.green[600]),
                const SizedBox(width: 8),
                const Text('معدل الفائدة: '),
                Text(
                  '$_interestRate%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Slider(
              value: _interestRate,
              min: 2.0,
              max: 8.0,
              divisions: 12,
              activeColor: Colors.green[600],
              onChanged: (value) {
                setState(() {
                  _interestRate = double.parse(value.toStringAsFixed(1));
                });
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _calculateLoan,
                icon: const Icon(Icons.calculate),
                label: const Text('احسب القسط الشهري'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationResult() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  'نتيجة الحساب',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green),
              ),
              child: Column(
                children: [
                  Text(
                    '${_calculationResult!['monthlyPayment']} ريال',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const Text(
                    'القسط الشهري',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildResultItem('مبلغ القرض', '${_calculationResult!['loanAmount']} ريال'),
            _buildResultItem('إجمالي الفوائد', '${_calculationResult!['totalInterest']} ريال'),
            _buildResultItem('إجمالي المبلغ المستحق', '${_calculationResult!['totalAmount']} ريال'),
            _buildResultItem('مدة القرض', '${_calculationResult!['loanPeriod']} شهر'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _applyForLoan,
                icon: const Icon(Icons.send),
                label: const Text('تقديم طلب التمويل'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankPartnerships() {
    final banks = [
      {'name': 'البنك الأهلي', 'rate': '3.2%', 'logo': Icons.account_balance, 'color': Colors.blue},
      {'name': 'بنك الراجحي', 'rate': '3.5%', 'logo': Icons.account_balance, 'color': Colors.green},
      {'name': 'بنك سامبا', 'rate': '3.8%', 'logo': Icons.account_balance, 'color': Colors.red},
      {'name': 'البنك السعودي للاستثمار', 'rate': '3.4%', 'logo': Icons.account_balance, 'color': Colors.purple},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'البنوك الشريكة',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
          ),
          itemCount: banks.length,
          itemBuilder: (context, index) {
            final bank = banks[index];
            return Card(
              child: InkWell(
                onTap: () => _selectBank(bank['name'] as String),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (bank['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          bank['logo'] as IconData,
                          size: 32,
                          color: bank['color'] as Color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        bank['name'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: bank['color'] as Color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'من ${bank['rate']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFinancingOptions() {
    final options = [
      {
        'title': 'تمويل تقليدي',
        'desc': 'قرض بفائدة ثابتة',
        'rate': '3.5%',
        'period': '60 شهر',
        'icon': Icons.account_balance,
        'color': Colors.blue,
      },
      {
        'title': 'تمويل إسلامي',
        'desc': 'تمويل متوافق مع الشريعة',
        'rate': '4.2%',
        'period': '72 شهر',
        'icon': Icons.mosque,
        'color': Colors.green,
      },
      {
        'title': 'تأجير منتهي بالتمليك',
        'desc': 'استئجار مع خيار الشراء',
        'rate': '3.8%',
        'period': '48 شهر',
        'icon': Icons.key,
        'color': Colors.orange,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'خيارات التمويل',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...options.map((option) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (option['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                option['icon'] as IconData,
                color: option['color'] as Color,
              ),
            ),
            title: Text(
              option['title'] as String,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(option['desc'] as String),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: option['color'] as Color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        option['rate'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'حتى ${option['period']}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: ElevatedButton(
              onPressed: () => _selectFinancingOption(option['title'] as String),
              style: ElevatedButton.styleFrom(
                backgroundColor: option['color'] as Color,
                minimumSize: const Size(60, 32),
              ),
              child: const Text('اختيار', style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ),
        )),
      ],
    );
  }

  void _calculateLoan() {
    if (_carPriceController.text.isEmpty || _downPaymentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال جميع البيانات المطلوبة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final carPrice = double.parse(_carPriceController.text);
    final downPayment = double.parse(_downPaymentController.text);
    final loanAmount = carPrice - downPayment;
    
    final monthlyRate = _interestRate / 100 / 12;
    final monthlyPayment = loanAmount * 
        (monthlyRate * pow(1 + monthlyRate, _loanPeriod)) / 
        (pow(1 + monthlyRate, _loanPeriod) - 1);
    
    final totalAmount = monthlyPayment * _loanPeriod;
    final totalInterest = totalAmount - loanAmount;

    setState(() {
      _calculationResult = {
        'monthlyPayment': monthlyPayment.toStringAsFixed(0),
        'loanAmount': loanAmount.toStringAsFixed(0),
        'totalInterest': totalInterest.toStringAsFixed(0),
        'totalAmount': totalAmount.toStringAsFixed(0),
        'loanPeriod': _loanPeriod,
      };
    });
  }

  void _applyForLoan() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تقديم طلب التمويل'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.send, size: 64, color: Colors.green[600]),
            const SizedBox(height: 16),
            const Text('سيتم توجيهك لإكمال طلب التمويل'),
            const SizedBox(height: 16),
            const Text('المستندات المطلوبة:'),
            const SizedBox(height: 8),
            const Text('• صورة الهوية الوطنية'),
            const Text('• كشف حساب بنكي'),
            const Text('• إثبات الراتب'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إرسال طلب التمويل بنجاح!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[600]),
            child: const Text('تقديم الطلب', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _selectBank(String bankName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم اختيار $bankName'),
        backgroundColor: Colors.green[600],
      ),
    );
  }

  void _selectFinancingOption(String optionName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم اختيار: $optionName'),
        backgroundColor: Colors.blue[600],
      ),
    );
  }

  @override
  void dispose() {
    _calculatorController.dispose();
    _carPriceController.dispose();
    _downPaymentController.dispose();
    super.dispose();
  }
}
