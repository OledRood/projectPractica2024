import 'package:flutter/material.dart';
import 'package:hr_monitor/models/admin/users_data.dart';
import 'package:provider/provider.dart';

import '../../bloc/bloc.dart';
import '../../resources/theme/theme.dart';

int numberTable = 0;

class UsersTablesPage extends StatefulWidget {
  const UsersTablesPage({super.key});

  @override
  State<UsersTablesPage> createState() => _UsersTablesPageState();
}

class _UsersTablesPageState extends State<UsersTablesPage> {

  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<AppTheme>(context).palette;
    final Bloc bloc = Provider.of<Bloc>(context, listen: false);
    return Scaffold(
      backgroundColor: palette.color50,
      body: Stack(
        children: [
          ExitButton(),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ButtonOfCountTable(
                    onPressed: () {
                      setState(() {
                        numberTable = 0;
                      });
                    },
                    text: "Таблица User",
                    isActive: numberTable == 0),
                SizedBox(height: 10),
                ButtonOfCountTable(
                    onPressed: () {
                      setState(() {
                        numberTable = 1;
                      });
                    },
                    text: "Таблица Hr",
                    isActive: numberTable == 1),
                SizedBox(height: 10),
                ButtonOfCountTable(
                    onPressed: () {
                      setState(() {
                        numberTable = 2;
                      });
                    },
                    text: "Таблица Hr_lead",
                    isActive: numberTable == 2),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StreamBuilder<UsersData>(
                  stream: bloc.observeUserData(),
                  builder: (context, value) {
                    if (!value.hasData || value.data == null) {
                      // return ExitButton();
                      return Center(child: Text('Ошибка в получении данных'));
                    }
                    var usersData = value.data!;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: TableContent(
                            numberTable: numberTable, usersData: usersData),
                      ),
                    );
                  }),
            ],
          ),
        ],
      ),
    );
  }
}

class ExitButton extends StatelessWidget {
  const ExitButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<AppTheme>(context).palette;

    return Padding(
      padding: EdgeInsets.all(20),
      child: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(Icons.logout),
        constraints: BoxConstraints(
          minWidth: 70.0,
          minHeight: 70.0,
        ),
        focusNode: FocusNode(skipTraversal: true),
        color: palette.color50,
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          shadowColor: WidgetStatePropertyAll(Colors.black),
          elevation: WidgetStatePropertyAll(2),
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (states) {
              if (states.contains(WidgetState.hovered)) {
                return palette.color800;
              }
              return palette.color900;
            },
          ),
        ),
      ),
    );
  }
}

class ButtonOfCountTable extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final bool isActive;

  const ButtonOfCountTable(
      {super.key,
      required this.onPressed,
      required this.text,
      required this.isActive});

  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<AppTheme>(context).palette;

    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        alignment: Alignment.center,
        // maximumSize: WidgetStatePropertyAll(Size(300, 75)),
        // minimumSize: WidgetStatePropertyAll((Size(150, 75))),
        fixedSize: WidgetStatePropertyAll(Size(200, 50)),
        shadowColor: WidgetStatePropertyAll(Colors.black),
        elevation: WidgetStatePropertyAll(2),
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.pressed)) {
              return palette.color900.withOpacity(0.3);
            }
            return null;
          },
        ),
        backgroundColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
            if (states.contains(WidgetState.hovered)) {
              return palette.color300;
            }
            // else if (states.contains(WidgetState.pressed)) {
            //   return palette.color900;}
            else if (states.contains(WidgetState.focused)) {
              return palette.color300;
            }
            return palette.color100;
          },
        ),
        // foregroundColor: WidgetStateProperty.resolveWith<Color?>(
        //   (states) {
        //     if (states.contains(WidgetState.hovered)) {
        //       return palette.colorSelectedText;
        //     } else if (states.contains(WidgetState.focused)) {
        //       return palette.colorSelectedText;
        //     }
        //     return palette.colorText;
        //   },
        // ),
        side: isActive ? WidgetStatePropertyAll(
            BorderSide(color: palette.color400, width: 2.0)) : null,
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      child: Text(text),
    );
  }
}

class TableContent extends StatelessWidget {
  final int numberTable;
  final UsersData usersData;

  TableContent({super.key, required this.numberTable, required this.usersData});

  @override
  Widget build(BuildContext context) {
    final Bloc bloc = Provider.of<Bloc>(context, listen: true);

    switch (numberTable) {
      case 0:
        return scrolledWidget(
            UserDataTable(usersTableList: usersData.userTable), context);
      case 1:
        return scrolledWidget(HrTableWidget(hrTableList: usersData.hrTable), context);
      case 2:
        return scrolledWidget(HrLeadTableWidget(hrLeadTableList: usersData.hrLeadTable,), context);
    }
    return Container(
        alignment: Alignment.center,
        height: 500,
        child: const Text('Ошибка с счетом страниц'));
  }

  Widget scrolledWidget(Widget widget, context) {
    return ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: SingleChildScrollView(child: widget));
  }
}

class UserDataTable extends StatelessWidget {
  final List<UserTable> usersTableList;

  const UserDataTable({super.key, required this.usersTableList});

  @override
  Widget build(BuildContext context) {
    return DataTable(
        columns: columnNames(),
        rows: List.generate(usersTableList.length, (index) {
          return DataRow(cells: rowData(usersTableList[index]));
        }));
  }

  List<DataColumn> columnNames() {
    List<String> listName = ['user_id',  "role", "username", "password"];
    List<DataColumn> columnList = [];
    for (String name in listName) {
      columnList.add(DataColumn(
        label: Text(name),
      ));
    }
    return columnList;
  }

  List<DataCell> rowData(UserTable userTable) {
    return [
      DataCell(Center(
          child: Text("${userTable.userId}", textAlign: TextAlign.left))),
      DataCell(Text("${userTable.role}", textAlign: TextAlign.left)),
      DataCell(Text("${userTable.username}", textAlign: TextAlign.left)),
      DataCell(Text("${userTable.password}", textAlign: TextAlign.left)),

    ];
  }
}

class HrTableWidget extends StatelessWidget {
  final List<HrTable> hrTableList;

  const HrTableWidget({super.key, required this.hrTableList});

  @override
  Widget build(BuildContext context) {
    return DataTable(
        columns: columnNames(),
        rows: List.generate(hrTableList.length, (index) {
          return DataRow(cells: rowData(hrTableList[index]));
        }));
  }

  List<DataColumn> columnNames() {
    List<String> listName = ['hr_id', "hr_lead_lead"];
    List<DataColumn> columnList = [];
    for (String name in listName) {
      columnList.add(DataColumn(
        label: Text(name),
      ));
    }
    return columnList;
  }

  List<DataCell> rowData(HrTable hrTable) {
    return [
      DataCell(Center(
          child: Text("${hrTable.hrId}", textAlign: TextAlign.left))),
      DataCell(Text("${hrTable.hr_lead_id}", textAlign: TextAlign.left)),
    ];
  }
}
class HrLeadTableWidget extends StatelessWidget {
  final List<HrLeadTable> hrLeadTableList;

  const HrLeadTableWidget({super.key, required this.hrLeadTableList});

  @override
  Widget build(BuildContext context) {
    return DataTable(
        columns: columnNames(),
        rows: List.generate(hrLeadTableList.length, (index) {
          return DataRow(cells: rowData(hrLeadTableList[index]));
        }));
  }

  List<DataColumn> columnNames() {
    List<String> listName = ['hr_lead_id', "sla"];
    List<DataColumn> columnList = [];
    for (String name in listName) {
      columnList.add(DataColumn(
        label: Text(name),
      ));
    }
    return columnList;
  }

  List<DataCell> rowData(HrLeadTable hrLead) {
    return [
      DataCell(Center(
          child: Text("${hrLead.hr_lead_id}", textAlign: TextAlign.left))),
      DataCell(Text("${hrLead.sla}", textAlign: TextAlign.left)),
    ];
  }
}
