import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:airline_app/models/ticket.dart';
import 'package:airline_app/services/ticket_service.dart';
import 'package:airline_app/theme/app_theme.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TicketDetailScreen extends StatefulWidget {
  final Ticket ticket;

  const TicketDetailScreen({
    Key? key,
    required this.ticket,
  }) : super(key: key);

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  bool _isLoading = false;

  Future<void> _loadPrintableTicket() async {
    if (widget.ticket.ticketId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final ticketService = Provider.of<TicketService>(context, listen: false);
      await ticketService.getPrintableTicket(widget.ticket.ticketId!);
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Помилка завантаження квитка: ${e.toString()}',
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Квиток'),
        backgroundColor: Colors.blue[900],
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ticket header
                  Text(
                    'Квиток',
                    style: AppTheme.headlineStyle,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${widget.ticket.ticketId}',
                        style: AppTheme.subtitleStyle,
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          // Implement copy functionality
                          Fluttertoast.showToast(
                            msg: 'Номер квитка скопійовано',
                            toastLength: Toast.LENGTH_SHORT,
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Passenger details
                  const Text(
                    'Пасажир',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Виданий'),
                      const Spacer(),
                      Text(
                        widget.ticket.passengerName ?? 'Artem Myronenko',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Дата народження'),
                      const Spacer(),
                      const Text(
                        '15.04.2006',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Ticket validity
                  const Text(
                    'Термін дії',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${widget.ticket.formattedDate}-${widget.ticket.formattedArrivalDate}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Ticket class
                  const Text(
                    'Клас',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.ticket.ticketClass == 'economy' 
                        ? 'Економ Клас'
                        : widget.ticket.ticketClass == 'business'
                            ? 'Бізнес Клас'
                            : 'Перший Клас',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 24),
                  
                  // Passenger count
                  const Text(
                    'Кількість пасажирів',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '1 Персона (з 6 років)',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 24),
                  
                  // Flight details
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Рейс: ${widget.ticket.flightNumber}',
                          style: AppTheme.subtitleStyle,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.ticket.origin ?? 'Origin',
                                    style: AppTheme.titleStyle,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.ticket.formattedDate,
                                    style: AppTheme.bodyStyle,
                                  ),
                                  Text(
                                    widget.ticket.formattedDepartureTime,
                                    style: AppTheme.subtitleStyle,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.flight,
                                    color: AppTheme.primaryColor,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Gate: ${widget.ticket.gate ?? 'TBA'}',
                                    style: AppTheme.captionStyle,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    widget.ticket.destination ?? 'Destination',
                                    style: AppTheme.titleStyle,
                                    textAlign: TextAlign.right,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.ticket.formattedArrivalDate,
                                    style: AppTheme.bodyStyle,
                                    textAlign: TextAlign.right,
                                  ),
                                  Text(
                                    widget.ticket.arrivalTime != null 
                                        ? '${widget.ticket.arrivalTime!.hour.toString().padLeft(2, '0')}:${widget.ticket.arrivalTime!.minute.toString().padLeft(2, '0')}'
                                        : '--:--',
                                    style: AppTheme.subtitleStyle,
                                    textAlign: TextAlign.right,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Share ticket functionality
                  Fluttertoast.showToast(
                    msg: 'Функція поширення квитка',
                    toastLength: Toast.LENGTH_SHORT,
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Поділитися'),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Download ticket functionality
                  _loadPrintableTicket();
                  Fluttertoast.showToast(
                    msg: 'Квиток завантажено',
                    toastLength: Toast.LENGTH_SHORT,
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Завантажити'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
