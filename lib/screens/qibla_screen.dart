import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/turkey_cities.dart';
import '../providers/prayer_provider.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> with SingleTickerProviderStateMixin {
  // Kaaba Coordinates (Mecca)
  static const double kaabaLat = 21.422487;
  static const double kaabaLng = 39.826206;

  TurkeyCity _selectedCity = TurkeyCities.all[33]; // Default: İstanbul (plate 34)
  double _manualHeading = 0.0; // Fallback manual dial heading in degrees
  double _smoothHeading = 0.0; // Filtered compass heading from device sensor
  bool _hasSensor = false;
  bool _wasAligned = false;
  StreamSubscription<CompassEvent>? _compassSubscription;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _initCompass();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncWithPrayerProvider();
    });
  }

  void _initCompass() {
    try {
      _compassSubscription = FlutterCompass.events?.listen((CompassEvent event) {
        if (!mounted) return;
        final rawHeading = event.heading;
        if (rawHeading != null) {
          final normalized = (rawHeading + 360.0) % 360.0;
          setState(() {
            _hasSensor = true;
            // Düşük geçiren filtre (Smoothing / lerp) ile sensör titreşimini engelle
            double diff = normalized - _smoothHeading;
            while (diff < -180.0) {
              diff += 360.0;
            }
            while (diff > 180.0) {
              diff -= 360.0;
            }
            _smoothHeading = (_smoothHeading + diff * 0.35 + 360.0) % 360.0;
          });
        }
      });
    } catch (_) {
      _hasSensor = false;
    }
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _syncWithPrayerProvider() {
    final prayerProvider = Provider.of<PrayerProvider>(context, listen: false);
    final locName = prayerProvider.locationName;
    for (final city in TurkeyCities.all) {
      if (locName.toLowerCase().contains(city.name.toLowerCase())) {
        setState(() {
          _selectedCity = city;
        });
        break;
      }
    }
  }

  // Calculate Forward Azimuth / Bearing to Kaaba in Degrees
  double _calculateQiblaBearing(double lat, double lng) {
    final lat1 = lat * (math.pi / 180.0);
    final lng1 = lng * (math.pi / 180.0);
    final lat2 = kaabaLat * (math.pi / 180.0);
    final lng2 = kaabaLng * (math.pi / 180.0);

    final dLng = lng2 - lng1;
    final y = math.sin(dLng) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLng);

    double bearing = math.atan2(y, x) * (180.0 / math.pi);
    return (bearing + 360.0) % 360.0;
  }

  // Calculate Haversine Distance in Kilometers
  double _calculateDistanceToKaaba(double lat, double lng) {
    const double r = 6371; // Earth radius in km
    final dLat = (kaabaLat - lat) * (math.pi / 180.0);
    final dLng = (kaabaLng - lng) * (math.pi / 180.0);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat * (math.pi / 180.0)) *
            math.cos(kaabaLat * (math.pi / 180.0)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  String _getDirectionName(double angle) {
    if (angle >= 337.5 || angle < 22.5) return 'Kuzey (N)';
    if (angle >= 22.5 && angle < 67.5) return 'Kuzeydoğu (NE)';
    if (angle >= 67.5 && angle < 112.5) return 'Doğu (E)';
    if (angle >= 112.5 && angle < 157.5) return 'Güneydoğu (SE)';
    if (angle >= 157.5 && angle < 202.5) return 'Güney (S)';
    if (angle >= 202.5 && angle < 247.5) return 'Güneybatı (SW)';
    if (angle >= 247.5 && angle < 292.5) return 'Batı (W)';
    return 'Kuzeybatı (NW)';
  }

  void _showCitySelectModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        String query = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final cities = TurkeyCities.search(query);
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: AppColors.bgDark1,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(top: BorderSide(color: AppColors.goldPrimary, width: 1.5)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Kıble İçin Şehir Seçin',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Şehir ara...',
                        hintStyle: const TextStyle(color: AppColors.textSecondary),
                        prefixIcon: const Icon(Icons.search, color: AppColors.goldPrimary),
                        filled: true,
                        fillColor: AppColors.cardBg,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.glassBorder),
                        ),
                      ),
                      onChanged: (val) {
                        setModalState(() {
                          query = val;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: cities.length,
                      itemBuilder: (ctx, i) {
                        final c = cities[i];
                        final isSelected = c.plate == _selectedCity.plate;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isSelected ? AppColors.goldPrimary : AppColors.cardBg,
                            child: Text(
                              c.plate.toString().padLeft(2, '0'),
                              style: TextStyle(
                                color: isSelected ? AppColors.bgDark1 : AppColors.goldLight,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          title: Text(
                            c.name,
                            style: TextStyle(
                              color: isSelected ? AppColors.goldGlow : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle, color: AppColors.goldGlow)
                              : null,
                          onTap: () {
                            setState(() {
                              _selectedCity = c;
                            });
                            Navigator.pop(ctx);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeHeading = _hasSensor ? _smoothHeading : _manualHeading;
    final qiblaBearing = _calculateQiblaBearing(_selectedCity.lat, _selectedCity.lng);
    final distance = _calculateDistanceToKaaba(_selectedCity.lat, _selectedCity.lng);

    // Difference between user orientation heading (top of phone) and Kaaba bearing
    final angleDiff = ((qiblaBearing - activeHeading + 540) % 360) - 180;
    final isAligned = angleDiff.abs() <= 5.0;

    // Telefon Kabe doğrultusuna girdiğinde haptic titreşim ver
    if (isAligned && !_wasAligned) {
      _wasAligned = true;
      HapticFeedback.heavyImpact();
    } else if (!isAligned && _wasAligned) {
      _wasAligned = false;
    }

    return Scaffold(
      backgroundColor: AppColors.bgDark1,
      appBar: AppBar(
        title: const Text(
          'Kıble Pusulası',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: AppColors.goldPrimary),
            tooltip: 'Hizala',
            onPressed: () {
              setState(() {
                _manualHeading = qiblaBearing; // Auto-align with one click
                _smoothHeading = qiblaBearing;
              });
              HapticFeedback.mediumImpact();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // City Selector Chip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: InkWell(
                onTap: _showCitySelectModal,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on, color: AppColors.goldGlow, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${_selectedCity.name} (${_selectedCity.plate.toString().padLeft(2, '0')})',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.keyboard_arrow_down, color: AppColors.goldGlow, size: 20),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Alignment Status Banner
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isAligned
                    ? AppColors.emeraldDark.withValues(alpha: 0.6)
                    : AppColors.cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isAligned ? AppColors.emeraldAccent : AppColors.glassBorder,
                  width: isAligned ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isAligned ? Icons.check_circle : Icons.explore,
                    color: isAligned ? AppColors.emeraldAccent : AppColors.goldPrimary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isAligned
                        ? 'KIBLE YÖNÜNDESİNİZ (TAM HİZA)'
                        : 'Kıbleye Kalan Açı: ${angleDiff.abs().toStringAsFixed(0)}° ${angleDiff > 0 ? "Sağda" : "Solda"}',
                    style: TextStyle(
                      color: isAligned ? AppColors.emeraldAccent : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Visual Compass Circle
            Center(
              child: GestureDetector(
                onPanUpdate: (details) {
                  if (!_hasSensor) {
                    setState(() {
                      _manualHeading = (_manualHeading + details.delta.dx * 0.5) % 360;
                      if (_manualHeading < 0) _manualHeading += 360;
                    });
                  }
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer glow circle
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          width: 290,
                          height: 290,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (isAligned ? AppColors.emeraldAccent : AppColors.goldPrimary)
                                    .withValues(alpha: isAligned ? (0.2 + 0.15 * _pulseController.value) : 0.15),
                                blurRadius: 28,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    // Rotating Compass Dial (Telefon döndükçe kadran ters açıyla döner, Kuzey sabit kalır)
                    Transform.rotate(
                      angle: -activeHeading * (math.pi / 180.0),
                      child: Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(
                            colors: [AppColors.bgDark3, AppColors.bgDark1],
                          ),
                          border: Border.all(
                            color: isAligned ? AppColors.emeraldAccent : AppColors.goldPrimary,
                            width: 2.5,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Cardinal Directions (N, E, S, W)
                            const Positioned(
                              top: 10,
                              child: Text(
                                'K',
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const Positioned(
                              right: 12,
                              child: Text(
                                'D',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const Positioned(
                              bottom: 10,
                              child: Text(
                                'G',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const Positioned(
                              left: 12,
                              child: Text(
                                'B',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),

                            // Minor ticks and degree rings
                            CustomPaint(
                              size: const Size(280, 280),
                              painter: _CompassTicksPainter(),
                            ),

                            // KAABA POINTER (Attached at the exact Qibla bearing on the dial!)
                            Transform.rotate(
                              angle: qiblaBearing * (math.pi / 180.0),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Pointer Needle
                                  Positioned(
                                    top: 36,
                                    child: Container(
                                      width: 4,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: AppColors.goldGlow,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                  // Kaaba Badge Indicator
                                  Positioned(
                                    top: 18,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: AppColors.goldGlow, width: 2),
                                      ),
                                      child: const Icon(
                                        Icons.mosque,
                                        color: AppColors.goldGlow,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Center Hub with Heading Display
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.bgDark1,
                        border: Border.all(
                          color: isAligned ? AppColors.emeraldAccent : AppColors.goldPrimary,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${activeHeading.toStringAsFixed(0)}°',
                              style: TextStyle(
                                color: isAligned ? AppColors.emeraldAccent : AppColors.goldGlow,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              _getDirectionName(activeHeading).split(' ').first,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Top Orientation Marker (Phone Top Reference - Like Google Maps)
                    Positioned(
                      top: 4,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: isAligned ? AppColors.emeraldAccent : Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),
            Text(
              _hasSensor
                  ? 'Telefonunuzun üst kısmını Kabe ikonuna doğru çeviriniz (Google Maps gibi).'
                  : 'Sensör bulunamadı; pusulayı elle döndürebilirsiniz.',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // Statistics Grid (Kıble Açısı & Mesafe)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.navigation, color: AppColors.goldPrimary, size: 22),
                          const SizedBox(height: 6),
                          const Text(
                            'Kıble Açısı',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${qiblaBearing.toStringAsFixed(1)}°',
                            style: const TextStyle(
                              color: AppColors.goldGlow,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            _getDirectionName(qiblaBearing),
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.straighten, color: AppColors.emeraldAccent, size: 22),
                          const SizedBox(height: 6),
                          const Text(
                            'Mekke\'ye Mesafe',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${distance.toStringAsFixed(0)} km',
                            style: const TextStyle(
                              color: AppColors.emeraldAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const Text(
                            'Kuş Uçuşu',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Educational / Guide Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.bgDark3, AppColors.emeraldDark],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline, color: AppColors.goldGlow, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Türkiye\'de kıble genellikle Güneydoğu (140° - 165°) istikametindedir. Telefonunuzu düz bir zemine koyarak Kabe ikonunun tam üst noktaya hizalanmasını sağlayınız.',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// Custom Painter for subtle degree markers on the compass dial
class _CompassTicksPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..color = AppColors.goldLight.withValues(alpha: 0.3)
      ..strokeWidth = 1;

    for (int i = 0; i < 360; i += 30) {
      final rad = i * (math.pi / 180.0);
      final p1 = Offset(
        center.dx + (radius - 14) * math.cos(rad),
        center.dy + (radius - 14) * math.sin(rad),
      );
      final p2 = Offset(
        center.dx + (radius - 4) * math.cos(rad),
        center.dy + (radius - 4) * math.sin(rad),
      );
      canvas.drawLine(p1, p2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
