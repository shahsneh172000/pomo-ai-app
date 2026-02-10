import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'app_localizations.dart';
import 'management_service.dart';

class ManagementPage extends StatefulWidget {
  final String diseaseKey;
  final ManagementService managementService;
  final String languageCode;
  final Function(String) onLanguageChanged;

  const ManagementPage({
    super.key,
    required this.diseaseKey,
    required this.managementService,
    required this.languageCode,
    required this.onLanguageChanged,
  });

  @override
  State<ManagementPage> createState() => _ManagementPageState();
}

class _ManagementPageState extends State<ManagementPage> {
  late Map<String, dynamic> _managementData;
  late AppLocalizations _localizations;

  @override
  void initState() {
    super.initState();
    _updateLocalData(widget.languageCode);
  }

  void _updateLocalData(String languageCode) {
    _localizations = AppLocalizations(languageCode);
    _managementData = widget.managementService.getTechnique(widget.diseaseKey, languageCode);
  }

  @override
  void didUpdateWidget(covariant ManagementPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.languageCode != widget.languageCode) {
      setState(() {
        _updateLocalData(widget.languageCode);
      });
    }
  }

  void _changeLanguage(String newLanguageCode) {
    widget.onLanguageChanged(newLanguageCode);
    // Also update the state of the current page to reflect the change immediately
    setState(() {
      _updateLocalData(newLanguageCode);
    });
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // Consider showing a snackbar or dialog on failure
      print('Could not launch $url');
    }
  }

  Widget _buildSectionTitle(BuildContext context, String? title) {
    if (title == null || title.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildParagraph(BuildContext context, String? text, {bool isNote = false}) {
    if (text == null || text.isEmpty) return const SizedBox.shrink();

    final lines = text.split('\n').where((line) => line.trim().isNotEmpty);

    final baseStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          height: 1.5,
          fontStyle: isNote ? FontStyle.italic : FontStyle.normal,
        );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lines.map((line) {
          final trimmedLine = line.trim();
          if (trimmedLine.startsWith('•')) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 8), // Indentation for list items
                  Text("•  ", style: baseStyle?.copyWith(fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(
                      trimmedLine.substring(1).trim(),
                      style: baseStyle,
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(trimmedLine, style: baseStyle),
            );
          }
        }).toList(),
      ),
    );
  }

  Widget _buildBulletedList(BuildContext context, List? items) {
    if (items == null || items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("•  ",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Text(
                          item.toString(),
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildUrlLink(BuildContext context, String? url) {
    if (url == null || url.isEmpty) return const SizedBox.shrink();
    return InkWell(
      onTap: () => _launchUrl(url),
      child: Text(
        url,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
      ),
    );
  }

  Widget _buildTitledListSection(BuildContext context, String titleKey,
      String? introKey, String listKey, String? noteKey) {
    final title = _managementData[titleKey];
    final intro = introKey != null ? _managementData[introKey] : null;
    final list = _managementData[listKey];
    final note = noteKey != null ? _managementData[noteKey] : null;

    if (title == null && list == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, title),
        _buildParagraph(context, intro),
        _buildBulletedList(context, list as List?),
        _buildParagraph(context, note, isNote: true),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_managementData['diseaseName'] ??
            _localizations.get('managementTechniquesTitle')),
        actions: [
          PopupMenuButton<String>(
            onSelected: _changeLanguage,
            icon: const Icon(Icons.language),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(value: 'en', child: Text('English')),
              const PopupMenuItem<String>(value: 'hi', child: Text('हिन्दी')),
              const PopupMenuItem<String>(value: 'gu', child: Text('ગુજરાતી')),
              const PopupMenuItem<String>(value: 'mr', child: Text('मराठी')),
              const PopupMenuItem<String>(value: 'kn', child: Text('ಕನ್ನಡ')),
              const PopupMenuItem<String>(value: 'te', child: Text('తెలుగు')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildParagraph(context, _managementData['description']),
            _buildSectionTitle(context, _localizations.get('causalOrganismLabel')),
            _buildParagraph(context, _managementData['causalOrganism']),
            _buildSectionTitle(context, _localizations.get('symptomsLabel')),
            _buildParagraph(context, _managementData['symptoms']),
            _buildSectionTitle(context, _localizations.get('predisposingFactorsLabel')),
            _buildParagraph(context, _managementData['predisposingFactors']),
            _buildTitledListSection(context, 'pruningManagementTitle', null, 'pruningManagement', null),
            _buildTitledListSection(context, 'cropSeasonManagementTitle', null, 'cropSeasonManagement', 'cropSeasonManagementNote'),
            _buildTitledListSection(context, 'emergencySpraysTitle', 'emergencySpraysIntro', 'emergencySprays', 'emergencySpraysNote'),
            _buildTitledListSection(context, 'chemicalManagementTitle', 'chemicalManagementIntro', 'sprays', 'chemicalManagementNote'),
            _buildTitledListSection(context, 'importantInstructionsTitle', null, 'instructions', null),
            _buildSectionTitle(context, _localizations.get('recommendationsLabel')),
            _buildBulletedList(context, _managementData['recommendations']),
            _buildSectionTitle(context, _localizations.get('sourceUrlLabel')),
            _buildUrlLink(context, _managementData['sourceUrl']),
          ],
        ),
      ),
    );
  }
}