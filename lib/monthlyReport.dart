// ignore_for_file: library_private_types_in_public_api, prefer_typing_uninitialized_variables

import 'package:easy_localization/easy_localization.dart';
import 'package:alfarsha/home.dart';
import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'constants.dart';
import 'sqldb.dart';

class MonthlyReport extends StatefulWidget {
  const MonthlyReport({super.key});

  @override
  _MonthlyReportState createState() => _MonthlyReportState();
}

class _MonthlyReportState extends State<MonthlyReport> {
  SqlDb sqlDb = SqlDb();
  List<Map> reportList = [];
  List<DateTime> dates = [];
  List<Map> sellingProducts = [];
  var totalMoney, wholesalePrice, netProfit, sellingPrice, sellingPriceAfterObligation,netProfitAfterObligation;
  Color tableHeaderColor = Constants.tableHeaderColor;
  Color tableHeaderTitleColor = Constants.white;
  Color obligationValuesColor = Constants.lightBlue;
  Color mostSoldProductColor = Constants.lightGreen;
  double tableContentFontSize = Constants.tableContentFontSize;
  double tableTitleFontSize = Constants.tableTitleFontSize;
  static const double paddingSize = Constants.padding;
  DateTime dateValue = DateTime.now();
  String? monthName;
  String? languageCode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = EasyLocalization.of(context)?.locale;
    languageCode = locale!.languageCode;
    monthName = DateFormat.MMMM(languageCode).format(dateValue).toString();
    getSellingProductFormDate(dateValue);
    getIMoneyData(dateValue);
  }

  void getIMoneyData(date) async {
    var response = await sqlDb.readData('''
      SELECT sum(sold_price) AS selling_price, sum(products.wholesalePrice) AS wholesale_price ,sum(sold_price)- sum(products.wholesalePrice)as net_profit
      FROM sales
      INNER JOIN products ON sales.product_id = products.id 
        WHERE strftime('%Y-%m', sales.created_at) = strftime('%Y-%m','$date','localtime')
      ''');
    setState(() {
      sellingPrice = response.first['selling_price'] ?? 0;
      sellingPriceAfterObligation = response.first['selling_price'] ?? 0;
      wholesalePrice = response.first['wholesale_price'] ?? 0;
      netProfit = response.first['net_profit'] ?? 0;
      netProfitAfterObligation = response.first['net_profit'] ?? 0;
    });
  }

  void getSellingProductFormDate(date) async {
    var response = await sqlDb.readData('''
    SELECT products.name As name,
        COUNT() AS number_of_selling
        FROM sales 
        INNER JOIN products ON sales.product_id = products.id 
        WHERE strftime('%Y-%m', sales.created_at) = strftime('%Y-%m','$date','localtime')
        GROUP BY product_id 
        ORDER BY number_of_selling DESC
        ''');
    setState(() {
      sellingProducts = response;
    });
  }

  Future<void> _showDatePicker(BuildContext context) async {
    await showMonthPicker(
      context: context,
      initialDate: DateTime.now(),
    ).then((date) {
      if (date != null) {
        setState(() {
          dateValue = date;
          monthName = DateFormat.MMMM(languageCode).format(date).toString();
        });
      }
    });
    setState(() {
      getIMoneyData(dateValue);
      getSellingProductFormDate(dateValue);
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
              title: Text("monthly_report".tr().toString()),
              leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const Home()));
                  })),
          body:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(
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
                        "data".tr().toString(),
                        style: TextStyle(
                            fontSize: tableTitleFontSize,
                            fontWeight: FontWeight.bold,
                            color: tableHeaderTitleColor),
                      )),
                      DataColumn(
                          label: Text(
                        "value".tr().toString(),
                        style: TextStyle(
                            fontSize: tableTitleFontSize,
                            fontWeight: FontWeight.bold,
                            color: tableHeaderTitleColor),
                      )),
                    ],
                    rows: [
                      DataRow(cells: [
                        DataCell(Text("date".tr().toString(),
                            style: TextStyle(
                                fontSize: tableContentFontSize,
                                fontWeight: FontWeight.bold))),
                        DataCell(
                          TextButton(
                            onPressed: () {
                              _showDatePicker(context);
                            },
                            child: Text(
                              monthName.toString(),
                              style: TextStyle(
                                fontSize: tableContentFontSize,
                              ),
                            ),
                          ),
                        ),
                      ]),
                      DataRow(cells: [
                        DataCell(Text("total_selling_price".tr().toString(),
                            style: TextStyle(
                                fontSize: tableTitleFontSize,
                                fontWeight: FontWeight.bold))),
                        DataCell(Text(
                            sellingPrice.toString(),
                            style: TextStyle(
                              fontSize: tableContentFontSize,
                            ))),
                      ]),
                      DataRow(cells: [
                        DataCell(Text("total_wholesale_price".tr().toString(),
                            style: TextStyle(
                                fontSize: tableContentFontSize,
                                fontWeight: FontWeight.bold))),
                        DataCell(Text(
                            wholesalePrice.toString(),
                            style: TextStyle(
                              fontSize: tableContentFontSize,
                            ))),
                      ]),
                      DataRow(cells: [
                        DataCell(Text("net_profit".tr().toString(),
                            style: TextStyle(
                                fontSize: tableContentFontSize,
                                fontWeight: FontWeight.bold))),
                        DataCell(Text(
                            netProfit.toString(),
                            style: TextStyle(
                              fontSize: tableContentFontSize,
                            ))),
                      ]),
                      DataRow(cells: [
                        DataCell(Text("obligations_value".tr().toString(),
                            style: TextStyle(
                                fontSize: tableContentFontSize,
                                fontWeight: FontWeight.bold))),
                        DataCell(
                          Container(
                            width: 100,
                            margin: const EdgeInsets.only(top: 8, bottom: 8),
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  sellingPriceAfterObligation = sellingPrice - double.parse(value);
                                  netProfitAfterObligation = netProfit- double.parse(value);
                                });
                              },
                              decoration: const InputDecoration(
                                hintText: "",
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.all(8),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ),
                      ]),
                      DataRow(
                          color: MaterialStateColor.resolveWith(
                                  (states) => obligationValuesColor),
                          cells: [
                            DataCell(Text("total_selling_price".tr().toString(),
                                style: TextStyle(
                                    fontSize: tableContentFontSize,
                                    fontWeight: FontWeight.bold))),
                            DataCell(Text(
                                sellingPriceAfterObligation.toString(),
                                style: TextStyle(
                                  fontSize: tableContentFontSize,
                                ))),
                          ]),
                      DataRow(
                          color: MaterialStateColor.resolveWith(
                                  (states) => obligationValuesColor),
                          cells: [
                            DataCell(Text("net_profit".tr().toString(),
                                style: TextStyle(
                                    fontSize: tableContentFontSize,
                                    fontWeight: FontWeight.bold))),
                            DataCell(Text(
                                netProfitAfterObligation != null
                                    ? netProfitAfterObligation.toStringAsFixed(2):
                                netProfitAfterObligation.toString(),
                                style: TextStyle(
                                  fontSize: tableContentFontSize,
                                ))),
                          ]),
                      for (var index = 0;
                          index < sellingProducts.length;
                          index++)
                        DataRow(
                            color: index == 0
                                ? MaterialStateColor.resolveWith(
                                    (states) => mostSoldProductColor)
                                : null,
                            cells: [
                              DataCell(Text(sellingProducts[index]['name'],
                                  style: TextStyle(
                                      fontSize: tableContentFontSize,
                                      fontWeight: FontWeight.bold))),
                              DataCell(Text(
                                  sellingProducts[index]['number_of_selling']
                                      .toString(),
                                  style: TextStyle(
                                    fontSize: tableContentFontSize,
                                  ))),
                            ]),
                    ],
                  ),
                ),
              ),
            ),
          ]),
        ));
  }
}
