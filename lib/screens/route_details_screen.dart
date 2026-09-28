import 'package:flutter/material.dart';
import '../models/transit_route.dart';

class RouteDetailsScreen extends StatelessWidget {
  final TransitRoute route;

  const RouteDetailsScreen({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الرحلة والخطوات'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // كارت الملخص الكبير والتكلفة الإجمالية
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
              ),
              child: Column(
                children: [
                  Text(
                    route.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryColumn('إجمالي الأجرة', '${route.totalFareEGP} ج.م', Colors.greenAccent),
                      _buildSummaryColumn('الوقت المتوقع', '${route.totalDurationMinutes} دقيقة', Colors.amberAccent),
                      _buildSummaryColumn('نوع المسار', route.transferCount == 0 ? 'مباشر' : 'تحويلة مواصلتين', Colors.lightBlueAccent),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // كارت نصيحة الأسطى
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF451A03), // Amber dark
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.5)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb, color: Color(0xFFF59E0B), size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'نصيحة الأسطى في الموقف والسير:',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF59E0B), fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          route.driverAdvice,
                          style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // عنوان الخطوات
            const Text(
              'خطوات الرحلة خطوة بخطوة (Step-by-Step):',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 14),

            // قائمة الخطوات التفصيلية
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: route.steps.length,
              itemBuilder: (context, index) {
                final step = route.steps[index];
                return _buildStepCard(step, index, index == route.steps.length - 1);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryColumn(String title, String value, Color color) {
    return Column(
      children: [
        Text(title, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildStepCard(TransitStep step, int index, bool isLast) {
    final isMicrobus = step.type == StepType.microbus;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isMicrobus ? const Color(0xFFF59E0B).withOpacity(0.6) : const Color(0xFF334155),
          width: isMicrobus ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس الخطوة (الأيقونة، الرقم، العنوان)
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: isMicrobus ? const Color(0xFFF59E0B) : const Color(0xFF475569),
                child: Icon(
                  isMicrobus ? Icons.directions_bus : Icons.directions_walk,
                  size: 18,
                  color: isMicrobus ? const Color(0xFF0F172A) : Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'الخطوة ${index + 1}: ${step.title}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                ),
              ),
              if (step.durationMinutes > 0)
                Text(
                  '${step.durationMinutes} دقيقة',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // التعليمات العامة
          Text(
            step.instruction,
            style: const TextStyle(color: Colors.white70, fontSize: 13.5, height: 1.4),
          ),

          // تفاصيل الميكروباص إذا كانت الخطوة ميكروباص
          if (isMicrobus) ...[
            const Divider(color: Color(0xFF334155), height: 20),

            // اسم الخط
            if (step.lineName != null)
              _buildDetailRow(Icons.alt_route, 'اسم الخط والسير:', step.lineName!, Colors.amberAccent),

            // شكل اليافطة
            if (step.vehicleSign != null)
              _buildDetailRow(Icons.label, 'لافتة السيارة أو اللون:', step.vehicleSign!, Colors.white70),

            // مكان النزول بالتحديد
            if (step.dropoffStop != null)
              _buildDetailRow(Icons.pin_drop, 'مكان النزول بالتحديد:', step.dropoffStop!, Colors.redAccent),

            // ما يقال للأسطى
            if (step.dropoffAdvice != null)
              _buildDetailRow(Icons.record_voice_over, 'ما تقوله للسواق:', step.dropoffAdvice!, Colors.cyanAccent),

            // أجرة الميكروباص بالجنيه
            _buildDetailRow(
              Icons.monetization_on,
              'أجرة هذا الميكروباص:',
              '${step.fareEGP} جنيه مصري',
              Colors.greenAccent,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: valueColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Colors.white),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12.5, color: valueColor, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
