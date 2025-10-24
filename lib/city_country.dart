import 'package:flutter/material.dart';
import 'package:homework4_052/unit_only.dart';
import '../main.dart';
import '../weather_service.dart';

class CityCountryScreen extends StatefulWidget {
  const CityCountryScreen({super.key});
  @override
  State<CityCountryScreen> createState() => _CityCountryScreenState();
}

class _CityCountryScreenState extends State<CityCountryScreen> {
  final _city = TextEditingController();
  final _country = TextEditingController(text: 'TH');
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic>? _data;
  String? _error;
  bool _loading = false;

  @override
  void dispose() { _city.dispose(); _country.dispose(); super.dispose(); }

  Future<void> _fetch() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; _data = null; });
    try {
      final unit = UnitScope.of(context).value;
      final j = await WeatherService.byCityCountry(
        city: _city.text.trim(),
        country: _country.text.trim(),
        unit: unit,
      );
      setState(() => _data = j);
    } catch (e) { setState(() => _error = e.toString()); }
    finally { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    final unit = UnitScope.of(context).value;
    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, centerTitle: true,
        title: const Text('City and Country', style: TextStyle(color: Colors.white)),
      ),
      drawer: const HWDrawer(current: Routes.city),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            GlassCard(
              child: Form(
                key: _formKey,
                child: Column(children: [
                  TextFormField(
                    controller: _city,
                    decoration: const InputDecoration(
                      labelText: 'City', prefixIcon: Icon(Icons.location_city),
                    ),
                    validator: (t) =>
                        (t == null || t.trim().isEmpty) ? 'กรอกชื่อเมือง' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _country,
                    decoration: const InputDecoration(
                      labelText: 'Country Code (ISO-2)', prefixIcon: Icon(Icons.flag),
                    ),
                    validator: (t) =>
                        (t == null || t.trim().length != 2) ? 'เช่น TH, US' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.thermostat, color: Colors.black54),
                      const SizedBox(width: 8),
                      Text('Unit: ${unit.label}',
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      const Spacer(),
                      TextButton(
                        onPressed: () async {
                          await showUnitPicker(context);
                          // ถ้าต้องการ refresh UI หลังเลือก (บางหน้าต้องดึงค่าใหม่) ให้ setState()
                        },
                        child: const Text('Change'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : _fetch,
                      icon: const Icon(Icons.search_rounded),
                      label: const Text('Search'),
                    ),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            if (_loading) const CircularProgressIndicator(),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            if (_data != null) _ResultCard(data: _data!, unit: unit),
          ]),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final TempUnit unit;
  const _ResultCard({required this.data, required this.unit});

  String _fmt(num v) => switch (unit) {
    TempUnit.celsius => '${v.toStringAsFixed(1)} °C',
    TempUnit.fahrenheit => '${v.toStringAsFixed(1)} °F',
    TempUnit.kelvin => '${v.toStringAsFixed(1)} K',
  };

  IconData _weatherIcon(String? main) {
    switch ((main ?? '').toLowerCase()) {
      case 'clear': return Icons.wb_sunny_rounded;
      case 'clouds': return Icons.cloud_rounded;
      case 'rain': return Icons.umbrella_rounded;
      case 'drizzle': return Icons.grain_rounded;
      case 'thunderstorm': return Icons.thunderstorm_rounded;
      case 'snow': return Icons.ac_unit_rounded;
      case 'mist':
      case 'haze':
      case 'fog': return Icons.dehaze_rounded;
      default: return Icons.wb_cloudy_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = (data['weather'] as List?)?.isNotEmpty == true ? data['weather'][0] : null;
    final main = w?['main']?.toString();
    final desc = w?['description']?.toString();
    final temp = data['main']?['temp'];
    final feels = data['main']?['feels_like'];
    final humidity = data['main']?['humidity'];
    final wind = data['wind']?['speed'];

    return GlassCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.lilac.withOpacity(.2),
              child: Icon(_weatherIcon(main), color: AppColors.pink, size: 26),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text('${data['name'] ?? '-'}',
                  style: Theme.of(context).textTheme.titleLarge),
            ),
            Text(temp == null ? '-' : _fmt(temp),
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: AppColors.purple, fontWeight: FontWeight.w900)),
          ],
        ),
        const SizedBox(height: 6),
        Text('${main ?? '-'} • ${desc ?? '-'}',
            style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 12),
        Row(children: [
          _infoChip(Icons.thermostat, 'Feels', feels == null ? '-' : _fmt(feels)),
          const SizedBox(width: 8),
          _infoChip(Icons.water_drop_outlined, 'Humidity', '${humidity ?? '-'} %'),
          const SizedBox(width: 8),
          _infoChip(Icons.air_rounded, 'Wind', '${wind ?? '-'} m/s'),
        ]),
      ]),
    );
  }

  Expanded _infoChip(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.lilac.withOpacity(.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.lilac.withOpacity(.45)),
        ),
        child: Row(children: [
          Icon(icon, size: 18, color: AppColors.pink),
          const SizedBox(width: 6),
          Expanded(
            child: Text('$label: $value',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ]),
      ),
    );
  }
}
