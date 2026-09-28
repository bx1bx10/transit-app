import 'package:flutter/material.dart';
import '../data/mock_routes.dart';
import '../models/transit_route.dart';
import 'route_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destController = TextEditingController();
  String _selectedCity = 'all'; // 'all', 'portsaid', 'cairo'
  List<TransitRoute> _filteredRoutes = [];
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _filteredRoutes = mockRoutes;
  }

  void _searchRoutes() {
    final originText = _originController.text.trim().toLowerCase();
    final destText = _destController.text.trim().toLowerCase();

    setState(() {
      _hasSearched = true;
      _filteredRoutes = mockRoutes.where((route) {
        // فلتر المدينة
        if (_selectedCity != 'all' && route.cityId != _selectedCity) {
          return false;
        }

        // لو الحقول فاضية، اعرض الكل الخاص بالمدينة
        if (originText.isEmpty && destText.isEmpty) {
          return true;
        }

        final matchOrigin = originText.isEmpty ||
            route.origin.toLowerCase().contains(originText) ||
            route.keywords.any((k) => k.toLowerCase().contains(originText));

        final matchDest = destText.isEmpty ||
            route.destination.toLowerCase().contains(destText) ||
            route.keywords.any((k) => k.toLowerCase().contains(destText));

        return matchOrigin && matchDest;
      }).toList();
    });
  }

  void _swapLocations() {
    setState(() {
      final temp = _originController.text;
      _originController.text = _destController.text;
      _destController.text = temp;
    });
    _searchRoutes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.directions_bus, color: Color(0xFF0F172A), size: 22),
            ),
            const SizedBox(width: 10),
            const Text(
              'مساعد المواصلات الذكي',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // شريط اختيار المدينة
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCityChip('all', 'جميع المدن 🇪🇬'),
                  const SizedBox(width: 8),
                  _buildCityChip('portsaid', 'بورسعيد ⚓'),
                  const SizedBox(width: 8),
                  _buildCityChip('cairo', 'القاهرة 🏛️'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // كارت إدخال البداية والنهاية
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF334155)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // مكان البداية
                  TextField(
                    controller: _originController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.my_location, color: Colors.greenAccent),
                      labelText: 'أنا فين؟ (مكان البداية)',
                      hintText: 'مثال: حي الزهور، رمسيس، شبرا...',
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // زر التبديل
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: _swapLocations,
                      icon: const Icon(Icons.swap_vert, color: Color(0xFFF59E0B)),
                      tooltip: 'تبديل مكان البداية والنهاية',
                    ),
                  ),

                  // مكان النهاية
                  TextField(
                    controller: _destController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.location_on, color: Colors.redAccent),
                      labelText: 'عايز أروح فين؟ (مكان الوصول)',
                      hintText: 'مثال: ديليسيبس، التجمع، المعادي...',
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // زر ابحث عن الطريق
                  ElevatedButton(
                    onPressed: _searchRoutes,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      foregroundColor: const Color(0xFF0F172A),
                      minimumSize: const Size(double.infinity, 52),
                      shape: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 22, color: Color(0xFF0F172A)),
                        SizedBox(width: 8),
                        Text(
                          'ابحث عن الطريق',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // عنوان قسم النتائج
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _hasSearched ? 'المسارات المتاحة (${_filteredRoutes.length})' : 'خطوط مقترحة وشائعة',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  _selectedCity == 'portsaid' ? 'بورسعيد' : (_selectedCity == 'cairo' ? 'القاهرة' : 'كل المدن'),
                  style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // قائمة النتائج
            if (_filteredRoutes.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.route_outlined, size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    const Text(
                      'لم يتم العثور على خط مباشر لهذه الكلمات',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'جرب كتابة اسم الحي الرئيسي مثل "رمسيس" أو "الزهور" أو اختر من المدن أعلاه.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[400], fontSize: 13),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredRoutes.length,
                itemBuilder: (context, index) {
                  final route = _filteredRoutes[index];
                  return _buildRouteCard(route);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCityChip(String cityId, String title) {
    final isSelected = _selectedCity == cityId;
    return ChoiceChip(
      label: Text(title),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCity = cityId;
        });
        _searchRoutes();
      },
      selectedColor: const Color(0xFFF59E0B),
      backgroundColor: const Color(0xFF1E293B),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF0F172A) : Colors.white,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildRouteCard(TransitRoute route) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFF334155)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RouteDetailsScreen(route: route),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الشارة والمدينة
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFF59E0B)),
                    ),
                    child: Text(
                      route.tag,
                      style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    route.cityName,
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // العنوان
              Text(
                route.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 12),

              // الأجرة والوقت وعدد المواصلات
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.payments, size: 18, color: Colors.greenAccent),
                      const SizedBox(width: 4),
                      Text(
                        '${route.totalFareEGP} ج.م',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent, fontSize: 16),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.timer, size: 18, color: Colors.amberAccent),
                      const SizedBox(width: 4),
                      Text(
                        '${route.totalDurationMinutes} دقيقة',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        route.transferCount == 0 ? Icons.directions_bus : Icons.sync_alt,
                        size: 18,
                        color: Colors.lightBlueAccent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        route.transferCount == 0 ? 'ميكروباص واحد' : 'ميكروباصان (تحويلة)',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
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
