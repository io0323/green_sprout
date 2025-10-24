import 'package:flutter/material.dart';
import '../../core/services/localization_service.dart';

/**
 * 言語設定ウィジェット
 * アプリケーションの言語を切り替えるためのウィジェット
 */
class LanguageSelector extends StatefulWidget {
  const LanguageSelector({super.key});

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  late String _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = LocalizationService.instance.currentLanguage;
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.language, color: Colors.white),
      tooltip: '言語設定',
      onSelected: (String languageCode) {
        setState(() {
          _selectedLanguage = languageCode;
        });
        LocalizationService.instance.setLanguage(languageCode);
        // アプリ全体を再構築
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      },
      itemBuilder: (BuildContext context) {
        return LocalizationService.instance.availableLanguages
            .map((String languageCode) {
          return PopupMenuItem<String>(
            value: languageCode,
            child: Row(
              children: [
                Icon(
                  _selectedLanguage == languageCode ? Icons.check : null,
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                    LocalizationService.instance.getLanguageName(languageCode)),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}

/**
 * 言語設定ダイアログ
 */
class LanguageDialog extends StatefulWidget {
  const LanguageDialog({super.key});

  @override
  State<LanguageDialog> createState() => _LanguageDialogState();
}

class _LanguageDialogState extends State<LanguageDialog> {
  late String _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = LocalizationService.instance.currentLanguage;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(t('language_settings')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: LocalizationService.instance.availableLanguages
            .map((String languageCode) {
          return RadioListTile<String>(
            title: Text(
                LocalizationService.instance.getLanguageName(languageCode)),
            value: languageCode,
            groupValue: _selectedLanguage,
            onChanged: (String? value) {
              setState(() {
                _selectedLanguage = value!;
              });
            },
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t('cancel')),
        ),
        ElevatedButton(
          onPressed: () {
            LocalizationService.instance.setLanguage(_selectedLanguage);
            Navigator.of(context).pop();
            // アプリ全体を再構築
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/', (route) => false);
          },
          child: Text(t('save')),
        ),
      ],
    );
  }
}
