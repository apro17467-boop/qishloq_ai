import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactActions {
  ContactActions._();

  static Future<void> launchPhoneCall(BuildContext context, String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri uri = Uri(scheme: 'tel', path: cleanPhone);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          _showErrorSnackBar(context, 'Telefon ilovasini ochib bo‘lmadi');
        }
      }
    } catch (_) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Telefon ilovasini ochib bo‘lmadi');
      }
    }
  }

  static Future<void> launchSms(BuildContext context, String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri uri = Uri(scheme: 'sms', path: cleanPhone);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          _showErrorSnackBar(context, 'SMS ilovasini ochib bo‘lmadi');
        }
      }
    } catch (_) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'SMS ilovasini ochib bo‘lmadi');
      }
    }
  }

  static Future<void> copyPhone(BuildContext context, String phone) async {
    await Clipboard.setData(ClipboardData(text: phone));
    if (context.mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Telefon raqami nusxalandi'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
