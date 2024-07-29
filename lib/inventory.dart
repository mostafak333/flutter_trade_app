// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';
import 'sqldb.dart';

class Inventory extends StatefulWidget {
  const Inventory({super.key});

  @override
  _InventoryState createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  SqlDb sqlDb = SqlDb();
  List<Map> productList = [];
  bool _inventoryQuantityValidate = false;
  bool _increaseShopQuantityValidate = false;
  Color tableHeaderColor = Constants.tableHeaderColor;
  Color tableHeaderTitleColor = Constants.white;
  Color addIconColor = Constants.green;
  Color editButtonColor = Constants.blue;
  double tableContentFontSize = Constants.tableContentFontSize;
  double tableTitleFontSize = Constants.tableTitleFontSize;

  static const double paddingSize = Constants.padding;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadUserInfo();
    fetchProductList();
  }

  int? _projectId;
  Future<void> _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _projectId = prefs.getInt('project_id');
    });
  }
  void fetchProductList() async {
    List<Map> response =
    await sqlDb.readData("SELECT * FROM 'products' WHERE project_id = $_projectId ORDER BY id DESC ");
    setState(() {
      productList = response;
    });
  }

  void updateInventoryQuantity(id, quantity) async {
    int response = await sqlDb.updateData('''
        UPDATE products 
        SET inventory_quantity = $quantity
        WHERE id = $id
        ''');
    if (response > 0) {
      fetchProductList();
    }
  }

  void updateDisplayQuantity(id, quantity) async {
    int response = await sqlDb.updateData('''
        UPDATE products 
        SET 
          inventory_quantity = inventory_quantity - $quantity,   
          display_quantity = display_quantity + $quantity
        WHERE id = $id
        ''');
    if (response > 0) {
      fetchProductList();
    }
  }

  _displayDialog(BuildContext context, $id, $quantity, $flag) async {
    TextEditingController quantityController = TextEditingController();
    TextEditingController inventoryQuantityController = TextEditingController(text: $quantity);
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
                if (quantityController.text.isEmpty) {
                    setState(() {
                    _inventoryQuantityValidate =
                    quantityController.text.isEmpty;
                    });
                   }
                  if ($flag == 'inventory') {
                    updateInventoryQuantity($id, inventoryQuantityController.text);
                    Navigator.of(context).pop();
                  } else {
                    int enteredQuantity =
                        int.tryParse(quantityController.text) ?? 0;
                    int existsQuantity = int.tryParse($quantity) ?? 0;
                    if (enteredQuantity > existsQuantity) {
                      setState(() {
                        _increaseShopQuantityValidate = true;
                      });
                    } else {
                      updateDisplayQuantity($id, quantityController.text);
                      Navigator.of(context).pop();
                    }
                  }
                },
            );
            return AlertDialog(
              title: $flag == 'inventory'
                  ? Text("increase_inventory_quantity".tr().toString())
                  : Text("increase_display_quantity".tr().toString()),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: $flag == 'inventory'? inventoryQuantityController :quantityController,
                      decoration: InputDecoration(
                        hintText: "enter_quantity".tr().toString(),
                        errorText: _inventoryQuantityValidate
                            ? "can_not_be_empty".tr().toString()
                            : _increaseShopQuantityValidate
                                ? "invalid_quantity".tr().toString()
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
              title: Text("inventory".tr().toString()),
              leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/', (route) => false);
                  })),
          body:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Card(
                      margin: const EdgeInsets.all(paddingSize),
                      color: tableHeaderTitleColor,
                      shadowColor: Colors.grey,
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
                            "inventory_quantity".tr().toString(),
                            style: TextStyle(
                                fontSize: tableTitleFontSize,
                                fontWeight: FontWeight.bold,
                                color: tableHeaderTitleColor),
                          )),
                          DataColumn(
                              label: Text(
                            "action".tr().toString(),
                            style: TextStyle(
                                fontSize: tableTitleFontSize,
                                fontWeight: FontWeight.bold,
                                color: tableHeaderTitleColor),
                          )),
                        ],
                        rows: [
                          for (var product in productList)
                            DataRow(cells: [
                              DataCell(Text(
                                product['name'].toString(),
                                textAlign: TextAlign.center,
                                style:
                                    TextStyle(fontSize: tableContentFontSize),
                              )),
                              DataCell(Text(
                                product['inventory_quantity'].toString(),
                                textAlign: TextAlign.center,
                                style:
                                    TextStyle(fontSize: tableContentFontSize),
                              )),
                              DataCell(
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      onPressed: () async {
                                        _inventoryQuantityValidate = false;
                                        _increaseShopQuantityValidate = false;
                                        _displayDialog(
                                            context,
                                            product['id'],
                                            product['inventory_quantity']
                                                .toString(),
                                            "inventory");
                                      },
                                      icon: const Icon(Icons.add),
                                      color: addIconColor,
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
                                        _inventoryQuantityValidate = false;
                                        _increaseShopQuantityValidate = false;
                                        _displayDialog(
                                            context,
                                            product['id'],
                                            product['inventory_quantity']
                                                .toString(),
                                            "shop");
                                      },
                                      icon: const Icon(Icons.forward),
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
          ]),
        ));
  }
}
