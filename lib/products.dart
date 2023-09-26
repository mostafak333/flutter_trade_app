// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'constants.dart';
import 'sqldb.dart';

class Products extends StatefulWidget {
  const Products({super.key});

  @override
  _ProductsState createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  SqlDb sqlDb = SqlDb();
  List<Map> productList = [];
  bool _nameValidate = false;
  bool _wholesalePriceValidate = false;
  bool _salePriceValidate = false;
  bool _deleteValidate = false;
  Color tableHeaderColor = Constants.tableHeaderColor;
  Color tableHeaderTitleColor = Constants.white;
  double tableContentFontSize = Constants.tableContentFontSize;
  double tableTitleFontSize = Constants.tableTitleFontSize;
  static const double paddingSize = Constants.padding;

  @override
  void initState() {
    super.initState();
    fetchProductList();
  }

  void fetchProductList() async {
    List<Map> response =
        await sqlDb.readData("SELECT * FROM 'products' ORDER BY id DESC ");
    setState(() {
      productList = response;
    });
  }

  void delete(id) async {
    int response =
        await sqlDb.deleteData("DELETE FROM Products WHERE id = $id");
    if (response > 0) {
      fetchProductList();
    }
  }

  void store(name, wholesalePrice, salePrice) async {
    int response = await sqlDb.insertData('''
    INSERT INTO 'products' ('name','wholesalePrice','salePrice') 
    VALUES ('$name','$wholesalePrice',$salePrice)
    ''');
    if (response > 0) {
      fetchProductList();
    }
  }

  void update(id, name, wholesalePrice, salePrice, locked) async {
    int response = await sqlDb.updateData('''
        UPDATE products 
        SET name = '$name',
        wholesalePrice = $wholesalePrice,
        salePrice = $salePrice,
        locked = $locked 
        WHERE id = $id
        ''');
    if (response > 0) {
      fetchProductList();
    }
  }

  _displayDialog(BuildContext context, $id, $name, $wholesalePrice, $salePrice,
      $flag) async {
    TextEditingController productNameController =
        TextEditingController(text: $name);
    TextEditingController wholesalePriceController =
        TextEditingController(text: $wholesalePrice);
    TextEditingController salePriceController =
        TextEditingController(text: $salePrice);

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
                if (productNameController.text.isEmpty ||
                    wholesalePriceController.text.isEmpty ||
                    salePriceController.text.isEmpty) {
                  setState(() {
                    _nameValidate = productNameController.text.isEmpty;
                    _wholesalePriceValidate =
                        wholesalePriceController.text.isEmpty;
                    _salePriceValidate = salePriceController.text.isEmpty;
                  });
                } else {
                  if ($flag == 'store') {
                    store(
                        productNameController.text.toString(),
                        wholesalePriceController.text,
                        salePriceController.text);
                  } else {
                    update(
                        $id,
                        productNameController.text.toString(),
                        wholesalePriceController.text,
                        salePriceController.text,
                        0);
                  }
                  Navigator.of(context).pop();
                }
              },
            );
            return AlertDialog(
              title: $flag == 'store'
                  ? Text("insert_product".tr().toString())
                  : Text("update_product".tr().toString()),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: productNameController,
                      decoration: InputDecoration(
                        hintText: "enter_product_name".tr().toString(),
                        errorText: _nameValidate
                            ? "can_not_be_empty".tr().toString()
                            : null,
                      ),
                    ),
                    TextField(
                      controller: wholesalePriceController,
                      decoration: InputDecoration(
                        hintText: "enter_wholesale_price".tr().toString(),
                        errorText: _wholesalePriceValidate
                            ? "can_not_be_empty".tr().toString()
                            : null,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: salePriceController,
                      decoration: InputDecoration(
                        hintText: "enter_selling_price".tr().toString(),
                        errorText: _salePriceValidate
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

  _displayLockDialog(BuildContext context, $id, $name, $wholesalePrice,
      $salePrice, $locked) async {
    TextEditingController productNameController =
        TextEditingController(text: $name);
    TextEditingController wholesalePriceController =
        TextEditingController(text: $wholesalePrice);
    TextEditingController salePriceController =
        TextEditingController(text: $salePrice);
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
                    update(
                        $id,
                        productNameController.text.toString(),
                        wholesalePriceController.text,
                        salePriceController.text,
                        $locked == 1 ? 0 : 1);
                    Navigator.of(context).pop();
                  } else if (text.text != 'sure'.tr().toString()) {
                    setState(() {
                      _deleteValidate = true;
                    });
                  }
                });
            return AlertDialog(
              title: Text($locked == 1
                  ? "unlock_product".tr().toString()
                  : "lock_product".tr().toString()),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: text,
                      decoration: InputDecoration(
                        hintText: "enter_sure".tr().toString(),
                        errorText: _deleteValidate
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
              title: Text("products".tr().toString()),
              leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/', (route) => false);
                  })),
          body:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    _displayDialog(context, null, null, null, null, 'store');
                  },
                  child: Text("add_product".tr().toString()),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
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
                            "wholesale_price".tr().toString(),
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
                            "status".tr().toString(),
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
                                product['wholesalePrice'].toString(),
                                textAlign: TextAlign.center,
                                style:
                                    TextStyle(fontSize: tableContentFontSize),
                              )),
                              DataCell(Text(
                                product['salePrice'].toString(),
                                textAlign: TextAlign.center,
                                style:
                                    TextStyle(fontSize: tableContentFontSize),
                              )),
                              DataCell(Text(
                                product['locked'] == 1
                                    ? "locked".tr().toString()
                                    : "unlocked".tr().toString(),
                                textAlign: TextAlign.center,
                                style:
                                    TextStyle(fontSize: tableContentFontSize),
                              )),
                              DataCell(
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Visibility(
                                      visible: product['locked'] == 0,
                                      child: IconButton(
                                        onPressed: () async {
                                          _nameValidate = false;
                                          _wholesalePriceValidate = false;
                                          _salePriceValidate = false;
                                          _displayDialog(
                                              context,
                                              product['id'],
                                              product['name'],
                                              product['wholesalePrice']
                                                  .toString(),
                                              product['salePrice'].toString(),
                                              'update');
                                        },
                                        icon: const Icon(Icons.edit),
                                        color: Colors.blue,
                                      ),
                                    ),
                                    Visibility(
                                      visible: product['locked'] == 0,
                                      child: const VerticalDivider(
                                        thickness: 0.7,
                                        color: Colors.grey,
                                        indent: 10,
                                        endIndent: 10,
                                        width: 5,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        _nameValidate = false;
                                        _wholesalePriceValidate = false;
                                        _salePriceValidate = false;
                                        _displayLockDialog(
                                            context,
                                            product['id'],
                                            product['name'],
                                            product['wholesalePrice']
                                                .toString(),
                                            product['salePrice'].toString(),
                                            product['locked']);
                                      },
                                      icon: Icon(product['locked'] == 1
                                          ? Icons.lock_open
                                          : Icons.lock),
                                      color: product['locked'] == 1
                                          ? Colors.green
                                          : Colors.red,
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
