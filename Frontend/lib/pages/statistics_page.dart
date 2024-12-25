import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hr_monitor/models/statistics/average_time.dart';
import 'package:hr_monitor/pages/info_resume_page.dart';
import 'package:provider/provider.dart';

import '../bloc/bloc.dart';
import '../models/statistics/status_model.dart';
import '../models/statistics/time.dart';
import '../resources/status.dart';
import '../resources/theme/theme.dart';
import '../types/resume_statistics.dart';

int pageCount = 0;

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<AppTheme>(context).palette;
    final Bloc bloc = Provider.of<Bloc>(context, listen: false);
    return Scaffold(
        backgroundColor: palette.color50,
        body: StreamBuilder<StateRequest>(
            stream: bloc.observeStateStatisticsRequest(),
            builder: (context, state) {
              if (!state.hasData || state.data == null) {
                return ExitButton();
              }
              switch (state.data) {
                case StateRequest.good:
                  return StatisticsPageContent();

                case StateRequest.loading:
                  return Center(
                    child: Stack(
                      children: [
                        ExitButton(),
                        Center(child: CircularProgressIndicator()),
                      ],
                    ),
                  );
                case StateRequest.none:
                  return ExitButton();
                default:
                  print('Statistica ${state.data}');
                  return RestartWidget();
              }
            }));
  }
}

class StatisticsPageContent extends StatefulWidget {
  const StatisticsPageContent({super.key});

  @override
  State<StatisticsPageContent> createState() => _StatisticsPageContentState();
}

class _StatisticsPageContentState extends State<StatisticsPageContent> {
  @override
  Widget build(BuildContext context) {
    final Bloc bloc = Provider.of<Bloc>(context, listen: false);
    return Stack(
      children: [
        ExitButton(),
        StreamBuilder<List<ResumeStatistic>>(
            stream: bloc.observeStatistics(),
            builder: (context, value) {
              if (!value.hasData || value.data == null) {
                return ExitButton();
              }
              var statistics = value.data!;

              var maxCountPage =
                  (statistics.length == 1) ? 0 : statistics.length - 1;
              print('maxCount = $maxCountPage');
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    (maxCountPage != 0)
                        ? MoveButton(
                            icon: Icons.chevron_left,
                            onPressed: () {
                              setState(() {
                                pageCount--;
                              });
                            },
                            isEnable: (pageCount > 0))
                        : SizedBox(
                            width: 40,
                          ),
                    StatisticsData(
                      resumeStatistics: statistics[pageCount],
                    ),
                    (maxCountPage != 0)
                        ? MoveButton(
                            icon: Icons.chevron_right,
                            onPressed: () {
                              setState(() {
                                pageCount++;
                              });
                            },
                            isEnable: (pageCount < maxCountPage))
                        : SizedBox(
                            width: 40,
                          ),
                  ],
                ),
              );
            }),
      ],
    );
  }
}

class StatisticsData extends StatelessWidget {
  final ResumeStatistic resumeStatistics;

  StatisticsData({super.key, required this.resumeStatistics});

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<AppTheme>(context).palette;

    return ScrollConfiguration(
      //Убрать плолсу прокрутки
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),

      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text("${resumeStatistics.name}",
                style: Theme.of(context).textTheme.headlineLarge),
            SizedBox(
              height: 30,
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Text("Сатистика по статусу", style: style),
                        SizedBox(height: 10),
                        HistogramWidget(
                            statusStatistic: resumeStatistics.status),
                        SizedBox(height: 50),
                      ],
                    ),
                    SizedBox(width: 270),
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Статистика по источникам', style: style),
                        SizedBox(height: 10),
                        SizedBox(
                            height: 300,
                            width: 300,
                            child: CircularHistogramWidget(
                                source: resumeStatistics.source))
                      ],
                    )
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Text('Среднее время в статусе', style: style),
                        SizedBox(height: 10),
                        AverageTable(
                          statistics: resumeStatistics,
                        ),
                      ],
                    ),
                    SizedBox(width: 50),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('Статистика по вакансиям', style: style),
                        SizedBox(height: 10),
                        VacancyTableWidget(
                          vacancy: resumeStatistics.vacancy,
                        )
                      ],
                    )
                  ],
                )
              ],
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  TextStyle get style => TextStyle(fontWeight: FontWeight.w500, fontSize: 20);
}

class VacancyTableWidget extends StatelessWidget {
  final vacancy;

  const VacancyTableWidget({super.key, this.vacancy});

  @override
  Widget build(BuildContext context) {
    return DataTable(
        columns: columnNames(),
        rows: List.generate(vacancy.keys.toList().length, (index) {
          return DataRow(cells: rowData(index));
        }));
  }

  List<DataColumn> columnNames() {
    List<String> listName = ['Вакансия', 'Количество'];
    List<DataColumn> columnList = [];
    for (String name in listName) {
      columnList.add(DataColumn(label: Text(name)));
    }
    return columnList;
  }

  List<DataCell> rowData(int index) {
    List<String> keys = vacancy.keys.toList();
    List<double> values =
        vacancy.values.cast<double>().toList(); // Пример данных
    List<PieChartSectionData> sections = [];

    return [
      DataCell(Center(child: Text("${keys[index]}"))),
      DataCell(Center(child: Text("${values[index]}"))),
    ];
  }
}

class AverageTable extends StatelessWidget {
  final ResumeStatistic statistics;

  const AverageTable({super.key, required this.statistics});

  @override
  Widget build(BuildContext context) {
    return DataTable(
        columns: columnNames(),
        rows: List.generate(7, (index) {
          return DataRow(
              cells: rowData(Status.code[index]!,
                  statistics.averageTime.getSortedListByStatus()[index]));
        }));
  }

  List<DataColumn> columnNames() {
    List<String> listName = ['Статус', "Дни", "Часы", "Минуты", "Секунды"];
    List<DataColumn> columnList = [];
    for (String name in listName) {
      columnList.add(DataColumn(label: Text(name)));
    }
    return columnList;
  }

  List<DataCell> rowData(String status, Time time) {
    return [
      DataCell(Text(
        "${status}",
        textAlign: TextAlign.center,
      )),
      DataCell(
          Center(child: Text("${time.days}", textAlign: TextAlign.center))),
      DataCell(
          Center(child: Text("${time.hours}", textAlign: TextAlign.center))),
      DataCell(
          Center(child: Text("${time.minutes}", textAlign: TextAlign.center))),
      DataCell(
          Center(child: Text("${time.seconds}", textAlign: TextAlign.center))),
    ];
  }
}

class MoveButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isEnable;
  final IconData icon;

  const MoveButton(
      {super.key,
      required this.onPressed,
      required this.isEnable,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<AppTheme>(context).palette;

    return Stack(
      children: [
        IconButton(
          onPressed: isEnable ? onPressed : null,
          // alignment: Alignment.center,
          icon: Icon(icon),
          color: palette.color50,
          disabledColor: palette.color50,
          constraints: BoxConstraints(
              maxWidth: 40.0, maxHeight: 100.0, minHeight: 100, minWidth: 40),
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color?>(
              (states) {
                if (states.contains(WidgetState.hovered)) {
                  return palette.color700;
                }
                return palette.color900;
              },
            ),
          ),
        ),
        if (!isEnable)
          Container(
            height: 100,
            width: 40,
            decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(19)),
          ),
      ],
    );
  }
}

class HistogramWidget extends StatefulWidget {
  final StatusModel statusStatistic;

  const HistogramWidget({super.key, required this.statusStatistic});

  @override
  State<HistogramWidget> createState() => _HistogramWidgetState();
}

class _HistogramWidgetState extends State<HistogramWidget> {
  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<AppTheme>(context).palette;

    return Container(
      height: 280,
      width: 400,
      child: RotatedBox(
        quarterTurns: 1,
        child: BarChart(
          BarChartData(
              alignment: BarChartAlignment.spaceBetween,

              //Нужно на 4 больше
              maxY: widget.statusStatistic.getMaxStatus(),
              gridData: FlGridData(show: false),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  tooltipRoundedRadius: 0,
                  getTooltipColor: (group) => Colors.transparent,
                  // tooltipHorizontalAlignment: FLHorizontalAlignment.center,
                  fitInsideHorizontally: true,
                  // Гарантирует, что подсказка не выйдет за границы
                  tooltipPadding:
                      EdgeInsets.only(top: 0, bottom: 0, right: 2, left: 2),
                  rotateAngle: -90,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${rod.toY}',
                      TextStyle(
                        color: palette.color900,
                        fontSize: 14,
                      ),
                    );
                  },
                ),
              ),
              borderData: FlBorderData(
                show: false,
                border: null, // Обводка графика
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true, // Отображение подписей оси X
                    getTitlesWidget: (value, meta) {
                      // return Text('Здравствуйте\nIts\nRevolution');
                      return RotatedBox(
                        quarterTurns: 3,
                        child: Text(
                          "${Status.getShortName(value.toInt())}",
                        ),
                      ); // Вывод числовых значений по оси X
                    },
                    reservedSize: 100, // Отступ для подписей
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false, // Показывать подписи сверху
                  ),
                ),
                leftTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                        showTitles: false)), // Скрытие правых подписей
              ),
              barGroups: getBarGroups(widget.statusStatistic)),
        ),
      ),
    );
  }

  List<BarChartGroupData> getBarGroups(StatusModel statusModel) {
    final palette = Provider.of<AppTheme>(context).palette;

    List<double> listOfHeight = statusModel.getSortedListByStatus();
    // listOfHeight = [4, 5, 6, 7, 8, 1, 20];
    List<BarChartGroupData> listOfGroups = [];
    for (int i = 0; i < listOfHeight.length; i++) {
      listOfGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
                toY: listOfHeight[i],
                width: 30,
                // gradient: _barsGradient,
                color: palette.color400)
          ],
          showingTooltipIndicators: [0],
        ),
      );
    }
    return listOfGroups;
  }
}

class CircularHistogramWidget extends StatelessWidget {
  final source;

  const CircularHistogramWidget({super.key, required this.source});

  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<AppTheme>(context).palette;

    return PieChart(PieChartData(
        borderData: FlBorderData(show: false),
        sectionsSpace: 0,
        centerSpaceRadius: 0,
        sections: showingSections(palette)));
  }

  // Секция данных для круговой диаграммы
  List<PieChartSectionData> showingSections(palette) {
    // {Певец: 1, Повар: 1, Презедент: 1, вак: 1}

    List<String> keys = source.keys.toList();
    List<double> values =
        source.values.cast<double>().toList(); // Пример данных
    List<PieChartSectionData> sections = [];

    // Генерация цветов с использованием градиента
    Color startColor = palette.color100;
    Color endColor = palette.color800;

    for (int i = 0; i < values.length; i++) {
      double percentage = values[i] / values.reduce((a, b) => a + b);
      // Генерация цвета с помощью интерполяции градиента
      Color color = values.length == 1
          ? startColor
          : Color.lerp(startColor, endColor, i / (values.length - 1))!;
      sections.add(
        PieChartSectionData(
          color: color,
          value: values[i],
          title: '${keys[i]}',
          radius: 150,
          titleStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return sections;
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

class RestartWidget extends StatelessWidget {
  const RestartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final Bloc bloc = Provider.of<Bloc>(context, listen: false);
    final palette = Provider.of<AppTheme>(context).palette;

    return Stack(
      children: [
        ExitButton(),
        Center(
          child: IconButton(
            onPressed: () => bloc.getStatistic(),
            icon: Icon(Icons.refresh),
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
        ),
      ],
    );
  }
}
