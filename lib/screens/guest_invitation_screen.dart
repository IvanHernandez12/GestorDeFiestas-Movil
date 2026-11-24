/*
 * @empresa Bigbitbyte
 * @autor Ivan Hernandez Hinojosa
 * @creado 24/noviembre/2026
 * @modificado 24/noviembre/2026
 * @descripción Muestra la invitación, el mapa del salón y el álbum del evento.
 */

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_ui/material_ui.dart';

class GuestInvitationScreen extends StatefulWidget {
  const GuestInvitationScreen({required this.data, super.key});

  final Map<String, dynamic> data;

  @override
  State<GuestInvitationScreen> createState() => _GuestInvitationScreenState();
}

class _GuestInvitationScreenState extends State<GuestInvitationScreen> {
  int _selectedTabIndex = 0;

  Map<String, dynamic> get _guest => _asMap(widget.data['guest']);

  Map<String, dynamic> get _event => _asMap(widget.data['event']);

  Map<String, dynamic> get _venue => _asMap(widget.data['venue']);

  double? get _latitude => _asDouble(_venue['lat']);

  double? get _longitude => _asDouble(_venue['lng']);

  bool get _hasVenueCoordinates => _latitude != null && _longitude != null;

  @override
  Widget build(BuildContext context) {
    final venuePosition = _hasVenueCoordinates
        ? LatLng(_latitude!, _longitude!)
        : const LatLng(19.2826, -99.6557);

    return Scaffold(
      appBar: AppBar(title: const Text('Mi invitación')),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedTabIndex,
          children: [
            _buildInvitationTab(),
            _buildDirectionsTab(venuePosition),
            _buildAlbumTab(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTabIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedTabIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.mail_outline),
            selectedIcon: Icon(Icons.mail),
            label: 'Invitación',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Cómo llegar',
          ),
          NavigationDestination(
            icon: Icon(Icons.photo_library_outlined),
            selectedIcon: Icon(Icons.photo_library),
            label: 'Álbum',
          ),
        ],
      ),
    );
  }

  Widget _buildInvitationTab() {
    final eventName = _event['name']?.toString() ?? 'Evento';
    final venueName = _venue['name']?.toString() ?? 'Salón por confirmar';
    final venueAddress = _venue['address']?.toString() ?? '';
    final guestName = _guest['name']?.toString() ?? 'Invitado';
    final guestCategory = _guest['category']?.toString();
    final eventDate = _formatEventDate(_event['date']?.toString());
    final rules = _event['rules']?.toString().trim() ?? '';

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ESTÁS INVITADO',
                style: TextStyle(
                  color: Color(0xFF1D4ED8),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                eventName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFF0F172A),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hola, $guestName',
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (guestCategory != null && guestCategory.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  guestCategory,
                  style: const TextStyle(color: Color(0xFF64748B)),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        _DetailCard(
          icon: Icons.calendar_month_outlined,
          title: 'Fecha',
          value: eventDate,
        ),
        const SizedBox(height: 12),
        _DetailCard(
          icon: Icons.location_on_outlined,
          title: venueName,
          value: venueAddress.isEmpty
              ? 'Dirección no disponible'
              : venueAddress,
        ),
        const SizedBox(height: 16),
        Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reglamento del evento',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  rules.isEmpty ? 'No se especificó un reglamento.' : rules,
                  style: const TextStyle(color: Color(0xFF475569), height: 1.5),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDirectionsTab(LatLng venuePosition) {
    final venueName = _venue['name']?.toString() ?? 'Salón del evento';
    final venueAddress = _venue['address']?.toString() ?? '';
    final markers = _hasVenueCoordinates
        ? <Marker>{
            Marker(
              markerId: const MarkerId('event-venue'),
              position: venuePosition,
              infoWindow: InfoWindow(title: venueName, snippet: venueAddress),
            ),
          }
        : <Marker>{};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                venueName,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (venueAddress.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  venueAddress,
                  style: const TextStyle(color: Color(0xFF64748B)),
                ),
              ],
              if (!_hasVenueCoordinates) ...[
                const SizedBox(height: 8),
                const Text(
                  'El salón no incluye coordenadas; se muestra Toluca como referencia.',
                  style: TextStyle(color: Color(0xFFB45309)),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: GoogleMap(
            mapId: '9cb338dac44e1caf2da4e3dd',
            initialCameraPosition: CameraPosition(
              target: venuePosition,
              zoom: _hasVenueCoordinates ? 16 : 12,
            ),
            markers: markers,
            myLocationButtonEnabled: false,
            mapToolbarEnabled: true,
          ),
        ),
      ],
    );
  }

  Widget _buildAlbumTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.photo_library_outlined,
              color: Color(0xFF64748B),
              size: 56,
            ),
            const SizedBox(height: 12),
            Text(
              _event['name']?.toString() ?? 'Álbum del evento',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Aún no hay fotos en el álbum.',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF2563EB)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Map<String, dynamic> _asMap(Object? value) {
  return value is Map<String, dynamic> ? value : <String, dynamic>{};
}

double? _asDouble(Object? value) {
  if (value is num) {
    return value.toDouble();
  }

  if (value is String) {
    return double.tryParse(value);
  }

  return null;
}

String _formatEventDate(String? rawDate) {
  final parsedDate = DateTime.tryParse(rawDate ?? '');
  if (parsedDate == null) {
    return 'Fecha no disponible';
  }

  const months = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];

  return '${parsedDate.day} de ${months[parsedDate.month - 1]} de ${parsedDate.year}';
}
