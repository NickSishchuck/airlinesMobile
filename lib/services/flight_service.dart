import 'package:flutter/foundation.dart';
import 'package:airline_app/models/flight.dart';
import 'package:airline_app/models/route.dart' as flight_route;
import 'package:airline_app/services/api_service.dart';

class FlightService with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Flight>? _flights;
  Flight? _selectedFlight;
  List<flight_route.Route>? _routes;

  List<Flight>? get flights => _flights;
  Flight? get selectedFlight => _selectedFlight;
  List<flight_route.Route>? get routes => _routes;

  void setSelectedFlight(Flight flight) {
    _selectedFlight = flight;
    notifyListeners();
  }

  Future<List<Flight>> getAllFlights({int page = 1, int limit = 10}) async {
    try {
      final response = await _apiService.get('/flights?page=$page&limit=$limit');
      final List<dynamic> flightsJson = response['data'];
      _flights = flightsJson.map((json) => Flight.fromJson(json)).toList();
      notifyListeners();
      return _flights!;
    } catch (e) {
      rethrow;
    }
  }

  Future<Flight> getFlightById(int id) async {
    try {
      final response = await _apiService.get('/flights/$id');
      final flight = Flight.fromJson(response['data']);
      
      // Update selected flight if it matches the requested id
      if (_selectedFlight?.flightId == id) {
        _selectedFlight = flight;
        notifyListeners();
      }
      
      return flight;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Flight>> searchFlightsByRouteAndDate(
      String origin, String destination, String date) async {
    try {
      final response = await _apiService.get(
          '/flights/search/by-route-date?origin=$origin&destination=$destination&date=$date');
      final List<dynamic> flightsJson = response['data'];
      _flights = flightsJson.map((json) => Flight.fromJson(json)).toList();
      notifyListeners();
      return _flights!;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Flight>> generateFlightSchedule(
      String startDate, String endDate) async {
    try {
      final response = await _apiService
          .get('/flights/schedule/generate?startDate=$startDate&endDate=$endDate');
      final List<dynamic> flightsJson = response['data'];
      final scheduleFlights = flightsJson.map((json) => Flight.fromJson(json)).toList();
      return scheduleFlights;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<flight_route.Route>> getAllRoutes() async {
    try {
      final response = await _apiService.get('/routes');
      final List<dynamic> routesJson = response['data'];
      _routes = routesJson.map((json) => flight_route.Route.fromJson(json)).toList();
      notifyListeners();
      return _routes!;
    } catch (e) {
      rethrow;
    }
  }

  Future<flight_route.Route> getRouteById(int id) async {
    try {
      final response = await _apiService.get('/routes/$id');
      return flight_route.Route.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }
}
