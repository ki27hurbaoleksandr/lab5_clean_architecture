import 'dart:io';

import 'package:test/test.dart';

const _packageName = 'lab5_clean_architecture';
const _layers = ['domain', 'application', 'infrastructure', 'presentation'];

final _importPattern = RegExp(
  r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
  multiLine: true,
);

/// Повертає шар (domain, application, ...) для файлу в lib/src.
String _layerOfFile(File file) {
  final normalized = file.path.replaceAll(r'\', '/');
  final marker = 'lib/src/';
  final start = normalized.indexOf(marker) + marker.length;
  return normalized.substring(start).split('/').first;
}

/// Повертає шар, на який вказує імпорт, або null (dart:, зовнішні пакети).
String? _layerOfImport(File file, String uri) {
  const packagePrefix = 'package:$_packageName/src/';
  String? relativePath;
  if (uri.startsWith(packagePrefix)) {
    relativePath = uri.substring(packagePrefix.length);
  } else if (!uri.contains(':')) {
    // Відносний імпорт: обчислюємо шлях відносно поточного файлу.
    final resolved = file.uri.resolve(uri).path;
    final marker = '/lib/src/';
    final index = resolved.indexOf(marker);
    if (index < 0) return null;
    relativePath = resolved.substring(index + marker.length);
  }
  if (relativePath == null) return null;
  final layer = relativePath.split('/').first;
  return _layers.contains(layer) ? layer : null;
}

/// Для кожного шару збирає множину шарів, які він імпортує (крім себе).
Map<String, Set<String>> _collectDependencies() {
  final dependencies = {for (final layer in _layers) layer: <String>{}};
  final files = Directory('lib/src')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));
  for (final file in files) {
    final layer = _layerOfFile(file);
    final content = file.readAsStringSync();
    for (final match in _importPattern.allMatches(content)) {
      final target = _layerOfImport(file, match.group(1)!);
      if (target != null && target != layer) {
        dependencies[layer]!.add(target);
      }
    }
  }
  return dependencies;
}

void main() {
  late Map<String, Set<String>> dependencies;

  setUpAll(() {
    dependencies = _collectDependencies();
  });

  test('усі імпорти між файлами використовують package:$_packageName/src/', () {
    final files = Directory('lib/src')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));
    for (final file in files) {
      final content = file.readAsStringSync();
      for (final match in _importPattern.allMatches(content)) {
        final uri = match.group(1)!;
        final isRelative = !uri.contains(':');
        expect(
          isRelative,
          isFalse,
          reason: '${file.path} має відносний імпорт',
        );
      }
    }
  });

  test('domain не імпортує application, infrastructure, presentation', () {
    expect(dependencies['domain'], isEmpty);
  });

  test('application імпортує лише domain', () {
    expect(dependencies['application']!.difference({'domain'}), isEmpty);
  });

  test('infrastructure не імпортує presentation', () {
    expect(dependencies['infrastructure'], isNot(contains('presentation')));
    expect(dependencies['infrastructure'], isNot(contains('application')));
  });

  test('presentation не залежить від infrastructure', () {
    expect(dependencies['presentation'], isNot(contains('infrastructure')));
  });

  test('аналізатор бачить залежності (перевірка самого тесту)', () {
    expect(dependencies['infrastructure'], contains('domain'));
    expect(dependencies['application'], contains('domain'));
  });
}
