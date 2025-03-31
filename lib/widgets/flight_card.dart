import 'package:flutter/material.dart';
import 'package:airline_app/models/flight.dart';
import 'package:airline_app/theme/app_theme.dart';

class FlightCard extends StatelessWidget {
  final Flight flight;
  final Function? onTap;
  final bool showDetails;

  const FlightCard({
    Key? key,
    required this.flight,
    this.onTap,
    this.showDetails = false,
  }) : super(key: key);

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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: InkWell(
        onTap: onTap != null ? () => onTap!() : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Flight number and time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    flight.flightNumber ?? 'Flight',
                    style: AppTheme.titleStyle,
                  ),
                  Text(
                    flight.formattedDepartureTime,
                    style: AppTheme.titleStyle,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Origin to Destination
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          flight.origin ?? 'Origin',
                          style: AppTheme.subtitleStyle,
                        ),
                      ],
                    ),
                  ),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          flight.destination ?? 'Destination',
                          style: AppTheme.subtitleStyle,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Flight details (gate, status)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.door_front_door,
                        size: 16,
                        color: AppTheme.secondaryTextColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Gate: ${flight.gate ?? "TBA"}',
                        style: AppTheme.captionStyle,
                      ),
                    ],
                  ),
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
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              
              // Additional details if requested
              if (showDetails) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                
                // Aircraft details
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Літак',
                            style: TextStyle(
                              color: AppTheme.secondaryTextColor,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            flight.aircraftModel ?? 'N/A',
                            style: AppTheme.bodyStyle,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Реєстраційний номер',
                            style: TextStyle(
                              color: AppTheme.secondaryTextColor,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            flight.registrationNumber ?? 'N/A',
                            style: AppTheme.bodyStyle,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Captain and available seats
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Капітан',
                            style: TextStyle(
                              color: AppTheme.secondaryTextColor,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            flight.captainName ?? 'N/A',
                            style: AppTheme.bodyStyle,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Місць доступно',
                            style: TextStyle(
                              color: AppTheme.secondaryTextColor,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            flight.bookedSeats != null && flight.totalCapacity != null
                                ? '${flight.totalCapacity! - flight.bookedSeats!} з ${flight.totalCapacity}'
                                : 'N/A',
                            style: AppTheme.bodyStyle,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
