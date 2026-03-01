// Placeholder screens for Flutter app
// These files need to be implemented based on the full app requirements

// ============================================================
// /lib/features/home/presentation/screens/home_screen.dart
// ============================================================
import 'package:flutter/material.dart';
export '../../../dashboard/presentation/screens/dashboard_screen.dart';

// ============================================================
// /lib/features/products/presentation/screens/products_screen.dart
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/theme/app_theme.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produits Afrique'),
        actions: [
          IconButton(icon: const Icon(Iconsax.filter), onPressed: () {}),
          IconButton(icon: const Icon(Iconsax.search_normal), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(Iconsax.box, color: AppTheme.primaryColor),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Produit ${index + 1}', style: Theme.of(context).textTheme.titleSmall),
                      Text('Sénégal • Électronique', style: Theme.of(context).textTheme.bodySmall),
                      SizedBox(height: 4.h),
                      Text('\$150.00', style: TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Icon(Iconsax.arrow_right_3, color: AppTheme.textSecondaryLight),
              ],
            ),
          );
        },
      ),
    );
  }
}
