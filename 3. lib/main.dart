import 'package:flutter/material.dart';

void main() => runApp(DistributionApp());

class DistributionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey,
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
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> customers = [];
  List<Map<String, dynamic>> expenses = [];
  List<Map<String, dynamic>> orders = [];

  double get totalSales => orders.fold(0, (sum, item) => sum + (item['sale_price'] * item['qty']));
  double get totalCostOfGoods => orders.fold(0, (sum, item) => sum + (item['purchase_price'] * item['qty']));
  double get totalExpenses => expenses.fold(0, (sum, item) => sum + item['amount']);

  @override
  Widget build(BuildContext context) {
    double grossProfit = totalSales - totalCostOfGoods;
    double netProfit = grossProfit - totalExpenses;

    return Scaffold(
      appBar: AppBar(
        title: Text('ڈسٹری بیوشن پرو مینجمنٹ', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildReportRow('کل سیل (Sales)', 'Rs. $totalSales', Colors.blue),
                      _buildReportRow('مال کی لاگت (Cost)', 'Rs. $totalCostOfGoods', Colors.orange),
                      Divider(),
                      _buildReportRow('مجموعی منافع (Gross)', 'Rs. $grossProfit', Colors.teal),
                      _buildReportRow('کل خرچے (Expenses)', 'Rs. $totalExpenses', Colors.red),
                      Divider(thickness: 2),
                      _buildReportRow('خالص منافع (Net Profit)', 'Rs. $netProfit', Colors.green, isBold: true),
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
                  _buildMenuCard(context, 'نیا آرڈر / انوائس', Icons.receipt_long, Colors.green, _openOrderForm),
                  _buildMenuCard(context, 'انوینٹری / اسٹاک', Icons.inventory, Colors.blue, _viewInventorySheet),
                  _buildMenuCard(context, 'دکانداروں کا کھاتا', Icons.account_balance_wallet, Colors.amber!, _viewCustomersSheet),
                  _buildMenuCard(context, 'خرچہ بک کریں', Icons.money_off, Colors.red, _viewExpensesSheet),
                  _buildMenuCard(context, 'پرانے آرڈرز ہسٹری', Icons.history, Colors.purple, _viewOrdersHistorySheet),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _viewCustomersSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('دکانداروں کی لسٹ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Container(
                height: 200,
                child: customers.isEmpty 
                  ? Center(child: Text('کوئی دکاندار موجود نہیں ہے'))
                  : ListView.builder(
                      itemCount: customers.length,
                      itemBuilder: (context, i) => ListTile(
                        title: Text(customers[i]['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('فون: ${customers[i]['phone']} | ادھار: Rs.${customers[i]['udhaar']}'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () { setState(() { customers.removeAt(i); }); setModalState(() {}); },
                        ),
                      ),
                    ),
              ),
              Divider(),
              ElevatedButton.icon(
                icon: Icon(Icons.person_add),
                label: Text('نیا دکاندار شامل کریں'),
                onPressed: () => _showAddCustomerDialog(setModalState),
              ),
              SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddCustomerDialog(Function setModalState) {
    String name = ''; String phone = ''; double udhaar = 0;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('نیا دکاندار شامل کریں'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: InputDecoration(labelText: 'دکان کا نام'), onChanged: (v) => name = v),
            TextField(decoration: InputDecoration(labelText: 'فون نمبر'), keyboardType: TextInputType.phone, onChanged: (v) => phone = v),
            TextField(decoration: InputDecoration(labelText: 'سابقہ ادھار'), keyboardType: TextInputType.number, onChanged: (v) => udhaar = double.tryParse(v) ?? 0),
          ],
        ),
        actions: [
          ElevatedButton(
            child: Text('سیو کریں'),
            onPressed: () {
              if (name.isNotEmpty) {
                setState(() { customers.add({"name": name, "phone": phone, "udhaar": udhaar}); });
                setModalState(() {});
                Navigator.pop(context);
              }
            },
          )
        ],
      ),
    );
  }

  void _viewInventorySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('گودام اسٹاک رپورٹ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Container(
                height: 200,
                child: products.isEmpty 
                  ? Center(child: Text('اسٹاک بالکل خالی ہے'))
                  : ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, i) => ListTile(
                        title: Text(products[i]['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('خرید: Rs.${products[i]['purchase']} | سیل: Rs.${products[i]['sale']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('اسٹاک: ${products[i]['stock']}', style: TextStyle(fontWeight: FontWeight.bold)),
                            IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () { setState(() { products.removeAt(i); }); setModalState(() {}); }),
                          ],
                        ),
                      ),
                    ),
              ),
              Divider(),
              ElevatedButton.icon(
                icon: Icon(Icons.add_box),
                label: Text('نیا مال درج کریں'),
                onPressed: () => _showAddProductDialog(setModalState),
              ),
              SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddProductDialog(Function setModalState) {
    String name = ''; double purchase = 0; double sale = 0; int stock = 0;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('پروڈکٹ اسٹاک انٹری'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: InputDecoration(labelText: 'پروڈکٹ کا نام'), onChanged: (v) => name = v),
            TextField(decoration: InputDecoration(labelText: 'خریداری ریٹ'), keyboardType: TextInputType.number, onChanged: (v) => purchase = double.tryParse(v) ?? 0),
            TextField(decoration: InputDecoration(labelText: 'فروخت ریٹ'), keyboardType: TextInputType.number, onChanged: (v) => sale = double.tryParse(v) ?? 0),
            TextField(decoration: InputDecoration(labelText: 'ٹوٹل کوانٹٹی'), keyboardType: TextInputType.number, onChanged: (v) => stock = int.tryParse(v) ?? 0),
          ],
        ),
        actions: [
          ElevatedButton(
            child: Text('سیو کریں'),
            onPressed: () {
              if (name.isNotEmpty) {
                setState(() { products.add({"name": name, "purchase": purchase, "sale": sale, "stock": stock}); });
                setModalState(() {});
                Navigator.pop(context);
              }
            },
          )
        ],
      ),
    );
  }

  void _openOrderForm() {
    if (products.isEmpty || customers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('براہ کرم پہلے اسٹاک اور دکاندار شامل کریں!')));
      return;
    }
