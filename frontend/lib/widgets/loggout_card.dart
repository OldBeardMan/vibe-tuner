import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_tuner/constants/app_paths.dart';
import 'package:vibe_tuner/constants/app_sizes.dart';
import 'package:vibe_tuner/constants/app_strings.dart';
import 'package:vibe_tuner/providers/auth_provider.dart';

class LogoutCard extends StatelessWidget {
  const LogoutCard({super.key});

  Future<void> _confirmAndLogout(BuildContext context) async {
    final theme = Theme.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(AppStrings.logOutDialogTitle, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          backgroundColor: theme.colorScheme.surface,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(AppSizes.logoutPageDialogCornerRadius))),
          content: Text(
            AppStrings.logOutDialogBody,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppSizes.logoutPageDialogButtonVerticalPadding),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(AppStrings.dialogCancel, style: TextStyle(color: theme.colorScheme.onSurface),),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppSizes.logoutPageDialogButtonVerticalPadding),
                      backgroundColor: theme.colorScheme.onSurface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(AppStrings.logOut),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (result == true) {
      final authProv = Provider.of<AuthProvider>(context, listen: false);
      await authProv.logout();
      if (context.mounted) context.go(AppPaths.baseLocation);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(
        left: AppSizes.expandableCardPadding,
        right: AppSizes.expandableCardPadding,
        top: AppSizes.expandableCardPaddingBetween,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSizes.expandableCardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: AppSizes.expandableCardBlurRadius,
              offset: AppSizes.expandableCardBlurOffset,
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppSizes.expandableCardPaddingInside),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _confirmAndLogout(context),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(AppStrings.logOut2,
                    style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: AppSizes.expandableCardBasicTitleSize,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _confirmAndLogout(context),
                icon: Icon(Icons.logout_outlined, color: theme.colorScheme.onSurface),
                splashRadius: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
