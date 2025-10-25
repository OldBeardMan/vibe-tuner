import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibe_tuner/constants/app_colors.dart';
import 'package:vibe_tuner/constants/app_paths.dart';
import 'package:vibe_tuner/constants/app_strings.dart';
import 'package:vibe_tuner/providers/auth_provider.dart';
import '../constants/mapping/error_messages_mapping.dart';
import '../services/api_client.dart';
import 'package:vibe_tuner/widgets/animated_banner.dart';
import 'package:vibe_tuner/constants/app_sizes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _bannerText;
  Color? _bannerColor;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _showBannerWithInfo(BannerInfo info) {
    setState(() {
      _bannerText = info.text;
      _bannerColor = info.color;
    });
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return AppStrings.enterEmail;
    final emailReg = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailReg.hasMatch(v.trim())) return AppStrings.invalidEmail;
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return AppStrings.enterPassword;
    return null;
  }

  Future<void> _submitLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final authProv = Provider.of<AuthProvider>(context, listen: false);
    try {
      await authProv.login(email: _emailCtrl.text.trim(), password: _passwordCtrl.text)
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;
      context.go(AppPaths.homePage);
    } on ApiException catch (e) {
      final info = mapApiExceptionToBannerInfo(e);
      _showBannerWithInfo(info);
    } on SocketException catch (_) {
      final info = BannerInfo(AppStrings.serverConnectionError, AppColors.signInError);
      _showBannerWithInfo(info);
    } on TimeoutException catch (_) {
      final info = BannerInfo(AppStrings.serverNotRespondingError, AppColors.signInError);
      _showBannerWithInfo(info);
    } catch (e) {
      final info = mapGenericExceptionToBannerInfo(e);
      _showBannerWithInfo(info);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.loginPagePaddingHorizontal,
                  vertical: AppSizes.loginPagePaddingVertical,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSizes.loginPageTopSpacer),
                    Center(
                      child: Icon(Icons.person_outline, size: AppSizes.loginPageAvatarIconSize, color: theme.colorScheme.onSurface),
                    ),
                    const SizedBox(height: AppSizes.loginPageLargeSpacer),
                    Text(AppStrings.logIn,
                        style: GoogleFonts.inter(fontSize: AppSizes.loginPageTitleFontSize, fontWeight: FontWeight.w700)),
                    const SizedBox(height: AppSizes.loginPageBetweenTitleAndForm),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // email
                          TextFormField(
                            controller: _emailCtrl,
                            validator: _validateEmail,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: AppStrings.email,
                              prefixIcon: const Icon(Icons.mail_outlined),
                              filled: true,
                              fillColor: theme.colorScheme.primaryContainer,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: AppSizes.loginPageFieldVerticalPadding,
                                horizontal: AppSizes.loginPageFieldHorizontalPadding,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppSizes.loginPageFieldBorderRadius),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSizes.loginPageFormSpacing),

                          // password
                          TextFormField(
                            controller: _passwordCtrl,
                            validator: _validatePassword,
                            obscureText: _obscure,
                            decoration: InputDecoration(
                              hintText: AppStrings.password,
                              prefixIcon: const Icon(Icons.key_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: theme.colorScheme.onSurface,),
                                onPressed: () => setState(() => _obscure = !_obscure,),
                              ),
                              filled: true,
                              fillColor: theme.colorScheme.primaryContainer,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: AppSizes.loginPageFieldVerticalPadding,
                                horizontal: AppSizes.loginPageFieldHorizontalPadding,
                              ),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.loginPageFieldBorderRadius), borderSide: BorderSide.none),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.loginPageLargeSpacer),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _submitLogin,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: AppSizes.loginPageButtonVerticalPadding),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.loginPageButtonBorderRadius)),
                        ),
                        child: _loading ? const SizedBox(height: AppSizes.loginPageLoadingIndicatorSize, width: AppSizes.loginPageLoadingIndicatorSize, child: CircularProgressIndicator(strokeWidth: 2)) : const Text(AppStrings.logIn),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            AnimatedBanner(
              message: _bannerText,
              color: _bannerColor,
              onDismissed: () {
                if (mounted) setState(() => _bannerText = null);
              },
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(AppStrings.noAccountQuestion),
                  GestureDetector(
                    onTap: () => context.go(AppPaths.registerPage),
                    child: Text(AppStrings.signIn, style: TextStyle(fontWeight: FontWeight.w700, color: theme.colorScheme.primary)),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
