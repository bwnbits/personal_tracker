import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'dashboard1.dart'; // Import the Task class from dashboard1.dart

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  List<Task> _tasksHistory = [];
  String _selectedTimeframe = '7day';
  String _selectedGraphType = 'line';
  int _totalTasksInPeriod = 0;
  int _completedTasksInPeriod = 0;
  int _pendingTasksInPeriod = 0;
  double _completionPercentage = 0.0;
  List<FlSpot> _chartDataCompleted = [];
  List<FlSpot> _chartDataPending = [];

  late Future<void> _refreshFuture;

  @override
  void initState() {
    super.initState();
    _refreshFuture = _loadTasksAndAnalytics();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-fetch data if dependencies change (like navigating back to the page)
    _refreshFuture = _loadTasksAndAnalytics();
  }

  Future<void> _loadTasksAndAnalytics() async {
    final prefs = await SharedPreferences.getInstance();
    final savedHistory = prefs.getStringList('tasks_history') ?? [];
    final savedPending = prefs.getStringList('tasks') ?? [];

    final history = savedHistory.map((e) => Task.fromJson(jsonDecode(e))).toList();
    final pending = savedPending.map((e) => Task.fromJson(jsonDecode(e))).toList();

    if (mounted) {
      setState(() {
        _tasksHistory = history + pending;
        _calculateAnalytics();
      });
    }
  }

  void _calculateAnalytics() {
    _chartDataCompleted.clear();
    _chartDataPending.clear();
    _totalTasksInPeriod = 0;
    _completedTasksInPeriod = 0;
    _pendingTasksInPeriod = 0;

    final now = DateTime.now();
    List<Task> relevantTasks = [];
    final int daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final int daysToDisplay = _selectedTimeframe == '1day' ? 24 : (_selectedTimeframe == '7day' ? 7 : daysInMonth);

    if (_selectedTimeframe == '1day') {
      relevantTasks = _tasksHistory.where((task) =>
      task.createdDate.year == now.year && task.createdDate.month == now.month && task.createdDate.day == now.day).toList();
    } else if (_selectedTimeframe == '7day') {
      relevantTasks = _tasksHistory.where((task) =>
          task.createdDate.isAfter(now.subtract(const Duration(days: 7)))).toList();
    } else if (_selectedTimeframe == '30day') {
      relevantTasks = _tasksHistory.where((task) =>
          task.createdDate.isAfter(now.subtract(Duration(days: daysInMonth)))).toList();
    }

    _totalTasksInPeriod = relevantTasks.length;
    _completedTasksInPeriod = relevantTasks.where((task) => task.isCompleted).length;
    _pendingTasksInPeriod = _totalTasksInPeriod - _completedTasksInPeriod;
    _completionPercentage = _totalTasksInPeriod > 0 ? (_completedTasksInPeriod / _totalTasksInPeriod) * 100 : 0.0;

    final Map<int, int> completedData = {};
    final Map<int, int> pendingData = {};
    for (int i = 0; i < daysToDisplay; i++) {
      completedData[i] = 0;
      pendingData[i] = 0;
    }

    for (var task in relevantTasks) {
      int index;
      if (_selectedTimeframe == '1day') {
        index = task.createdDate.hour;
      } else {
        final daysAgo = now.difference(task.createdDate).inDays;
        index = (daysToDisplay - 1) - daysAgo;
      }
      if (task.isCompleted) {
        completedData[index] = (completedData[index] ?? 0) + 1;
      } else {
        pendingData[index] = (pendingData[index] ?? 0) + 1;
      }
    }

    _chartDataCompleted = completedData.entries.map((e) => FlSpot(e.key.toDouble(), e.value.toDouble())).toList();
    _chartDataPending = pendingData.entries.map((e) => FlSpot(e.key.toDouble(), e.value.toDouble())).toList();
  }

  Widget _buildGraph() {
    if (_chartDataCompleted.isEmpty && _chartDataPending.isEmpty) {
      return const Center(child: Text('No data for this period.'));
    }

    final maxY = _totalTasksInPeriod > 0 ? (_totalTasksInPeriod.toDouble() + 1) : 10.0;

    if (_selectedGraphType == 'line') {
      return LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              // The API for this is complex in older versions, but this basic structure should be fine.
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((LineBarSpot touchedSpot) {
                  return LineTooltipItem(
                      '${touchedSpot.barIndex == 0 ? 'Completed' : 'Pending'}: ${touchedSpot.y.toInt()}',
                      const TextStyle(color: Colors.white)
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            // Completed tasks line
            LineChartBarData(
              spots: _chartDataCompleted,
              isCurved: true,
              color: Colors.green, // Completed tasks are green
              barWidth: 3,
              isStrokeCapRound: true,
              belowBarData: BarAreaData(show: false),
            ),
            // Pending tasks line
            LineChartBarData(
              spots: _chartDataPending,
              isCurved: true,
              color: Colors.red, // Pending tasks are red
              barWidth: 3,
              isStrokeCapRound: true,
              belowBarData: BarAreaData(show: false),
            ),
          ],
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 30),
              axisNameWidget: Text('Task Count'),
              axisNameSize: 20,
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22, // <-- Increased from 20 to 22
                interval: _selectedTimeframe == '1day' ? 3 : (_selectedTimeframe == '7day' ? 1 : 5),
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(_getXAxisLabel(value, _chartDataCompleted.length)),
                  );
                },
              ),
              axisNameWidget: const Padding(
                padding: EdgeInsets.only(top: 8.0), // <-- Added padding
                child: Text('Time Period'),
              ),
              axisNameSize: 30, // <-- Increased from 20 to 30 for the padding
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 1),
          minX: 0, maxX: (_chartDataCompleted.length - 1).toDouble(), minY: 0, maxY: maxY,
        ),
      );
    } else { // Scatter plot
      return ScatterChart(
        ScatterChartData(
          scatterSpots: [
            ..._chartDataCompleted.map((spot) => ScatterSpot(
              spot.x,
              //
              // ** THIS IS THE FIX **
              //
              spot.y, // <-- Changed from spot.Y to spot.y
              //
              // ** END OF FIX **
              //
              dotPainter: FlDotCirclePainter(
                radius: 6,
                color: Colors.green,
                strokeWidth: 0,
              ),
            )),
            ..._chartDataPending.map((spot) => ScatterSpot(
              spot.x,
              spot.y,
              dotPainter: FlDotCirclePainter(
                radius: 6,
                color: Colors.red,
                strokeWidth: 0,
              ),
            )),
          ],
          minX: 0, maxX: (_chartDataCompleted.length - 1).toDouble(), minY: 0, maxY: maxY,
          scatterTouchData: ScatterTouchData(enabled: true),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
        ),
      );
    }
  }

  String _getXAxisLabel(double value, int totalPoints) {
    int index = value.toInt();
    if (totalPoints <= 0) return ''; // Guard against empty data

    if (_selectedTimeframe == '1day') {
      return '$index:00';
    } else if (_selectedTimeframe == '7day') {
      // Ensure index is within bounds
      if (index < 0 || index >= totalPoints) return '';
      DateTime date = DateTime.now().subtract(Duration(days: totalPoints - 1 - index));
      return '${date.day}';
    } else {
      // Ensure index is within bounds
      if (index < 0 || index >= totalPoints) return '';
      DateTime date = DateTime.now().subtract(Duration(days: totalPoints - 1 - index));
      return '${date.day}';
    }
  }

  // A separate widget for the legend
  Widget _buildLegend() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.circle, color: Colors.green, size: 12),
        SizedBox(width: 4),
        Text('Completed'),
        SizedBox(width: 16),
        Icon(Icons.circle, color: Colors.red, size: 12),
        SizedBox(width: 4),
        Text('Pending'),
      ],
    );
  }

  Widget _buildTimeframeButtons() {
    return ToggleButtons(
      isSelected: [
        _selectedTimeframe == '1day',
        _selectedTimeframe == '7day',
        _selectedTimeframe == '30day',
      ],
      onPressed: (int index) {
        setState(() {
          if (index == 0) {
            _selectedTimeframe = '1day';
          } else if (index == 1) {
            _selectedTimeframe = '7day';
          } else {
            _selectedTimeframe = '30day';
          }
          // When a button is pressed, re-run the future
          _refreshFuture = _loadTasksAndAnalytics();
        });
      },
      borderRadius: BorderRadius.circular(20),
      children: const [
        Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('1D')),
        Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('7D')),
        Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('1M')),
      ],
    );
  }

  Widget _buildGraphTypeButtons() {
    return ToggleButtons(
      isSelected: [
        _selectedGraphType == 'line',
        _selectedGraphType == 'scatter',
      ],
      onPressed: (int index) {
        setState(() {
          if (index == 0) {
            _selectedGraphType = 'line';
          } else {
            _selectedGraphType = 'scatter';
          }
        });
      },
      borderRadius: BorderRadius.circular(20),
      children: const [
        Icon(Icons.show_chart),
        Icon(Icons.scatter_plot),
      ],
    );
  }

  Widget _buildNumericSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryCard('Completed', '$_completedTasksInPeriod'),
          _buildSummaryCard('Pending', '$_pendingTasksInPeriod'),
          _buildSummaryCard('Completion', '${_completionPercentage.toStringAsFixed(0)}%'),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: FutureBuilder(
        future: _refreshFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            // Data is loaded, build the UI
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  // NEW: Micro description
                  Text('Your productivity trend over the last $_selectedTimeframe.',
                      style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTimeframeButtons(),
                      _buildGraphTypeButtons(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    child: _buildGraph(),
                  ),
                  const SizedBox(height: 8),
                  _buildLegend(), // NEW: Graph legend
                  _buildNumericSummary(),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}