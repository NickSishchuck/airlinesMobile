import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:airline_app/services/flight_service.dart';
import 'package:airline_app/models/flight.dart';
import 'package:airline_app/widgets/flight_card.dart';
import 'package:airline_app/widgets/custom_button.dart';
import 'package:airline_app/theme/app_theme.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FlightListScreen extends StatefulWidget {
  final String origin;
  final String destination;
  final DateTime date;
  final List<Flight> flights;
  final bool isPriorityLine;

  const FlightListScreen({
    Key? key,
    required this.origin,
    required this.destination,
    required this.date,
    required this.flights,
    this.isPriorityLine = false,
  }) : super(key: key);

  @override
  State<FlightListScreen> createState() => _FlightListScreenState();
}

class _FlightListScreenState extends State<FlightListScreen> {
  late List<Flight> _filteredFlights;
  Flight? _selectedFlight;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _filteredFlights = widget.flights;
  }

  void _selectFlight(Flight flight) {
    setState(() {
      _selectedFlight = flight;
    });
    
    // Update the selected flight in the service
    Provider.of<FlightService>(context, listen: false).setSelectedFlight(flight);
  }

  void _filterFlights(String status) {
    setState(() {
      if (status == 'all') {
        _filteredFlights = widget.flights;
      } else {
        _filteredFlights = widget.flights
            .where((flight) => flight.status?.toLowerCase() == status.toLowerCase())
            .toList();
      }
    });
  }

  void _bookFlight() {
    if (_selectedFlight == null) {
      Fluttertoast.showToast(
        msg: 'Будь ласка, виберіть рейс',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate booking process
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Show success message
        Fluttertoast.showToast(
          msg: 'Квиток успішно заброньовано!',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        
        // Navigate back to search screen
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'uk');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Доступні рейси'),
      ),
      body: Column(
        children: [
          // Route and date info
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.origin,
                            style: AppTheme.titleStyle,
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Icon(
                        Icons.flight,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            widget.destination,
                            style: AppTheme.titleStyle,
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Дата: ${dateFormat.format(widget.date)}',
                  style: AppTheme.captionStyle,
                ),
                if (widget.isPriorityLine)
                  Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blue,
                            width: 1,
                          ),
                        ),
                        child: const Text(
                          'Priority Line',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          
          // Filter buttons
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('Усі'),
                    selected: _filteredFlights == widget.flights,
                    onSelected: (selected) {
                      if (selected) {
                        _filterFlights('all');
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('За розкладом'),
                    selected: _filteredFlights != widget.flights &&
                        _filteredFlights.every((f) => f.status?.toLowerCase() == 'scheduled'),
                    onSelected: (selected) {
                      if (selected) {
                        _filterFlights('scheduled');
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Посадка'),
                    selected: _filteredFlights != widget.flights &&
                        _filteredFlights.every((f) => f.status?.toLowerCase() == 'boarding'),
                    onSelected: (selected) {
                      if (selected) {
                        _filterFlights('boarding');
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Затримується'),
                    selected: _filteredFlights != widget.flights &&
                        _filteredFlights.every((f) => f.status?.toLowerCase() == 'delayed'),
                    onSelected: (selected) {
                      if (selected) {
                        _filterFlights('delayed');
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // Flight list
          Expanded(
            child: _filteredFlights.isEmpty
                ? const Center(
                    child: Text(
                      'Немає доступних рейсів',
                      style: AppTheme.subtitleStyle,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredFlights.length,
                    itemBuilder: (context, index) {
                      final flight = _filteredFlights[index];
                      final isSelected = _selectedFlight?.flightId == flight.flightId;
                      
                      return Stack(
                        children: [
                          FlightCard(
                            flight: flight,
                            showDetails: isSelected,
                            onTap: () => _selectFlight(flight),
                          ),
                          if (isSelected)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(16),
                                    bottomLeft: Radius.circular(16),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: CustomButton(
          text: 'Забронювати квиток',
          onPressed: _bookFlight,
          isLoading: _isLoading,
          isFullWidth: true,
        ),
      ),
    );
  }
}
