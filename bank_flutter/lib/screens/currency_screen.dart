// lib/screens/currency_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../models/currency.dart';
import '../services/currency_service.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({Key? key}) : super(key: key);

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  final CurrencyService _currencyService = CurrencyService();
  List<Currency> _currencies = [];
  bool _isLoading = true;
  String _errorMessage = '';
  
  // Selected currency for detailed view
  Currency? _selectedCurrency;
  
  // Mock data for currency history graph
  List<FlSpot> _mockHistoryData = [];
  
  @override
  void initState() {
    super.initState();
    _loadCurrencies();
  }
  
  Future<void> _loadCurrencies() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final currencies = await _currencyService.getCurrencies();
      
      setState(() {
        _currencies = currencies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Falha ao carregar cotações: $e';
        _isLoading = false;
      });
    }
  }
  
  void _selectCurrency(Currency currency) {
    setState(() {
      _selectedCurrency = currency;
      
      // Generate random mock data for the graph
      final random = Random();
      _mockHistoryData = List.generate(
        30,
        (index) => FlSpot(
          (index + 1).toDouble(),
          currency.value * (1 + (random.nextDouble() - 0.5) * 0.1),
        ),
      );
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cotações'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadCurrencies,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.red[700],
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadCurrencies,
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      // Currency detail view
                      if (_selectedCurrency != null) _buildCurrencyDetailView(),
                      
                      // Currency list
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _currencies.length,
                          itemBuilder: (context, index) {
                            final currency = _currencies[index];
                            return _buildCurrencyCard(currency);
                          },
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
  
  Widget _buildCurrencyCard(Currency currency) {
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final isPositiveVariation = currency.variation >= 0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _selectCurrency(currency),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Currency icon/flag
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    currency.code.substring(0, 3),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Currency details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currency.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Atualizado: ${DateFormat('dd/MM HH:mm').format(currency.lastUpdate)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Currency value and variation
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currencyFormat.format(currency.value),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        isPositiveVariation
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 12,
                        color: isPositiveVariation ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${isPositiveVariation ? '+' : ''}${currency.variation.toStringAsFixed(2)}%',
                        style: TextStyle(
                          color: isPositiveVariation ? Colors.green : Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCurrencyDetailView() {
    if (_selectedCurrency == null) return const SizedBox.shrink();
    
    final currency = _selectedCurrency!;
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final isPositiveVariation = currency.variation >= 0;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${currency.code} - ${currency.name}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _selectedCurrency = null;
                  });
                },
              ),
            ],
          ),
          
          // Currency value and variation
          Row(
            children: [
              Text(
                currencyFormat.format(currency.value),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isPositiveVariation
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPositiveVariation
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      size: 12,
                      color: isPositiveVariation ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${isPositiveVariation ? '+' : ''}${currency.variation.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: isPositiveVariation ? Colors.green : Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Chart
          Container(
            height: 150,
            padding: const EdgeInsets.all(8),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        // Only show some dates to avoid overcrowding
                        if (value % 5 != 0) return const SizedBox.shrink();
                        
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            '${value.toInt()}d',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: Theme.of(context).colorScheme.background,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          currencyFormat.format(spot.y),
                          TextStyle(color: Theme.of(context).primaryColor),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: _mockHistoryData,
                    isCurved: true,
                    color: Theme.of(context).primaryColor,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Info text
          Text(
            'Dados históricos dos últimos 30 dias',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}