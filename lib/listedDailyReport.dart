// ignore_for_file: library_private_types_in_public_api, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'constants.dart';
import 'sqldb.dart';

class ListedDailyReport extends StatefulWidget {
  const ListedDailyReport({super.key});

  @override
  _ListedDailyReportState createState() => _ListedDailyReportState();
}

class _ListedDailyReportState extends State<ListedDailyReport> {
  SqlDb sqlDb = SqlDb();
  List<Map> reportList = [];
  var totalMoney;
  Color tableHeaderColor = Constants.tableHeaderColor;
  Color tableHeaderTitleColor = Constants.white;
  Color primaryColor = Constants.blue;
  double tableContentFontSize = Constants.tableContentFontSize;
  double tableTitleFontSize = Constants.tableTitleFontSize;
  static const double paddingSize = Constants.padding;

  @override
  void initState() {
    super.initState();
    fetchListDailyReport();
    fetchTotalMoney();
  }

  void fetchListDailyReport() async {
    List<Map> response =
        await sqlDb.readData("SELECT count(product_id) as products_count,"
            "sum(sold_price) as price_sum,"
            "DATE(created_at) as date"
            " FROM sales"
            " GROUP BY DATE(created_at);");
    setState(() {
      reportList = response;
    });
  }

  void fetchTotalMoney() async {
    var response = await sqlDb.readData(
      "SELECT SUM(sold_price) AS price_sum FROM sales",
    );
    setState(() {
      totalMoney = response.first['price_sum'] != null ?
      response.first['price_sum'].toStringAsFixed(2) : "0";
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
              title: Text("list_daily_report".tr().toString()),
              leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/', (route) => false);
                  })),
          body:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Card(
                      margin: const EdgeInsets.all(10),
                      color: primaryColor,
                      shadowColor: Colors.grey,
                      elevation: 2,
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            leading: const Icon(Icons.paid,
                                color: Colors.white, size: 45),
                            title: Text(
                              "${"total_money".tr()}: $totalMoney",
                              style: const TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
                          "date".tr().toString(),
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: tableHeaderTitleColor),
                          textAlign: TextAlign.center,
                        )),
                        DataColumn(
                            label: Text(
                          "total_products".tr().toString(),
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: tableHeaderTitleColor),
                        )),
                        DataColumn(
                            label: Text(
                          "daily_sales".tr().toString(),
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: tableHeaderTitleColor),
                        )),
                      ],
                      rows: [
                        for (var row in reportList)
                          DataRow(cells: [
                            DataCell(Text(
                              row['date'].toString(),
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: tableContentFontSize),
                            )),
                            DataCell(Text(
                              row['products_count'].toString(),
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: tableContentFontSize),
                            )),
                            DataCell(Text(
                              row['price_sum'].toStringAsFixed(2),
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: tableContentFontSize),
                            )),
                          ]),
                      ],
                    )),
              ),
            ),
          ]),
        ));
  }
}
