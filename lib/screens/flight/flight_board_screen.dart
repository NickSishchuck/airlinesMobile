import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:airline_app/services/flight_service.dart';
import 'package:airline_app/models/flight.dart';
import 'package:airline_app/screens/flight/search_screen.dart';
import 'package:airline_app/screens/ticket/ticket_list_screen.dart';
import 'package:airline_app/theme/app_theme.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FlightBoardScreen extends StatefulWidget {
  const FlightBoardScreen({Key? key}) : super(key: key);

  @override
  State<FlightBoardScreen> createState() => _FlightBoardScreenState();
}

class _FlightBoardScreenState extends State<FlightBoardScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<Flight>? _flights;
  late TabController _tabController;
  Flight? _selectedFlight;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFlightSchedule();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFlightSchedule() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final flightService = Provider.of<FlightService>(context, listen: false);
      
      // Get today's and tomorrow's dates
      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));
      
      // Format dates for API
      final startDate = DateFormat('yyyy-MM-dd').format(today);
      final endDate = DateFormat('yyyy-MM-dd').format(tomorrow);
      
      // Generate flight schedule
      _flights = await flightService.generateFlightSchedule(startDate, endDate);
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Помилка завантаження розкладу: ${e.toString()}',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showFlightInfo(Flight flight) {
    setState(() {
      _selectedFlight = flight;
    });
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: _buildFlightDetails(flight),
          ),
        ),
      ),
    );
  }

  Widget _buildFlightDetails(Flight flight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Flight header
        Text(
          'Рейс ${flight.flightNumber}',
          style: AppTheme.headlineStyle,
        ),
        const SizedBox(height: 16),
        
        // Flight route
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    flight.origin ?? 'Origin',
                    style: AppTheme.titleStyle,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    flight.formattedDepartureDate,
                    style: AppTheme.bodyStyle,
                  ),
                  Text(
                    flight.formattedDepartureTime,
                    style: AppTheme.subtitleStyle,
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  const Icon(
                    Icons.flight,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    flight.duration,
                    style: AppTheme.captionStyle,
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    flight.destination ?? 'Destination',
                    style: AppTheme.titleStyle,
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    flight.formattedArrivalDate,
                    style: AppTheme.bodyStyle,
                    textAlign: TextAlign.right,
                  ),
                  Text(
                    flight.arrivalTime != null 
                        ? '${flight.arrivalTime!.hour.toString().padLeft(2, '0')}:${flight.arrivalTime!.minute.toString().padLeft(2, '0')}'
                        : '--:--',
                    style: AppTheme.subtitleStyle,
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        
        // Flight status and gate
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Статус',
                    style: TextStyle(color: AppTheme.secondaryTextColor),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(flight.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(flight.status),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _getStatusText(flight.status),
                      style: TextStyle(
                        color: _getStatusColor(flight.status),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Гейт',
                    style: TextStyle(color: AppTheme.secondaryTextColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    flight.gate ?? 'TBA',
                    style: AppTheme.subtitleStyle,
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Aircraft info
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Літак',
                    style: TextStyle(color: AppTheme.secondaryTextColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    flight.aircraftModel ?? 'N/A',
                    style: AppTheme.subtitleStyle,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Реєстрація',
                    style: TextStyle(color: AppTheme.secondaryTextColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    flight.registrationNumber ?? 'N/A',
                    style: AppTheme.subtitleStyle,
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Captain
        const Text(
          'Капітан',
          style: TextStyle(color: AppTheme.secondaryTextColor),
        ),
        const SizedBox(height: 8),
        Text(
          flight.captainName ?? 'N/A',
          style: AppTheme.subtitleStyle,
        ),
        
        const SizedBox(height: 32),
        
        // Book ticket button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Fluttertoast.showToast(
                msg: 'Перенаправлення на бронювання квитка',
                toastLength: Toast.LENGTH_SHORT,
              );
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Забронювати квиток'),
            ),
          ),
        ),
      ],
    );
  }

  String _getStatusText(String? status) {
    if (status == null) return 'Невідомо';
    
    switch (status.toLowerCase()) {
      case 'scheduled':
        return 'За розкладом';
      case 'boarding':
        return 'Посадка';
      case 'departed':
        return 'Відправлено';
      case 'arrived':
        return 'Прибув';
      case 'delayed':
        return 'Затримується';
      case 'canceled':
        return 'Скасовано';
      default:
        return status;
    }
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    
    switch (status.toLowerCase()) {
      case 'scheduled':
        return Colors.green;
      case 'boarding':
        return Colors.blue;
      case 'departed':
        return Colors.orange;
      case 'arrived':
        return Colors.green;
      case 'delayed':
        return Colors.amber;
      case 'canceled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: const Text('Табло'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Відправлення'),
            Tab(text: 'Прибуття'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _flights == null || _flights!.isEmpty
              ? const Center(
                  child: Text(
                    'Немає доступних рейсів',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // Departures tab
                    RefreshIndicator(
                      onRefresh: _loadFlightSchedule,
                      child: _buildFlightList(_flights!, true),
                    ),
                    
                    // Arrivals tab
                    RefreshIndicator(
                      onRefresh: _loadFlightSchedule,
                      child: _buildFlightList(_flights!, false),
                    ),
                  ],
                ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SearchScreen()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const TicketListScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Пошук',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.airplane_ticket),
            label: 'Квитки',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Табло',
          ),
        ],
      ),
    );
  }

  Widget _buildFlightList(List<Flight> flights, bool isDepartures) {
    // In a real app, we'd filter these properly
    // For now, just split the list in half for demonstration
    final filteredFlights = isDepartures 
        ? flights.take(flights.length ~/ 2 + 1).toList()
        : flights.skip(flights.length ~/ 2 + 1).toList();
    
    if (filteredFlights.isEmpty) {
      return const Center(
        child: Text(
          'Немає рейсів для відображення',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
    
    return Container(
      color: Colors.white,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: filteredFlights.length,
        itemBuilder: (context, index) {
          final flight = filteredFlights[index];
          
          return InkWell(
            onTap: () => _showFlightInfo(flight),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                children: [
                  // Flight number
                  SizedBox(
                    width: 80,
                    child: Text(
                      flight.flightNumber ?? 'N/A',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  
                  // City
                  Expanded(
                    flex: 2,
                    child: Text(
                      isDepartures ? (flight.destination ?? 'N/A') : (flight.origin ?? 'N/A'),
                    ),
                  ),
                  
                  // Time
                  SizedBox(
                    width: 50,
                    child: Text(
                      flight.formattedDepartureTime,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  
                  // Gate
                  SizedBox(
                    width: 50,
                    child: Text(
                      flight.gate ?? 'N/A',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  // Status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getStatusColor(flight.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(flight.status),
                      style: TextStyle(
                        color: _getStatusColor(flight.status),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
