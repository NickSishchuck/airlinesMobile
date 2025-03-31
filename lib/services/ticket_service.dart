import 'package:flutter/foundation.dart';
import 'package:airline_app/models/ticket.dart';
import 'package:airline_app/services/api_service.dart';

class TicketService with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Ticket>? _tickets;
  Ticket? _selectedTicket;

  List<Ticket>? get tickets => _tickets;
  Ticket? get selectedTicket => _selectedTicket;

  void setSelectedTicket(Ticket ticket) {
    _selectedTicket = ticket;
    notifyListeners();
  }

  Future<List<Ticket>> getAllTickets({int page = 1, int limit = 10}) async {
    try {
      final response = await _apiService.get('/tickets?page=$page&limit=$limit');
      final List<dynamic> ticketsJson = response['data'];
      _tickets = ticketsJson.map((json) => Ticket.fromJson(json)).toList();
      notifyListeners();
      return _tickets!;
    } catch (e) {
      rethrow;
    }
  }

  Future<Ticket> getTicketById(int id) async {
    try {
      final response = await _apiService.get('/tickets/$id');
      final ticket = Ticket.fromJson(response['data']);
      
      // Update selected ticket if it matches the requested id
      if (_selectedTicket?.ticketId == id) {
        _selectedTicket = ticket;
        notifyListeners();
      }
      
      return ticket;
    } catch (e) {
      rethrow;
    }
  }

  Future<Ticket> getPrintableTicket(int id) async {
    try {
      final response = await _apiService.get('/tickets/$id/print');
      return Ticket.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Ticket>> getTicketsByPassenger(int passengerId) async {
    try {
      final response = await _apiService.get('/tickets/passenger/$passengerId');
      final List<dynamic> ticketsJson = response['data'];
      _tickets = ticketsJson.map((json) => Ticket.fromJson(json)).toList();
      notifyListeners();
      return _tickets!;
    } catch (e) {
      rethrow;
    }
  }

  Future<Ticket> bookTicket({
    required int flightId,
    required String seatNumber,
    required String ticketClass,
    required double price,
  }) async {
    try {
      final response = await _apiService.post('/tickets', {
        'flight_id': flightId,
        'seat_number': seatNumber,
        'class': ticketClass,
        'price': price,
        'payment_status': 'pending',
      });
      
      final newTicket = Ticket.fromJson(response['data']);
      
      // Update ticket list if it exists
      if (_tickets != null) {
        _tickets!.add(newTicket);
        notifyListeners();
      }
      
      return newTicket;
    } catch (e) {
      rethrow;
    }
  }

  Future<Ticket> updateTicket(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put('/tickets/$id', data);
      final updatedTicket = Ticket.fromJson(response['data']);
      
      // Update in local list and selected ticket if applicable
      if (_tickets != null) {
        final index = _tickets!.indexWhere((ticket) => ticket.ticketId == id);
        if (index != -1) {
          _tickets![index] = updatedTicket;
        }
      }
      
      if (_selectedTicket?.ticketId == id) {
        _selectedTicket = updatedTicket;
      }
      
      notifyListeners();
      return updatedTicket;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTicket(int id) async {
    try {
      await _apiService.delete('/tickets/$id');
      
      // Remove from local list if exists
      if (_tickets != null) {
        _tickets!.removeWhere((ticket) => ticket.ticketId == id);
      }
      
      // Clear selected ticket if it was deleted
      if (_selectedTicket?.ticketId == id) {
        _selectedTicket = null;
      }
      
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePaymentStatus(int id, String status) async {
    try {
      await _apiService.patch('/tickets/$id/payment', {
        'payment_status': status,
      });
      
      // Update in local data structures
      if (_tickets != null) {
        final index = _tickets!.indexWhere((ticket) => ticket.ticketId == id);
        if (index != -1) {
          final updatedTicket = await getTicketById(id);
          _tickets![index] = updatedTicket;
        }
      }
      
      if (_selectedTicket?.ticketId == id) {
        _selectedTicket = await getTicketById(id);
      }
      
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
