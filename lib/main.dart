import 'package:flutter/material.dart';

void main() => runApp(DistributionApp());

class DistributionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal, scaffoldBackgroundColor: Colors.grey[200]),
      home: DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> products = [
    {"name": "کریانہ آئٹم اے", "purchase": 100.0, "sale": 130.0, "stock": 50},
    {"name": "صابن باکس", "purchase": 500.0, "sale": 600.0, "stock": 20},
  ];

  List<Map<String, dynamic>> customers = [
    {"name": "المدینہ اسٹور", "phone": "03001234567", "udhaar": 5000.0},
    {"name": "بسم اللہ جنرل اسٹور", "phone": "03217654321", "udhaar": 0.0},
  ];

  List<Map<String, dynamic>> expenses = [
    {"desc": "بائیک پٹرول", "amount": 500.0},
  ];

  List<Map<String, dynamic>> orders = [];

  double get totalSales => orders.fold(0, (sum, item) => sum + (item['sale_price'] * item['qty']));
  double get totalCostOfGoods => orders.fold(0, (sum, item) => sum + (item['purchase_price'] * item['qty']));
  double get totalExpenses => expenses.fold(0, (sum, item) => sum + item['amount']);

  @override
  Widget build(BuildContext context) {
    double grossProfit = totalSales - totalCostOfGoods;
    double netProfit = grossProfit - totalExpenses;

    return Scaffold(
      appBar: AppBar(title: Text('ڈسٹری بیوشن مینجمنٹ'), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _row('کل سیل (Sales)', 'Rs. $totalSales', Colors.blue),
                      _row('مال کی لاگت (Cost)', 'Rs. $totalCostOfGoods', Colors.orange),
                      Divider(),
                      _row('مجموعی منافع (Gross)', 'Rs. $grossProfit', Colors.teal),
                      _row('کل خرچے (Expenses)', 'Rs. $totalExpenses', Colors.red),
                      Divider(thickness: 2),
                      _row('خالص منافع (Net Profit)', 'Rs. $netProfit', Colors.green, isBold: true),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _btn('نیا آرڈر / سیل', Icons.shopping_cart, Colors.green, _openOrder),
                  _btn('اسٹاک مینجمنٹ', Icons.inventory, Colors.blue, _openStock),
                  _btn('دکانداروں کا کھاتا', Icons.account_balance_wallet, Colors.amber, _openCustomer),
                  _btn('خرچہ بک کریں', Icons.money_off, Colors.red, _openExpense),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _openStock() {
    String name = ''; double purchase = 0; double sale = 0; int stock = 0;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('نیا پروڈکٹ شامل کریں'),
            TextField(decoration: InputDecoration(labelText: 'پروڈکٹ کا نام'), onChanged: (v) => name = v),
            TextField(decoration: InputDecoration(labelText: 'خریداری ریٹ'), keyboardType: TextInputType.number, onChanged: (v) => purchase = double.tryParse(v) ?? 0),
            TextField(decoration: InputDecoration(labelText: 'فروخت ریٹ'), keyboardType: TextInputType.number, onChanged: (v) => sale = double.tryParse(v) ?? 0),
            TextField(decoration: InputDecoration(labelText: 'اسٹاک تعداد'), keyboardType: TextInputType.number, onChanged: (v) => stock = int.tryParse(v) ?? 0),
            ElevatedButton(child: Text('سیو کریں'), onPressed: () {
              if (name.isNotEmpty) {
                setState(() { products.add({"name": name, "purchase": purchase, "sale": sale, "stock": stock}); });
                Navigator.pop(context);
              }
            }),
          ],
        ),
      ),
    );
  }

  void _openOrder() {
    if (products.isEmpty || customers.isEmpty) return;
    Map<String, dynamic> selP = products.first;
    Map<String, dynamic> selC = customers.first;
    int qty = 1;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('نیا آرڈر بک کریں'),
            DropdownButtonFormField<Map<String, dynamic>>(value: selC, items: customers.map((c) => DropdownMenuItem(child: Text(c['name']), value: c)).toList(), onChanged: (v) => setState(() { if (v != null) selC = v; })),
            DropdownButtonFormField<Map<String, dynamic>>(value: selP, items: products.map((p) => DropdownMenuItem(child: Text(p['name']), value: p)).toList(), onChanged: (v) => setState(() { if (v != null) selP = v; })),
            TextField(decoration: InputDecoration(labelText: 'تعداد'), keyboardType: TextInputType.number, onChanged: (v) => qty = int.tryParse(v) ?? 1),
            ElevatedButton(child: Text('آرڈر فائنل کریں'), onPressed: () {
              setState(() {
                orders.add({"customer": selC['name'], "product": selP['name'], "qty": qty, "purchase_price": selP['purchase'], "sale_price": selP['sale']});
                selP['stock'] = selP['stock'] - qty;
              });
              Navigator.pop(context);
            }),
          ],
        ),
      ),
    );
  }

  void _openCustomer() {
    String name = ''; String phone = ''; double udhaar = 0;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('نیا دکاندار شامل کریں'),
            TextField(decoration: InputDecoration(labelText: 'دکان کا نام'), onChanged: (v) => name = v),
            TextField(decoration: InputDecoration(labelText: 'فون نمبر'), keyboardType: TextInputType.phone, onChanged: (v) => phone = v),
            TextField(decoration: InputDecoration(labelText: 'سابقہ ادھار'), keyboardType: TextInputType.number, onChanged: (v) => udhaar = double.tryParse(v) ?? 0),
            ElevatedButton(child: Text('کھاتا کھولیں'), onPressed: () {
              if (name.isNotEmpty) {
                setState(() { customers.add({"name": name, "phone": phone, "udhaar": udhaar}); });
                Navigator.pop(context);
              }
            }),
          ],
        ),
      ),
    );
  }

  void _openExpense() {
    String desc = ''; double amount = 0;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('کاروباری خرچہ درج کریں'),
            TextField(decoration: InputDecoration(labelText: 'تفصیل'), onChanged: (v) => desc = v),
            TextField(decoration: InputDecoration(labelText: 'رقم'), keyboardType: TextInputType.number, onChanged: (v) => amount = double.tryParse(v) ?? 0),
            ElevatedButton(child: Text('خرچہ ریکارڈ کریں'), onPressed: () {
              if (amount > 0) {
                setState(() { expenses.add({"desc": desc, "amount": amount}); });
                Navigator.pop(context);
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _row(String t, String v, Color c, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(t, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(v, style: TextStyle(fontWeight: FontWeight.bold, color: c)),
        ],
      ),
    );
  }

  Widget _btn(String t, IconData icon, Color c, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: c),
            SizedBox(height: 8),
            Text(t, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
