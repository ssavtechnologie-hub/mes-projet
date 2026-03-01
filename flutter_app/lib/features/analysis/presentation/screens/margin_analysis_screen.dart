import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../models/analyse_marge.dart';

class MarginAnalysisScreen extends ConsumerStatefulWidget {
  const MarginAnalysisScreen({super.key});

  @override
  ConsumerState<MarginAnalysisScreen> createState() => _MarginAnalysisScreenState();
}

class _MarginAnalysisScreenState extends ConsumerState<MarginAnalysisScreen> {
  bool _isLoading = false;
  bool _isCalculating = false;
  AnalyseMarge? _currentAnalysis;
  
  // Form controllers
  final _quantiteController = TextEditingController(text: '100');
  final _transportController = TextEditingController(text: '500');
  final _logistiqueController = TextEditingController(text: '200');
  
  String? _selectedProduitAfrique;
  String? _selectedProduitFournisseur;

  @override
  void dispose() {
    _quantiteController.dispose();
    _transportController.dispose();
    _logistiqueController.dispose();
    super.dispose();
  }

  Future<void> _calculateMargin() async {
    if (_selectedProduitAfrique == null || _selectedProduitFournisseur == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner les deux produits'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => _isCalculating = true);

    // Simuler l'appel à l'Edge Function
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _currentAnalysis = AnalyseMarge(
        id: '1',
        produitAfriqueId: _selectedProduitAfrique!,
        produitFournisseurId: _selectedProduitFournisseur!,
        prixAchat: 8999,
        coutTransport: double.parse(_transportController.text),
        coutDouane: 1349.85,
        coutLogistique: double.parse(_logistiqueController.text),
        prixRevientTotal: 11048.85,
        prixVenteEstime: 15000,
        margeBrute: 3951.15,
        margeBrutePourcentage: 26.34,
        margeNette: 3556.04,
        margeNettePourcentage: 23.71,
        roiEstime: 43.91,
        volumeRecommande: 200,
        risqueNiveau: 'faible',
        recommandation: 'Excellent potentiel! Produit fortement recommandé avec une marge confortable.',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        produitAfriqueNom: 'Smartphones Android',
        produitAfriquePrix: 150,
        produitFournisseurNom: 'Smartphone 6.5" 4GB RAM',
        produitFournisseurPrix: 89.99,
        fournisseurNom: 'Guangzhou Electronics Co.',
      );
      _isCalculating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analyse de Marge'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.document_download),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input Section
            _buildInputSection(),
            SizedBox(height: 24.h),

            // Calculate Button
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton.icon(
                onPressed: _isCalculating ? null : _calculateMargin,
                icon: _isCalculating
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Iconsax.chart_2),
                label: Text(_isCalculating ? 'Calcul en cours...' : 'Calculer la marge'),
              ),
            ),
            SizedBox(height: 24.h),

            // Results Section
            if (_currentAnalysis != null) ...[
              _buildResultsSection(),
              SizedBox(height: 24.h),
              _buildCostBreakdownChart(),
              SizedBox(height: 24.h),
              _buildRecommendation(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
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
          Text(
            'Paramètres de l\'analyse',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 20.h),

          // Produit Afrique
          Text(
            'Produit sur le marché africain',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          SizedBox(height: 8.h),
          DropdownButtonFormField<String>(
            value: _selectedProduitAfrique,
            decoration: InputDecoration(
              prefixIcon: const Icon(Iconsax.global),
              hintText: 'Sélectionner un produit',
            ),
            items: const [
              DropdownMenuItem(value: '1', child: Text('Smartphones - Sénégal')),
              DropdownMenuItem(value: '2', child: Text('Vêtements - Côte d\'Ivoire')),
              DropdownMenuItem(value: '3', child: Text('Électroménager - Cameroun')),
            ],
            onChanged: (value) => setState(() => _selectedProduitAfrique = value),
          ),
          SizedBox(height: 16.h),

          // Produit Fournisseur
          Text(
            'Produit fournisseur',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          SizedBox(height: 8.h),
          DropdownButtonFormField<String>(
            value: _selectedProduitFournisseur,
            decoration: InputDecoration(
              prefixIcon: const Icon(Iconsax.building),
              hintText: 'Sélectionner un produit',
            ),
            items: const [
              DropdownMenuItem(value: '1', child: Text('Smartphone 6.5" - \$89.99')),
              DropdownMenuItem(value: '2', child: Text('T-Shirt Coton - \$3.50')),
              DropdownMenuItem(value: '3', child: Text('Ventilateur 16" - \$15.00')),
            ],
            onChanged: (value) => setState(() => _selectedProduitFournisseur = value),
          ),
          SizedBox(height: 16.h),

          // Quantité
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quantité', style: Theme.of(context).textTheme.bodySmall),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _quantiteController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Iconsax.box),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Transport (\$)', style: Theme.of(context).textTheme.bodySmall),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _transportController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Iconsax.ship),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Logistique
          Text('Logistique locale (\$)', style: Theme.of(context).textTheme.bodySmall),
          SizedBox(height: 8.h),
          TextFormField(
            controller: _logistiqueController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              prefixIcon: Icon(Iconsax.truck),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection() {
    final analysis = _currentAnalysis!;
    
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: analysis.isHighlyRentable
            ? LinearGradient(
                colors: [AppTheme.accentColor, AppTheme.accentColor.withOpacity(0.8)],
              )
            : analysis.isRentable
                ? LinearGradient(
                    colors: [AppTheme.secondaryColor, AppTheme.secondaryColor.withOpacity(0.8)],
                  )
                : LinearGradient(
                    colors: [AppTheme.warningColor, AppTheme.warningColor.withOpacity(0.8)],
                  ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Marge Brute',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${analysis.margeBrutePourcentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      analysis.risqueNiveau == 'faible'
                          ? Iconsax.shield_tick
                          : analysis.risqueNiveau == 'moyen'
                              ? Iconsax.warning_2
                              : Iconsax.danger,
                      color: Colors.white,
                      size: 18.sp,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'Risque ${analysis.risqueLabel}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          
          // Details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildResultItem('Prix Achat', '\$${analysis.prixAchat.toStringAsFixed(0)}'),
              _buildResultItem('Prix Revient', '\$${analysis.prixRevientTotal.toStringAsFixed(0)}'),
              _buildResultItem('Prix Vente', '\$${analysis.prixVenteEstime.toStringAsFixed(0)}'),
              _buildResultItem('ROI', '${analysis.roiEstime.toStringAsFixed(0)}%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 11.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildCostBreakdownChart() {
    final analysis = _currentAnalysis!;
    
    return Container(
      padding: EdgeInsets.all(20.w),
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
          Text(
            'Répartition des coûts',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 20.h),
          SizedBox(
            height: 200.h,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 50.r,
                sections: [
                  PieChartSectionData(
                    value: analysis.prixAchat,
                    title: '${((analysis.prixAchat / analysis.prixRevientTotal) * 100).toStringAsFixed(0)}%',
                    color: AppTheme.primaryColor,
                    radius: 50.r,
                    titleStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    value: analysis.coutTransport,
                    title: '${((analysis.coutTransport / analysis.prixRevientTotal) * 100).toStringAsFixed(0)}%',
                    color: AppTheme.secondaryColor,
                    radius: 50.r,
                    titleStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    value: analysis.coutDouane,
                    title: '${((analysis.coutDouane / analysis.prixRevientTotal) * 100).toStringAsFixed(0)}%',
                    color: AppTheme.warningColor,
                    radius: 50.r,
                    titleStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    value: analysis.coutLogistique,
                    title: '${((analysis.coutLogistique / analysis.prixRevientTotal) * 100).toStringAsFixed(0)}%',
                    color: AppTheme.accentColor,
                    radius: 50.r,
                    titleStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Wrap(
            spacing: 16.w,
            runSpacing: 12.h,
            children: [
              _buildLegendItem('Achat', AppTheme.primaryColor, '\$${analysis.prixAchat.toStringAsFixed(0)}'),
              _buildLegendItem('Transport', AppTheme.secondaryColor, '\$${analysis.coutTransport.toStringAsFixed(0)}'),
              _buildLegendItem('Douane', AppTheme.warningColor, '\$${analysis.coutDouane.toStringAsFixed(0)}'),
              _buildLegendItem('Logistique', AppTheme.accentColor, '\$${analysis.coutLogistique.toStringAsFixed(0)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3.r),
          ),
        ),
        SizedBox(width: 6.w),
        Text(
          '$label: $value',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildRecommendation() {
    final analysis = _currentAnalysis!;
    
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.lamp_on,
                color: AppTheme.primaryColor,
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                'Recommandation',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryColor,
                    ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            analysis.recommandation ?? 'Aucune recommandation disponible.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Icon(
                Iconsax.box,
                size: 16.sp,
                color: AppTheme.textSecondaryLight,
              ),
              SizedBox(width: 8.w),
              Text(
                'Volume recommandé: ${analysis.volumeRecommande} unités',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
