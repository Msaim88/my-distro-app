DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // ڈائنامک ڈیٹا لسٹیں (موبائل میموری میں ڈیٹا سیو رکھنے کے لیے)
  List<Map<String, dynamic>> products = [
    {"name": "کریانہ آئٹم اے", "purchase": 100.0, "sale": 130.0, "stock": 50},
    {"name": "صابن باکس", "purchase": 500.0, "sale": 600.0, "stock": 20},
  ];

  List<Map<String, dynamic>> customers = [
    {"name": "المدینہ اسٹور", "phone": "03001234567", "udhaar": 5000.0},
    {"name": "بسم اللہ جنرل اسٹور", "phone": "03217654321", "udhaar": 0.0},
  ];

  List<Map<String, dynamic>> expenses = [
    {"desc": "بائیک پٹرول", "amount": 500.0, "category": "ٹرانسپورٹ"},
  ];

  List<Map<String, dynamic>> orders = [];

  // فائنل حساب کتاب کرنے کے فنکشنز
  double get totalSales {
    return orders.fold(0, (sum, item) => sum + (item['sale_price'] * item['qty']));
  }

  double get totalCostOfGoods {
    return orders.fold(0, (sum, item) => sum + (item['purchase_price'] * item['qty']));
  }

  double get totalExpenses {
    return expenses.fold(0, (sum, item) => sum + item['amount']);
  }

  @override
  Widget build(BuildContext context) {
    double grossProfit = totalSales - totalCostOfGoods;
    double netProfit = grossProfit - totalExpenses;

    return Scaffold(
      appBar: AppBar(
        title: Text('ڈسٹری بیوشن مینجمنٹ', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('مالیاتی رپورٹ (Live Dashboard)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),

              // پرافٹ اینڈ لاس لائیو کارڈ
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
                      _buildReportRow('کل خرچے (Total Expenses)', 'Rs. $totalExpenses', Colors.red),
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

  void _openExpenseSheet() {
