import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:airline_app/services/ticket_service.dart';
import 'package:airline_app/services/auth_service.dart';
import 'package:airline_app/widgets/ticket_card.dart';
import 'package:airline_app/screens/flight/search_screen.dart';
import 'package:airline_app/screens/flight/flight_board_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:airline_app/screens/auth/login_screen.dart';

class TicketListScreen extends StatefulWidget {
  const TicketListScreen({Key? key}) : super(key: key);

  @override
  State<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTickets();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadTickets() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final ticketService = Provider.of<TicketService>(context, listen: false);

      // Make sure we're authenticated first
      bool isAuthenticated = await authService.isAuthenticated();

      if (!isAuthenticated) {
        // If not authenticated, redirect to login
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
          );
        }
        return;
      }

      // Force refresh user info before proceeding
      await authService.getCurrentUser();
      final user = authService.currentUser;

      if (user != null && user.userId != null) {
        await ticketService.getTicketsByPassenger(user.userId!);
      } else {
        throw Exception('Не вдалося отримати інформацію про користувача');
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Помилка завантаження квитків: ${e.toString()}',
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
    final ticketService = Provider.of<TicketService>(context);
    final tickets = ticketService.tickets;

    return Scaffold(
      backgroundColor: Colors.blue[800],
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: const Text('Квитки та підписки'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Активні'),
            Tab(text: 'Архив'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : TabBarView(
              controller: _tabController,
              children: [
                // Active tickets tab
                tickets == null || tickets.isEmpty
                    ? const Center(
                        child: Text(
                          'Немає активних квитків',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadTickets,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: tickets.length,
                          itemBuilder: (context, index) {
                            return TicketCard(ticket: tickets[index]);
                          },
                        ),
                      ),
                
                // Archive tab
                const Center(
                  child: Text(
                    'Історія квитків',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SearchScreen()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
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
