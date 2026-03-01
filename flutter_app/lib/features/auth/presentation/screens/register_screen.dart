import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../services/supabase_service.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  String? _selectedPays;
  String _selectedExperience = 'debutant';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _acceptTerms = false;

  final List<Map<String, String>> _paysOptions = [
    {'id': 'sen', 'nom': 'Sénégal'},
    {'id': 'civ', 'nom': 'Côte d\'Ivoire'},
    {'id': 'cmr', 'nom': 'Cameroun'},
    {'id': 'nga', 'nom': 'Nigeria'},
    {'id': 'gha', 'nom': 'Ghana'},
    {'id': 'ken', 'nom': 'Kenya'},
    {'id': 'zaf', 'nom': 'Afrique du Sud'},
    {'id': 'mar', 'nom': 'Maroc'},
    {'id': 'egy', 'nom': 'Égypte'},
    {'id': 'cod', 'nom': 'RD Congo'},
  ];

  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez accepter les conditions d\'utilisation'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabaseService = ref.read(supabaseServiceProvider);
      
      // Créer le compte
      final authResponse = await supabaseService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        data: {'nom_complet': _nomController.text.trim()},
      );

      if (authResponse.user != null) {
        // Créer le profil membre
        await supabaseService.createMembre({
          'user_id': authResponse.user!.id,
          'nom_complet': _nomController.text.trim(),
          'email': _emailController.text.trim(),
          'telephone': _telephoneController.text.trim(),
          'whatsapp': _telephoneController.text.trim(),
          'pays_id': _selectedPays,
          'experience_import': _selectedExperience,
        });

        if (mounted) {
          context.go('/dashboard');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur d\'inscription: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.go('/login'),
        ),
        title: const Text('Inscription'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Créer un compte',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                SizedBox(height: 8.h),
                Text(
                  'Rejoignez la plateforme de commerce Afrique-Chine',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondaryLight,
                      ),
                ),
                SizedBox(height: 32.h),

                // Nom complet
                _buildLabel('Nom complet'),
                TextFormField(
                  controller: _nomController,
                  decoration: InputDecoration(
                    hintText: 'Jean Dupont',
                    prefixIcon: const Icon(Iconsax.user),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre nom';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.h),

                // Email
                _buildLabel('Email'),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'votre@email.com',
                    prefixIcon: const Icon(Iconsax.sms),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre email';
                    }
                    if (!value.contains('@')) {
                      return 'Email invalide';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.h),

                // Téléphone
                _buildLabel('Téléphone / WhatsApp'),
                TextFormField(
                  controller: _telephoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: '+221 77 123 45 67',
                    prefixIcon: const Icon(Iconsax.call),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre numéro';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.h),

                // Pays
                _buildLabel('Pays'),
                DropdownButtonFormField<String>(
                  value: _selectedPays,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Iconsax.global),
                  ),
                  hint: const Text('Sélectionnez votre pays'),
                  items: _paysOptions
                      .map((pays) => DropdownMenuItem(
                            value: pays['id'],
                            child: Text(pays['nom']!),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedPays = value);
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Veuillez sélectionner un pays';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.h),

                // Expérience
                _buildLabel('Expérience en import'),
                DropdownButtonFormField<String>(
                  value: _selectedExperience,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Iconsax.medal_star),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'debutant',
                      child: Text('Débutant - Première importation'),
                    ),
                    DropdownMenuItem(
                      value: 'intermediaire',
                      child: Text('Intermédiaire - Quelques imports'),
                    ),
                    DropdownMenuItem(
                      value: 'expert',
                      child: Text('Expert - Importateur régulier'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedExperience = value!);
                  },
                ),
                SizedBox(height: 20.h),

                // Mot de passe
                _buildLabel('Mot de passe'),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: const Icon(Iconsax.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Iconsax.eye_slash : Iconsax.eye,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un mot de passe';
                    }
                    if (value.length < 8) {
                      return 'Minimum 8 caractères';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.h),

                // Confirmer mot de passe
                _buildLabel('Confirmer le mot de passe'),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: const Icon(Iconsax.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Iconsax.eye_slash : Iconsax.eye,
                      ),
                      onPressed: () {
                        setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24.h),

                // Terms checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _acceptTerms,
                      onChanged: (value) {
                        setState(() => _acceptTerms = value!);
                      },
                      activeColor: AppTheme.primaryColor,
                    ),
                    Expanded(
                      child: Text(
                        'J\'accepte les conditions d\'utilisation et la politique de confidentialité',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32.h),

                // Register button
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    child: _isLoading
                        ? SizedBox(
                            width: 24.w,
                            height: 24.w,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Créer mon compte'),
                  ),
                ),
                SizedBox(height: 24.h),

                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Déjà un compte ? ',
                      style: TextStyle(color: AppTheme.textSecondaryLight),
                    ),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text(
                        'Se connecter',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }
}
