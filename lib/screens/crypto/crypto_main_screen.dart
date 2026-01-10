import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

class CryptoMainScreen extends StatefulWidget {
  const CryptoMainScreen({super.key});

  @override
  State<CryptoMainScreen> createState() => _CryptoMainScreenState();
}

class _CryptoMainScreenState extends State<CryptoMainScreen>
    with TickerProviderStateMixin {
  late AnimationController _coinController;
  late Animation<double> _coinAnimation;
  Timer? _priceTimer;

  double _walletBalance = 15420.50;

  List<Map<String, dynamic>> _cryptoPrices = [
    {
      'name': 'Bitcoin',
      'symbol': 'BTC',
      'price': 43250.00,
      'change': 2.5,
      'icon': '₿'
    },
    {
      'name': 'Ethereum',
      'symbol': 'ETH',
      'price': 2680.00,
      'change': -1.2,
      'icon': 'Ξ'
    },
    {
      'name': 'Cardano',
      'symbol': 'ADA',
      'price': 0.45,
      'change': 5.8,
      'icon': '₳'
    },
    {
      'name': 'Solana',
      'symbol': 'SOL',
      'price': 98.50,
      'change': 3.2,
      'icon': '◎'
    },
  ];

  @override
  void initState() {
    super.initState();
    _coinController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _coinAnimation =
        Tween<double>(begin: 0, end: 2 * pi).animate(_coinController);
    _coinController.repeat();
    _startPriceUpdates();
  }

  void _startPriceUpdates() {
    _priceTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          final random = Random();
          for (var crypto in _cryptoPrices) {
            final changePercent = (random.nextDouble() - 0.5) * 10;
            crypto['change'] = changePercent;
            crypto['price'] = crypto['price'] * (1 + changePercent / 100);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('العملات الرقمية'),
        backgroundColor: Colors.amber[600],
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _coinAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _coinAnimation.value,
                      child: Icon(Icons.monetization_on,
                          color: Colors.yellow[300]),
                    );
                  },
                ),
                const SizedBox(width: 4),
                Text('${_walletBalance.toStringAsFixed(2)} ريال',
                    style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWalletCard(),
            const SizedBox(height: 20),
            _buildCryptoPrices(),
            const SizedBox(height: 20),
            _buildTradingFeatures(),
            const SizedBox(height: 20),
            _buildTransactionHistory(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showBuySellDialog,
        backgroundColor: Colors.amber[600],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildWalletCard() {
    return Card(
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.amber[600]!, Colors.amber[400]!],
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
                  animation: _coinAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _coinAnimation.value * 0.5,
                      child: Icon(Icons.account_balance_wallet,
                          color: Colors.white, size: 32),
                    );
                  },
                ),
                const SizedBox(width: 12),
                const Text(
                  'محفظة العملات الرقمية',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${_walletBalance.toStringAsFixed(2)} ريال سعودي',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'الرصيد الإجمالي',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildWalletStat('الأرباح اليوم', '+245.50 ريال', Colors.green),
                const SizedBox(width: 20),
                _buildWalletStat('العملات المملوكة', '4', Colors.white70),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
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

  Widget _buildCryptoPrices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'أسعار العملات المباشرة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'مباشر',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...(_cryptoPrices.map((crypto) => _buildCryptoItem(crypto))),
      ],
    );
  }

  Widget _buildCryptoItem(Map<String, dynamic> crypto) {
    final isPositive = crypto['change'] >= 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.amber.withOpacity(0.1),
          child: Text(
            crypto['icon'],
            style: TextStyle(
              color: Colors.amber[600],
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          crypto['name'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(crypto['symbol']),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${crypto['price'].toStringAsFixed(2)} ريال',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isPositive ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${isPositive ? '+' : ''}${crypto['change'].toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        onTap: () => _showCryptoDetails(crypto),
      ),
    );
  }

  Widget _buildTradingFeatures() {
    final features = [
      {
        'title': 'شراء فوري',
        'icon': Icons.shopping_cart,
        'color': Colors.green
      },
      {'title': 'بيع فوري', 'icon': Icons.sell, 'color': Colors.red},
      {'title': 'تداول متقدم', 'icon': Icons.trending_up, 'color': Colors.blue},
      {'title': 'محفظة آمنة', 'icon': Icons.security, 'color': Colors.purple},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'خدمات التداول',
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
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
            return Card(
              child: InkWell(
                onTap: () => _onFeatureTap(feature['title'] as String),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (feature['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          feature['icon'] as IconData,
                          size: 32,
                          color: feature['color'] as Color,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        feature['title'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
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

  Widget _buildTransactionHistory() {
    final transactions = [
      {
        'type': 'شراء',
        'crypto': 'BTC',
        'amount': '0.025',
        'value': '1,250 ريال',
        'time': 'منذ ساعة',
        'color': Colors.green
      },
      {
        'type': 'بيع',
        'crypto': 'ETH',
        'amount': '1.5',
        'value': '4,020 ريال',
        'time': 'منذ 3 ساعات',
        'color': Colors.red
      },
      {
        'type': 'شراء',
        'crypto': 'ADA',
        'amount': '1000',
        'value': '450 ريال',
        'time': 'أمس',
        'color': Colors.green
      },
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: Colors.amber[600]),
                const SizedBox(width: 8),
                const Text(
                  'سجل المعاملات',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...transactions
                .map((transaction) => _buildTransactionItem(transaction)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (transaction['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              transaction['type'] == 'شراء'
                  ? Icons.arrow_downward
                  : Icons.arrow_upward,
              color: transaction['color'] as Color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${transaction['type']} ${transaction['crypto']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${transaction['amount']} ${transaction['crypto']} • ${transaction['value']}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            transaction['time'] as String,
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _showBuySellDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('شراء/بيع العملات الرقمية'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.monetization_on, size: 64, color: Colors.amber[600]),
            const SizedBox(height: 16),
            const Text('اختر العملة والكمية التي تريد تداولها'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showTradeDialog('شراء');
                    },
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text('شراء'),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showTradeDialog('بيع');
                    },
                    icon: const Icon(Icons.sell),
                    label: const Text('بيع'),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  void _showTradeDialog(String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$type العملة الرقمية'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'اختر العملة',
                border: OutlineInputBorder(),
              ),
              items: _cryptoPrices
                  .map((crypto) => DropdownMenuItem<String>(
                        value: crypto['symbol'],
                        child: Text('${crypto['name']} (${crypto['symbol']})'),
                      ))
                  .toList(),
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'الكمية',
                border: OutlineInputBorder(),
                suffixText: 'BTC',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'القيمة بالريال',
                border: OutlineInputBorder(),
                suffixText: 'ريال',
              ),
              keyboardType: TextInputType.number,
            ),
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
                SnackBar(
                  content: Text('تم $type العملة بنجاح!'),
                  backgroundColor: type == 'شراء' ? Colors.green : Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: type == 'شراء' ? Colors.green : Colors.red,
            ),
            child: Text(type, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCryptoDetails(Map<String, dynamic> crypto) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(crypto['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              crypto['icon'],
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 16),
            Text(
              '${crypto['price'].toStringAsFixed(2)} ريال',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: crypto['change'] >= 0 ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${crypto['change'] >= 0 ? '+' : ''}${crypto['change'].toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showTradeDialog('شراء');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[600]),
            child: const Text('تداول', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _onFeatureTap(String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تفعيل: $featureName'),
        backgroundColor: Colors.amber[600],
      ),
    );
  }

  @override
  void dispose() {
    _coinController.dispose();
    _priceTimer?.cancel();
    super.dispose();
  }
}
