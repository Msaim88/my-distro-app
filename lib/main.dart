import 'package:flutter/material.dart';

void main() => runApp(DistributionApp());

class DistributionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // فرضی لائیو ڈیٹا (جو لوکل ڈیٹا بیس اور فائر بیس سے سنک ہوگا)
  double totalSales = 250000;
  double totalCostOfGoods = 180000;
  double totalExpenses = 15000;

  @override
  Widget build(BuildContext context) {
    // مجموعی منافع = سیلز - مال کی اصل قیمت
    double grossProfit = totalSales - totalCostOfGoods;
    // خالص منافع = مجموعی منافع - کاروباری خرچے
    double netProfit = grossProfit - totalExpenses;

    return Scaffold(
      appBar: AppBar(
        title: Text('ڈسٹری بیوشن مینجمنٹ ایپ', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          Icon(Icons.cloud_done, color: Colors.greenAccent), // لائیو سنک اسٹیٹس
          SizedBox(width: 15),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // کلاؤڈ سنک کی پٹی
              Card(
                color: Colors.teal[50],
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Icon(Icons.sync, color: Colors.teal),
                      SizedBox(width: 10),
                      Text('ڈیٹا موبائل اور فائر بیس کلاؤڈ پر محفوظ ہے', style: TextStyle(color: Colors.teal[900])),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 15),

              Text('مالیاتی رپورٹ (Profit & Loss Dashboard)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),

              // پرافٹ اینڈ لاس کارڈ
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildReportRow('کل سیل (Total Sales)', 'Rs. $totalSales', Colors.blue),
                      _buildReportRow('مال کی قیمت (Cost of Goods)', 'Rs. $totalCostOfGoods', Colors.orange),
                      Divider(),
                      _buildReportRow('مجموعی منافع (Gross Profit)', 'Rs. $grossProfit', Colors.teal),
                      _buildReportRow('کاروباری خرچے (Total Expenses)', 'Rs. $totalExpenses', Colors.red),
                      Divider(thickness: 2),
                      _buildReportRow(
                        'خالص منافع (Net Profit)', 
                        'Rs. $netProfit', 
                        netProfit >= 0 ? Colors.green : Colors.red,
                        isBold: true
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 25),

              Text('ایپ کے بنیادی سیکشنز', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),

              // مینو گریڈ بٹنز
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildMenuCard(context, 'نیا آرڈر / سیل', Icons.shopping_cart_checkout, Colors.green, () {
                    _showFeatureToast(context, 'نیا آرڈر فارم اور بلنگ اسکرین');
                  }),
                  _buildMenuCard(context, 'اسٹاک مینجمنٹ', Icons.inventory_2, Colors.blue, () {
                    _showFeatureToast(context, 'اسٹاک انٹری (خرید/فروخت ریٹ)');
                  }),
                  _buildMenuCard(context, 'دکانداروں کا کھاتا', Icons.account_balance_wallet, Colors.amber[700]!, () {
                    _showFeatureToast(context, 'ادھار اور کسٹمر لیجر ہسٹری');
                  }),
                  _buildMenuCard(context, 'خرچہ بک کریں', Icons.money_off, Colors.red, () {
                    _showFeatureToast(context, 'پٹرول، کرایہ اور متفرق خرچے');
                  }),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportRow(String title, String value, Color color, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: isBold ? 16 : 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: isBold ? 16 : 14, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, size: 28, color: color),
            ),
            SizedBox(height: 12),
            Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  void _showFeatureToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$message کامیابی سے لوڈ ہو گیا ہے'), duration: Duration(seconds: 2)),
    );
  }
}
