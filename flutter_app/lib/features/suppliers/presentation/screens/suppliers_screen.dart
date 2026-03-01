import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/theme/app_theme.dart';

class SuppliersScreen extends ConsumerWidget {
  const SuppliersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fournisseurs'),
        actions: [
          IconButton(icon: const Icon(Iconsax.filter), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: 8,
        itemBuilder: (context, index) {
          final isVerified = index % 2 == 0;
          return Container(
            margin: EdgeInsets.only(bottom: 16.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50.w,
                      height: 50.w,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Center(
                        child: Text(
                          'G',
                          style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Guangzhou Tech Co.', style: Theme.of(context).textTheme.titleSmall),
                              if (isVerified) ...[
                                SizedBox(width: 6.w),
                                Icon(Iconsax.verify5, color: AppTheme.accentColor, size: 16.sp),
                              ],
                            ],
                          ),
                          Text('Shenzhen, Chine', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          Icon(Iconsax.star1, color: AppTheme.secondaryColor, size: 14.sp),
                          SizedBox(width: 4.w),
                          Text('4.${8 - index}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 8.w,
                  children: ['Électronique', 'Smartphones', 'Accessoires']
                      .map((cat) => Chip(
                            label: Text(cat, style: TextStyle(fontSize: 10.sp)),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ))
                      .toList(),
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${50 + index * 10} transactions', style: Theme.of(context).textTheme.bodySmall),
                    TextButton.icon(
                      onPressed: () {},
                      icon: Icon(Iconsax.eye, size: 16.sp),
                      label: const Text('Voir'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
