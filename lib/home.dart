// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sqldb.dart';
import 'navdrawer.dart';
import 'constants.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  SqlDb sqlDb = SqlDb();
  List<Map> productList = [];
  List<Map> salesList = [];
  bool _validate = false;
  Color tableHeaderColor = Constants.tableHeaderColor;
  Color tableHeaderTitleColor = Constants.white;
  Color deleteButtonColor = Constants.red;
  Color shadowColor = Constants.grey;
  Color editButtonColor = Constants.blue;
  double tableContentFontSize = Constants.tableContentFontSize;
  double tableTitleFontSize = Constants.tableTitleFontSize;
  String pickedDateValue = DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();
  @override
  void initState() {
    super.initState();
    _initializeData();
  }
  Future<void> _initializeData() async {
    await _loadUserInfo();
    fetchProductList();
    fetchSalesList();
  }
  int? _projectId;
  Future<void> _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _projectId = prefs.getInt('project_id');
    });
  }
  void fetchProductList() async {
    List<Map> response = await sqlDb.readData('''
        SELECT * FROM 'products' 
        WHERE locked <> 1 
        AND display_quantity > 0 
        AND project_id = $_projectId
        ORDER BY id DESC 
        ''');
    setState(() {
      productList = response;
    });
  }

  void fetchSalesList() async {
    List<Map> response = await sqlDb.readData('''
    SELECT sales.id as id, products.name as name, sales.sold_price, products.id as product_id
    FROM sales
    INNER JOIN products ON sales.product_id = products.id
    WHERE sales.project_id = $_projectId
    AND products.project_id = $_projectId
    AND DATE(sales.created_at) = '$pickedDateValue'
    ORDER BY sales.id DESC
    ''');
    setState(() {
      salesList = response;
    });
  }

  Future<void> storeSale(id, price, date) async {
    int response = await sqlDb.insertData(
        "INSERT INTO 'sales' ('product_id','project_id','sold_price',created_at) VALUES ('$id','$_projectId','$price','$date')");
    if (response > 0) {
      fetchSalesList();
      fetchProductList();
    }
  }

  void delete(id) async {
    int response = await sqlDb.deleteData("DELETE FROM sales WHERE id = $id");
    if (response > 0) {
      fetchSalesList();
    }
  }

  void update(id, price) async {
    int response = await sqlDb.updateData("UPDATE sales SET sold_price = '$price' WHERE id = $id");
    if (response > 0) {
      fetchSalesList();
    }
  }
  void updateProductQuantity(int id, bool increase) async {
    String operator = increase ? '+' : '-'; // Use + for increase, - for decrease
    int response = await sqlDb.updateData("UPDATE products SET display_quantity = display_quantity $operator 1 WHERE id = $id");
    if (response > 0) {
      fetchSalesList();
    }
  }


  _displayDialog(BuildContext context, $id, $Price) async {
    TextEditingController salePriceController =
        TextEditingController(text: $Price);

    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            Widget backButton = TextButton(
              child: Text("cancel".tr().toString()),
              onPressed: () {
                Navigator.of(context).pop();
              },
            );
            Widget confirmButton = TextButton(
              child: Text("ok".tr().toString()),
              onPressed: () {
                if (salePriceController.text.isEmpty) {
                  setState(() {
                    _validate = true;
                  });
                } else {
                  update($id, salePriceController.text);
                  Navigator.of(context).pop();
                }
              },
            );
            return AlertDialog(
              title: Text("update_selling_price".tr().toString()),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: salePriceController,
                      decoration: InputDecoration(
                        hintText: "enter_selling_price".tr().toString(),
                        errorText: _validate
                            ? "can_not_be_empty".tr().toString()
                            : null,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              actions: [
                backButton,
                confirmButton,
              ],
            );
          });
        });
  }

  _displayDeleteDialog(BuildContext context, $saleRow) async {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            TextEditingController text =
                TextEditingController(); // Create a new TextEditingController
            Widget backButton = TextButton(
              child: Text("cancel".tr().toString()),
              onPressed: () {
                Navigator.of(context).pop();
              },
            );
            Widget confirmButton = TextButton(
                child: Text("ok".tr().toString()),
                onPressed: () {
                  if (text.text == 'sure'.tr().toString()) {
                    delete($saleRow['id']);
                    updateProductQuantity($saleRow['product_id'],true);
                    Navigator.of(context).pop();
                  } else if (text.text != 'sure'.tr().toString()) {
                    setState(() {
                      _validate = true;
                    });
                  }
                });
            return AlertDialog(
              title: Text('delete_Sold_item'.tr().toString()),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: text,
                      decoration: InputDecoration(
                        hintText: "enter_sure".tr().toString(),
                        errorText: _validate
                            ? "please_write_sure".tr().toString()
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                backButton,
                confirmButton,
              ],
            );
          });
        });
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != DateTime.now()) {
      // Do something with the selected date
      setState(() {
        pickedDateValue = pickedDate.toString().substring(0,10);
        fetchSalesList();
      });
    }
  }
  bool isProcessing = false;

  void handleButtonPress(int productId, String price) async {
    if (isProcessing) return; // Prevent duplicate presses while processing
    setState(() {
      isProcessing = true; // Disable buttons during processing
    });
    await storeSale(productId, price, pickedDateValue);
    updateProductQuantity(productId,false);
    setState(() {
      isProcessing = false; // Re-enable buttons after processing
    });
  }
  @override
  Widget build(BuildContext context) {
    List<Widget> buttons = [];
    for (var product in productList) {
      buttons.add(ElevatedButton(
        onPressed: isProcessing ? null : () async {
          handleButtonPress(product['id'], product['salePrice'].toString());
        },
        child: Text(product['name'].toString()),
      ));
    }
    /*List<Widget> rows = [];
    for (var i = 0; i < buttons.length; i++) {
      List<Widget> rowChildren = [];

        rowChildren.add(buttons[i]);

      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: rowChildren,
      ));
    }*/
    return Scaffold(
      drawer: const NavDrawer(),
      appBar: AppBar(
        title: Text("home".tr().toString()),
        actions: [
          TextButton(
            onPressed: () {
              _selectDate(context);
            },
            child: Text(
              pickedDateValue,
              style: TextStyle(
                  fontSize: tableTitleFontSize,
                  fontWeight: FontWeight.bold,
                  color: tableHeaderTitleColor
              ),
            ),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8.0, // Adjust the spacing between buttons as needed
            alignment: WrapAlignment.spaceEvenly, // Align buttons to the start of each line
            children: buttons,
          ),
          const SizedBox(height: 16.0),
          salesList.isEmpty?  Expanded(
            child: Card(
                color: tableHeaderTitleColor,
                shadowColor: shadowColor,
                elevation: 2,
                child: DataTable(
                  headingRowColor: MaterialStateColor.resolveWith(
                          (states) => tableHeaderColor),
                  columns: [
                    DataColumn(
                        label: Text(
                          "name".tr().toString(),
                          style: TextStyle(
                              fontSize: tableTitleFontSize,
                              fontWeight: FontWeight.bold,
                              color: tableHeaderTitleColor),
                        )),
                    DataColumn(
                        label: Text(
                          "selling_price".tr().toString(),
                          style: TextStyle(
                              fontSize: tableTitleFontSize,
                              fontWeight: FontWeight.bold,
                              color: tableHeaderTitleColor),
                        )),
                    DataColumn(
                        label: Text(
                          'action'.tr().toString(),
                          style: TextStyle(
                              fontSize: tableTitleFontSize,
                              fontWeight: FontWeight.bold,
                              color: tableHeaderTitleColor),
                        )),
                  ],
                  rows: const [],
                )),
          ) :
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Card(
                    color: tableHeaderTitleColor,
                    shadowColor: shadowColor,
                    elevation: 2,
                    child: DataTable(
                      headingRowColor: MaterialStateColor.resolveWith(
                          (states) => tableHeaderColor),
                      columns: [
                        DataColumn(
                            label: Text(
                          "name".tr().toString(),
                          style: TextStyle(
                              fontSize: tableTitleFontSize,
                              fontWeight: FontWeight.bold,
                              color: tableHeaderTitleColor),
                        )),
                        DataColumn(
                            label: Text(
                          "selling_price".tr().toString(),
                          style: TextStyle(
                              fontSize: tableTitleFontSize,
                              fontWeight: FontWeight.bold,
                              color: tableHeaderTitleColor),
                        )),
                        DataColumn(
                            label: Text(
                          'action'.tr().toString(),
                          style: TextStyle(
                              fontSize: tableTitleFontSize,
                              fontWeight: FontWeight.bold,
                              color: tableHeaderTitleColor),
                        )),
                      ],
                      rows: [
                        for (var sale in salesList)
                          DataRow(cells: [
                            DataCell(Text(
                              sale['name'].toString(),
                              style: TextStyle(fontSize: tableContentFontSize),
                              textAlign: TextAlign.center,
                            )),
                            DataCell(Text(
                              sale['sold_price'].toString(),
                              style: TextStyle(fontSize: tableContentFontSize),
                              textAlign: TextAlign.center,
                            )),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      _validate = false;
                                      _displayDeleteDialog(context, sale);
                                    },
                                    icon: const Icon(Icons.delete),
                                    color: deleteButtonColor,
                                  ),
                                  const VerticalDivider(
                                    thickness: 0.7,
                                    color: Colors.grey,
                                    indent: 10,
                                    endIndent: 10,
                                    width: 5,
                                  ),
                                  IconButton(
                                    alignment: Alignment.centerLeft,
                                    onPressed: () async {
                                      _validate = false;
                                      _displayDialog(context, sale['id'],
                                          sale['sold_price'].toString());
                                    },
                                    icon: const Icon(Icons.edit),
                                    color: editButtonColor,
                                  ),
                                ],
                              ),
                            ),
                          ]),
                      ],
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
