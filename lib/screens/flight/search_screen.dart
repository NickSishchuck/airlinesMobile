import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:airline_app/services/flight_service.dart';
import 'package:airline_app/screens/flight/flight_list_screen.dart';
import 'package:airline_app/widgets/custom_button.dart';
import 'package:airline_app/widgets/custom_text_field.dart';
import 'package:airline_app/screens/ticket/ticket_list_screen.dart';
import 'package:airline_app/screens/flight/flight_board_screen.dart';
import 'package:airline_app/screens/profile/profile_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:table_calendar/table_calendar.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isRoundTrip = false;
  bool _isPriorityLine = false;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  bool _isCalendarVisible = false;

  void _toggleCalendar() {
    setState(() {
      _isCalendarVisible = !_isCalendarVisible;
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
      _isCalendarVisible = false;
    });
  }

  Future<void> _searchFlights() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final flightService = Provider.of<FlightService>(context, listen: false);
      
      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
      
      final flights = await flightService.searchFlightsByRouteAndDate(
        _originController.text,
        _destinationController.text,
        formattedDate,
      );

      if (mounted) {
        if (flights.isEmpty) {
          Fluttertoast.showToast(
            msg: 'Немає доступних рейсів на вказану дату',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FlightListScreen(
                origin: _originController.text,
                destination: _destinationController.text,
                date: _selectedDate,
                flights: flights,
                isPriorityLine: _isPriorityLine,
              ),
            ),
          );
        }
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Пошук рейсів'),
      ),
      body: Form(
        key: _formKey,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Origin Field
                  CustomTextField(
                    controller: _originController,
                    hintText: 'Місто відправки',
                    prefixIcon: const Icon(Icons.flight_takeoff),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введіть місто відправлення';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  // Destination Field
                  CustomTextField(
                    controller: _destinationController,
                    hintText: 'Місто прибуття',
                    prefixIcon: const Icon(Icons.flight_land),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введіть місто призначення';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  // Date and Round Trip Row
                  Row(
                    children: [
                      // Round Trip Checkbox
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Icon(
                                Icons.swap_horiz,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Зворотній квиток',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              Checkbox(
                                value: _isRoundTrip,
                                onChanged: (value) {
                                  setState(() {
                                    _isRoundTrip = value ?? false;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 8),
                      
                      // Date Button
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: _toggleCalendar,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'За датою',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Priority Line Switch
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        const Text(
                          'Priority line',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            'Прискорене проходження всіх формальностей',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Switch(
                          value: _isPriorityLine,
                          onChanged: (value) {
                            setState(() {
                              _isPriorityLine = value;
                            });
                          },
                          activeColor: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Search Button
                  CustomButton(
                    text: 'Знайти',
                    onPressed: _searchFlights,
                    isLoading: _isLoading,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Steam Autumn Sale Banner
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.orange[800],
                      borderRadius: BorderRadius.circular(12),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/autumn_sale.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Steam',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Autumn Sale',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Nov 27 - Dec 10',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Calendar Popup
            if (_isCalendarVisible)
              Positioned.fill(
                child: GestureDetector(
                  onTap: _toggleCalendar,
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TableCalendar(
                              firstDay: DateTime.now(),
                              lastDay: DateTime.now().add(const Duration(days: 365)),
                              focusedDay: _selectedDate,
                              selectedDayPredicate: (day) {
                                return isSameDay(_selectedDate, day);
                              },
                              onDaySelected: (selectedDay, focusedDay) {
                                _selectDate(selectedDay);
                              },
                              headerStyle: const HeaderStyle(
                                formatButtonVisible: false,
                                titleCentered: true,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: _toggleCalendar,
                                    child: const Text('Скасувати'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      _toggleCalendar();
                                    },
                                    child: const Text('Підтвердити'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TicketListScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FlightBoardScreen()),
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
}
