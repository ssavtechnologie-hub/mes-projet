import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../services/supabase_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        actions: [
          IconButton(icon: const Icon(Iconsax.setting_2), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40.r,
                    backgroundColor: Colors.white,
                    child: Icon(Iconsax.user, size: 40.sp, color: AppTheme.primaryColor),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Jean Dupont',
                    style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Importateur • Sénégal',
                    style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Iconsax.crown, color: Colors.white, size: 16.sp),
                        SizedBox(width: 6.w),
                        Text('Membre Premium', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Stats
            Row(
              children: [
                Expanded(child: _buildStatCard(context, '24', 'Matchs', Iconsax.link)),
                SizedBox(width: 12.w),
                Expanded(child: _buildStatCard(context, '12', 'Transactions', Iconsax.receipt)),
                SizedBox(width: 12.w),
                Expanded(child: _buildStatCard(context, '\$45K', 'Volume', Iconsax.money)),
              ],
            ),
            SizedBox(height: 24.h),

            // Menu items
            _buildMenuItem(context, Iconsax.user_edit, 'Modifier le profil', () {}),
            _buildMenuItem(context, Iconsax.notification, 'Notifications', () => context.push('/notifications')),
            _buildMenuItem(context, Iconsax.document_text, 'Mes rapports', () => context.push('/reports')),
            _buildMenuItem(context, Iconsax.wallet, 'Abonnement', () {}),
            _buildMenuItem(context, Iconsax.message_question, 'Support', () {}),
            _buildMenuItem(context, Iconsax.info_circle, 'À propos', () {}),
            SizedBox(height: 16.h),
            
            // Logout
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await ref.read(supabaseServiceProvider).signOut();
                  if (context.mounted) context.go('/login');
                },
                icon: const Icon(Iconsax.logout, color: AppTheme.errorColor),
                label: const Text('Déconnexion', style: TextStyle(color: AppTheme.errorColor)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.errorColor),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryColor),
          SizedBox(height: 8.h),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      trailing: const Icon(Iconsax.arrow_right_3),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
    );
  }
}
