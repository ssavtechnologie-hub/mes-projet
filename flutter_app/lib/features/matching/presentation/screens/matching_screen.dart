import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../models/score_matching.dart';

class MatchingScreen extends ConsumerStatefulWidget {
  const MatchingScreen({super.key});

  @override
  ConsumerState<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends ConsumerState<MatchingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  List<ScoreMatching> _matches = [];
  String _selectedFilter = 'tous';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMatches();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMatches() async {
    setState(() => _isLoading = true);
    // Simuler le chargement
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _matches = _generateMockMatches();
      _isLoading = false;
    });
  }

  List<ScoreMatching> _generateMockMatches() {
    return [
      ScoreMatching(
        id: '1',
        membreId: 'membre1',
        fournisseurId: 'fournisseur1',
        produitFournisseurId: 'produit1',
        scoreCompatibilite: 0.92,
        scoreBudget: 0.95,
        scoreCategorie: 0.90,
        scoreExperience: 0.88,
        raisonsMatch: ['Budget compatible', 'Catégorie recherchée', 'Fournisseur vérifié'],
        statut: 'nouveau',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now(),
        fournisseurNom: 'Guangzhou Electronics Co.',
        fournisseurFiabilite: 0.95,
        produitNom: 'Smartphones Android',
        produitPrix: 89.99,
      ),
      ScoreMatching(
        id: '2',
        membreId: 'membre1',
        fournisseurId: 'fournisseur2',
        produitFournisseurId: 'produit2',
        scoreCompatibilite: 0.85,
        scoreBudget: 0.80,
        scoreCategorie: 0.90,
        scoreExperience: 0.85,
        raisonsMatch: ['Catégorie d\'intérêt', 'Excellent score de fiabilité'],
        statut: 'vu',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now(),
        fournisseurNom: 'Shanghai Textile Ltd',
        fournisseurFiabilite: 0.92,
        produitNom: 'Vêtements Mode',
        produitPrix: 12.50,
      ),
      ScoreMatching(
        id: '3',
        membreId: 'membre1',
        fournisseurId: 'fournisseur3',
        produitFournisseurId: 'produit3',
        scoreCompatibilite: 0.78,
        scoreBudget: 0.75,
        scoreCategorie: 0.85,
        scoreExperience: 0.70,
        raisonsMatch: ['Budget légèrement dépassé', 'Fournisseur vérifié'],
        statut: 'contacte',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now(),
        fournisseurNom: 'Shenzhen Tech Co.',
        fournisseurFiabilite: 0.88,
        produitNom: 'Accessoires Électroniques',
        produitPrix: 5.99,
      ),
    ];
  }

  Future<void> _runNewMatching() async {
    setState(() => _isLoading = true);
    // Simuler l'appel à l'Edge Function
    await Future.delayed(const Duration(seconds: 2));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Nouveau matching lancé! 3 nouveaux matchs trouvés.'),
        backgroundColor: AppTheme.accentColor,
      ),
    );
    await _loadMatches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Matchs'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.filter),
            onPressed: _showFilterDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tous'),
            Tab(text: 'Nouveaux'),
            Tab(text: 'En cours'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildMatchList(_matches),
                _buildMatchList(_matches.where((m) => m.statut == 'nouveau').toList()),
                _buildMatchList(_matches.where((m) => m.statut == 'contacte' || m.statut == 'en_cours').toList()),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _runNewMatching,
        icon: const Icon(Iconsax.flash),
        label: const Text('Nouveau Matching'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildMatchList(List<ScoreMatching> matches) {
    if (matches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.link,
              size: 64.sp,
              color: AppTheme.textSecondaryLight,
            ),
            SizedBox(height: 16.h),
            Text(
              'Aucun match trouvé',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8.h),
            Text(
              'Lancez un nouveau matching pour trouver des fournisseurs',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMatches,
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: matches.length,
        itemBuilder: (context, index) {
          return _buildMatchCard(matches[index]);
        },
      ),
    );
  }

  Widget _buildMatchCard(ScoreMatching match) {
    final scoreColor = match.scoreCompatibilite >= 0.8
        ? AppTheme.accentColor
        : match.scoreCompatibilite >= 0.6
            ? AppTheme.warningColor
            : AppTheme.textSecondaryLight;

    return GestureDetector(
      onTap: () => context.push('/matching/${match.id}'),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with score
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        match.fournisseurNom ?? 'Fournisseur',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        match.produitNom ?? 'Produit',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: scoreColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Iconsax.star1, color: scoreColor, size: 16.sp),
                      SizedBox(width: 4.w),
                      Text(
                        '${match.scorePercentage}%',
                        style: TextStyle(
                          color: scoreColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Score breakdown
            Row(
              children: [
                _buildScoreIndicator('Budget', match.scoreBudget ?? 0),
                SizedBox(width: 12.w),
                _buildScoreIndicator('Catégorie', match.scoreCategorie ?? 0),
                SizedBox(width: 12.w),
                _buildScoreIndicator('Expérience', match.scoreExperience ?? 0),
              ],
            ),
            SizedBox(height: 16.h),

            // Reasons
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: match.raisonsMatch
                  .take(3)
                  .map((raison) => Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          raison,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ))
                  .toList(),
            ),
            SizedBox(height: 16.h),

            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildStatusChip(match.statut),
                    SizedBox(width: 8.w),
                    if (match.produitPrix != null)
                      Text(
                        '\$${match.produitPrix!.toStringAsFixed(2)}/unité',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Iconsax.message),
                      onPressed: () {},
                      iconSize: 20.sp,
                      color: AppTheme.primaryColor,
                    ),
                    IconButton(
                      icon: const Icon(Iconsax.chart_2),
                      onPressed: () {},
                      iconSize: 20.sp,
                      color: AppTheme.secondaryColor,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreIndicator(String label, double score) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: AppTheme.textSecondaryLight,
            ),
          ),
          SizedBox(height: 4.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: score,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                score >= 0.8
                    ? AppTheme.accentColor
                    : score >= 0.6
                        ? AppTheme.warningColor
                        : AppTheme.textSecondaryLight,
              ),
              minHeight: 6.h,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String statut) {
    Color color;
    String label;

    switch (statut) {
      case 'nouveau':
        color = AppTheme.accentColor;
        label = 'Nouveau';
        break;
      case 'vu':
        color = AppTheme.primaryColor;
        label = 'Vu';
        break;
      case 'contacte':
        color = AppTheme.secondaryColor;
        label = 'Contacté';
        break;
      case 'en_cours':
        color = AppTheme.warningColor;
        label = 'En cours';
        break;
      default:
        color = AppTheme.textSecondaryLight;
        label = statut;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filtrer les matchs',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 24.h),
              _buildFilterOption('Tous les matchs', 'tous'),
              _buildFilterOption('Score > 80%', 'high'),
              _buildFilterOption('Score 60-80%', 'medium'),
              _buildFilterOption('Score < 60%', 'low'),
              SizedBox(height: 24.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String label, String value) {
    final isSelected = _selectedFilter == value;
    return ListTile(
      title: Text(label),
      leading: Radio<String>(
        value: value,
        groupValue: _selectedFilter,
        onChanged: (val) {
          setState(() => _selectedFilter = val!);
          Navigator.pop(context);
        },
      ),
      onTap: () {
        setState(() => _selectedFilter = value);
        Navigator.pop(context);
      },
    );
  }
}
