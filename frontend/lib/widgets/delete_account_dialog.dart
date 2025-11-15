import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_sizes.dart';
import '../constants/app_strings.dart';
import '../constants/app_colors.dart';
import '../constants/mapping/error_messages_mapping.dart';
import '../services/api_client.dart';
import '../providers/auth_provider.dart';
import '../constants/app_paths.dart';

class DeleteAccountDialog extends StatefulWidget {
  const DeleteAccountDialog({super.key});

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  final TextEditingController _passwordCtrl = TextEditingController();
  String? _errorText;
  bool _loading = false;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _onDeletePressed() async {
    final pwd = _passwordCtrl.text.trim();

    if (pwd.isEmpty) {
      setState(() => _errorText = AppStrings.deleteAccountPasswordEmpty);
      return;
    }

    setState(() {
      _errorText = null;
      _loading = true;
    });

    try {
      const path = '/auth/account';
      await ApiClient.instance.delete(path, body: {'password': pwd});

      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.logout();
      if (mounted) Navigator.of(context).pop(true);
      if (mounted) GoRouter.of(context).go(AppPaths.baseLocation);
      return;
    } catch (err) {
      if (mounted) setState(() => _loading = false);

      debugPrint('delete account error: $err');
      if (err is ApiException) {
        debugPrint('ApiException.statusCode=${err.statusCode}, message=${err.message}');
        int? code = err.statusCode;
        if (code == null) {
          final m = err.message;
          final match = RegExp(r'\b(1|2|3|4|5)\d{2}\b').firstMatch(m);
          if (match != null) {
            code = int.tryParse(match.group(0)!);
          }
        }
        final msg = DeleteAccountErrors.fromStatusCode(code);
        if (mounted) setState(() => _errorText = msg);
        return;
      }

      if (err is http.Response) {
        final msg = DeleteAccountErrors.fromStatusCode(err.statusCode);
        if (mounted) setState(() => _errorText = msg);
        return;
      }

      if (err.toString().toLowerCase().contains('timeout')) {
        if (mounted) setState(() => _errorText = AppStrings.serverNotRespondingError);
        return;
      }
      if (err.toString().toLowerCase().contains('socket') || err.toString().toLowerCase().contains('network')) {
        if (mounted) setState(() => _errorText = AppStrings.errorNoNetwork);
        return;
      }

      if (mounted) setState(() => _errorText = AppStrings.errorDefault);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(AppStrings.deleteAccountTitle, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(AppSizes.logoutPageDialogCornerRadius))),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_outlined, color: AppColors.deleteAccountButton, size: AppSizes.logoutPageDialogIconSize),
          const SizedBox(height: 8),
          Text(
            AppStrings.deleteAccountWarning,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordCtrl,
            obscureText: true,
            enabled: !_loading,
            decoration: InputDecoration(
              labelText: AppStrings.deleteAccountPasswordLabel,
              isDense: true,
              errorText: _errorText,
            ),
          ),
          if (_loading) ...[
            const SizedBox(height: 12),
          ],
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _loading ? null : () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.logoutPageDialogButtonVerticalPadding),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(AppStrings.dialogCancel, style: TextStyle(color: theme.colorScheme.onSurface)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _loading ? null : _onDeletePressed,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.logoutPageDialogButtonVerticalPadding),
                    foregroundColor: theme.colorScheme.onSurface,
                    backgroundColor: AppColors.deleteAccountButton,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(AppStrings.deleteAccountButtonDelete, style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
