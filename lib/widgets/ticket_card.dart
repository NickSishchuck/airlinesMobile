import 'package:flutter/material.dart';
import 'package:airline_app/models/ticket.dart';
import 'package:airline_app/screens/ticket/ticket_detail_screen.dart';
import 'package:airline_app/theme/app_theme.dart';

class TicketCard extends StatelessWidget {
  final Ticket ticket;
  
  const TicketCard({
    Key? key,
    required this.ticket,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TicketDetailScreen(ticket: ticket),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Ticket class and name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Назва билета, ${ticket.ticketClass == 'economy' ? 'Economy' : ticket.ticketClass == 'business' ? 'Business' : 'First'} Cl.',
                          style: AppTheme.titleStyle,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: AppTheme.secondaryTextColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Україна',
                              style: AppTheme.captionStyle,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Validity period
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppTheme.secondaryTextColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Дійсний до ${ticket.formattedArrivalDate}',
                    style: AppTheme.captionStyle,
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              
              // Flight details
              Row(
                children: [
                  // Origin - Destination
                  Expanded(
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ticket.origin ?? 'Origin',
                              style: AppTheme.subtitleStyle,
                            ),
                            Text(
                              ticket.formattedDate,
                              style: AppTheme.captionStyle,
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Divider(
                                thickness: 1,
                                color: AppTheme.dividerColor,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                color: Colors.white,
                                child: const Icon(
                                  Icons.flight,
                                  size: 16,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ticket.destination ?? 'Destination',
                              style: AppTheme.subtitleStyle,
                            ),
                            Text(
                              ticket.formattedArrivalDate,
                              style: AppTheme.captionStyle,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
