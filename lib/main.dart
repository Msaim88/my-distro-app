import 'package:flutter/material.dart';

void main() {
  runApp(DistributionApp());
}

class DistributionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[200],
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
  // ڈائنامک ڈیٹا لسٹیں
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

  // حساب کتاب کے فنکشنز
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

              // لائیو ڈیش بورڈ کارڈ
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
              SizedBox(height: 25),

              Text('ایپ کے سیکشنز', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),

              // گریڈ ویو مینو
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildMenuCard(context, 'نیا آرڈر / سیل', Icons.shopping_cart_checkout, Colors.green, () => _openOrderSheet()),
                  _buildMenuCard(context, 'اسٹاک مینجمنٹ', Icons.inventory_2, Colors.blue, () => _openStockSheet()),
                  _buildMenuCard(context, 'دکانداروں کا کھاتا', Icons.account_balance_wallet, Colors.amber, () => _openCustomerSheet()),
                  _buildMenuCard(context, 'خرچہ بک کریں', Icons.money_off, Colors.red, () => _openExpenseSheet()),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // ---- فارم پاپ اپ فنکشنز ----
  void _openStockSheet() {
    String name = ''; double purchase = 0; double sale = 0; int stock = 0;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('نیا پروڈکٹ شامل کریں', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(decoration: InputDecoration(labelText: 'پروڈکٹ کا نام'), onChanged: (v) => name = v),
            TextField(decoration: InputDecoration(labelText: 'خریداری ریٹ'), keyboardType: TextInputType.number, onChanged: (v) => purchase = double.tryParse(v) ?? 0),
            TextField(decoration: InputDecoration(labelText: 'فروخت ریٹ'), keyboardType: TextInputType.number, onChanged: (v) => sale = double.tryParse(v) ?? 0),
            TextField(decoration: InputDecoration(labelText: 'اسٹاک تعداد'), keyboardType: TextInputType.number, onChanged: (v) => stock = int.tryParse(v) ?? 0),
            SizedBox(height: 15),
            ElevatedButton(
              child: Text('سیو کریں'),
              onPressed: () {
                if (name.isNotEmpty) {
                  setState(() {
                    products.add({"name": name, "purchase": purchase, "sale": sale, "stock": stock});
                  });
                  Navigator.pop(context);
                }
              },
            ),
            SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  void _openOrderSheet() {
    if (products.isEmpty || customers.isEmpty) return;
    Map<String, dynamic> selectedProduct = products.first;
    Map<String, dynamic> selectedCustomer = customers.first;
    int qty = 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('نیا آرڈر بک کریں', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButtonFormField<Map<String, dynamic>>(
              value: selectedCustomer,
              items: customers.map((c) => DropdownMenuItem<Map<String, dynamic>>(child: Text(c['name']), value: c)).toList(),
              onChanged: (v) => setState(() { if (v != null) selectedCustomer = v; }),
              decoration: InputDecoration(labelText: 'دکاندار چنیں'),
            ),
            DropdownButtonFormField<Map<String, dynamic>>(
              value: selectedProduct,
              items: products.map((p) => DropdownMenuItem<Map<String, dynamic>>(child: Text(p['name']), value: p)).toList(),
              onChanged: (v) => setState(() { if (v != null) selectedProduct = v; }),
              decoration: InputDecoration(labelText: 'پروڈکٹ چنیں'),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'تعداد (Quantity)'),
              keyboardType: TextInputType.number,
              onChanged: (v) => qty = int.tryParse(v) ?? 1,
            ),
            SizedBox(height: 15),
            ElevatedButton(
              child: Text('آرڈر فائنل کریں'),
              onPressed: () {
                setState(() {
                  orders.add({
                    "customer": selectedCustomer['name'],
                    "product": selectedProduct['name'],
                    "qty": qty,
                    "purchase_price": selectedProduct['purchase'],
                    "sale_price": selectedProduct['sale']
                  });
                  selectedProduct['stock'] = selectedProduct['stock'] - qty;
                });
                Navigator.pop(context);
              },
            ),
            SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  void _openCustomerSheet() {
    String name = ''; String phone = ''; double udhaar = 0;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('نیا دکاندار شامل کریں', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(decoration: InputDecoration(labelText: 'دکان / دکاندار کا نام'), onChanged: (v) => name = v),
            TextField(decoration: InputDecoration(labelText: 'فون نمبر'), keyboardType: TextInputType.phone, onChanged: (v) => phone = v),
            TextField(decoration: InputDecoration(labelText: 'سابقہ ادھار (اگر ہے)'), keyboardType: TextInputType.number, onChanged: (v) => udhaar = double.tryParse(v) ?? 0),
            SizedBox(height: 15),
            ElevatedButton(
              child: Text('کھاتا کھولیں'),
              onPressed: () {
                if (name.isNotEmpty) {
                  setState(() {
                    customers.add({"name": name, "phone": phone, "udhaar": udhaar});
                  });
                  Navigator.pop(context);
                }
              },
            ),
            SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  void _openExpenseSheet() {
