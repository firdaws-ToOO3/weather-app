import 'package:flutter/material.dart';
import 'city_country.dart';
import 'zip_country.dart';
import 'lat_lon.dart';

/* ---------- โทนชมพู–ม่วง ---------- */
class AppColors {
  static const pink = Color(0xFFEA5CA0);
  static const lilac = Color(0xFFB07BD9);
  static const purple = Color(0xFF7D6EF0);
  static const pinkSoft = Color(0xFFF08BB5);
  static const bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [pinkSoft, lilac, purple],
  );
  static Color glass([double o = .14]) => Colors.white.withOpacity(o);
}

/* ---------- หน่วยอุณหภูมิ (แชร์ทั้งแอพ) ---------- */
enum TempUnit { celsius, fahrenheit, kelvin }
extension UnitExt on TempUnit {
  String? get api => switch (this) {
        TempUnit.celsius => 'metric',
        TempUnit.fahrenheit => 'imperial',
        TempUnit.kelvin => null,
      };
  String get label => switch (this) {
        TempUnit.celsius => '°C',
        TempUnit.fahrenheit => '°F',
        TempUnit.kelvin => 'K',
      };
}

/// InheritedNotifier เก็บ/กระจายค่า TempUnit
class UnitScope extends InheritedNotifier<ValueNotifier<TempUnit>> {
  const UnitScope({super.key, required super.notifier, required super.child});
  static ValueNotifier<TempUnit> of(BuildContext c) =>
      contextDependOn(c).notifier!;
  static UnitScope contextDependOn(BuildContext c) =>
      c.dependOnInheritedWidgetOfExactType<UnitScope>()!;
}

/* ---------- Routes ---------- */
class Routes {
  static const city = '/city';
  static const unit = '/unit';
  static const zip = '/zip';
  static const latlon = '/latlon';
}

void main() => runApp(const WeatherHW4App());

class WeatherHW4App extends StatelessWidget {
  const WeatherHW4App({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.purple,
      primary: AppColors.purple,
      secondary: AppColors.pink,
      brightness: Brightness.light,
    );

    return UnitScope(
      notifier: ValueNotifier(TempUnit.celsius),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Weather HW4',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: scheme,
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white.withOpacity(.95),          // ขาวเกือบทึบ → อ่านง่าย
            labelStyle: const TextStyle(color: Colors.black87),
            hintStyle: const TextStyle(color: Colors.black54),
            prefixIconColor: AppColors.purple,                 // ไอคอนช่องกรอก = ม่วง
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: AppColors.lilac.withOpacity(.45)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: AppColors.pink, width: 1.6),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pink,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              elevation: 6,
            ),
          ),
          segmentedButtonTheme: SegmentedButtonThemeData(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((s) =>
                  s.contains(WidgetState.selected)
                      ? AppColors.lilac.withOpacity(.25)
                      : AppColors.glass(.10)),
              foregroundColor: WidgetStateProperty.resolveWith(
                  (s) => Colors.white.withOpacity(s.contains(WidgetState.selected) ? 1 : .9)),
              side: WidgetStatePropertyAll(
                  BorderSide(color: Colors.white.withOpacity(.35))),
            ),
          ),
        ),
        initialRoute: Routes.latlon, // จะเริ่มที่หน้าไหนก็ได้
        routes: {
          Routes.city: (_) => const CityCountryScreen(),
          Routes.zip: (_) => const ZipCountryScreen(),
          Routes.latlon: (_) => const LatLonScreen(),
        },
      ),
    );
  }
}

/* ---------- Widgets ใช้ซ้ำ ---------- */
class GradientScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? drawer;
  const GradientScaffold({super.key, this.appBar, required this.body, this.drawer});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.bgGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: appBar,
        drawer: drawer,
        body: body,
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const GlassCard({super.key, required this.child, this.padding = const EdgeInsets.all(18)});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.lilac.withOpacity(.25)),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 24, offset: Offset(0, 12))
        ],
      ),
      child: child,
    );
  }
}

class HWDrawer extends StatelessWidget {
  final String current;
  const HWDrawer({super.key, required this.current});
  @override
  Widget build(BuildContext context) {
    TextStyle item(String k) => TextStyle(
      color: Colors.black,
      fontWeight: current == k ? FontWeight.w900 : FontWeight.w600,
    );
    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const ListTile(
                title: Text('Weather App',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                subtitle: Text('City/Zip/LatLon', style: TextStyle(color: Colors.white70)),
              ),
              const SizedBox(height: 8),
              GlassCard(
                padding: EdgeInsets.zero,
                child: Column(children: [
                  ListTile(
                    // ← เปลี่ยนตรงนี้
                    leading: const Icon(Icons.location_city, color: AppColors.purple),
                    title: Text('City and Country', style: item(Routes.city)),
                    onTap: () => Navigator.pushReplacementNamed(context, Routes.city),
                  ),
                  const Divider(color: Colors.white24, height: 1),
                  ListTile(
                    leading: const Icon(Icons.mail_outline, color: AppColors.purple), // ← เดิม Icons.local_post_office
                    title: Text('Zip and Country', style: item(Routes.zip)),
                    onTap: () => Navigator.pushReplacementNamed(context, Routes.zip),
                  ),
                  const Divider(color: Colors.white24, height: 1),
                  ListTile(
                    leading: const Icon(Icons.my_location, color: AppColors.purple),
                    title: Text('Latitude and Longitude', style: item(Routes.latlon)),
                    onTap: () => Navigator.pushReplacementNamed(context, Routes.latlon),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
