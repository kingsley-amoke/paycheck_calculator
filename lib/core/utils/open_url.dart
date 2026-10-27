import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openUrl(BuildContext context, {required String url}) async {
  final uri = Uri.parse(url);

  final success = await launchUrl(uri, mode: LaunchMode.externalApplication);

  if (!success && context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Unable to open Url.')));
  }
}
