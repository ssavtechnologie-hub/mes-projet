import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(onPressed: () {}, child: const Text('Tout lire')),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: 10,
        itemBuilder: (context, index) {
          final isRead = index > 2;
          return Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: isRead ? AppTheme.surfaceLight : AppTheme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12.r),
              border: isRead ? null : Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    index % 3 == 0 ? Iconsax.link : index % 3 == 1 ? Iconsax.chart : Iconsax.message,
                    color: AppTheme.primaryColor,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        index % 3 == 0 
                          ? 'Nouveau match trouvé!'
                          : index % 3 == 1 
                            ? 'Analyse terminée'
                            : 'Message reçu',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Description de la notification avec plus de détails...',
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Il y a ${index + 1}h',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
                if (!isRead)
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
