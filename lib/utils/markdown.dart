import 'package:markdown/markdown.dart';

class Markdown {
  String text;
  bool parsed = false;

  Markdown(this.text);

  void load(String data) {
    if (parsed) return;

    text = data;
    parsed = true;
  }

  static String parse(String data) => markdownToHtml(
        data,
        extensionSet: ExtensionSet.none,
        blockSyntaxes: _blockSyntaxes,
        inlineSyntaxes: _inlineSyntaxes,
      );

  static const _blockSyntaxes = [
    _CenterSyntax(),
    _SpoilerSyntax(),
    FencedCodeBlockSyntax(),
  ];

  static final _inlineSyntaxes = [
    StrikethroughSyntax(),
    AutolinkExtensionSyntax(),
    InlineHtmlSyntax(),
  ];
}

class _CenterSyntax extends BlockSyntax {
  const _CenterSyntax();

  @override
  RegExp get pattern => RegExp(r'^(.*?)~~~(.*)$');

  @override
  bool canParse(BlockParser parser) =>
      pattern.firstMatch(parser.current) != null;

  // The text before the opening '~~~' is the first element (prefix)
  // The text after  the closing '~~~' is the last  element (postfix)
  @override
  List<String> parseChildLines(BlockParser parser) {
    final childLines = <String>[];

    final firstMatch = pattern.firstMatch(parser.current)!;
    childLines.add(firstMatch.group(1) ?? '');

    final lineEnd = firstMatch.group(2) ?? '';
    final earlyMatch = pattern.firstMatch(lineEnd);

    if (earlyMatch != null)
      return childLines
        ..add(earlyMatch.group(1) ?? '')
        ..add(earlyMatch.group(2) ?? '');

    childLines.add(lineEnd);
    parser.advance();

    while (!parser.isDone) {
      final match = pattern.firstMatch(parser.current);
      if (match == null) {
        childLines.add(parser.current);
        parser.advance();
      } else {
        childLines..add(match.group(1) ?? '')..add(match.group(2) ?? '');
        parser.advance();
        break;
      }
    }

    return childLines;
  }

  @override
  Node parse(BlockParser parser) {
    final lines = parseChildLines(parser);

    final prefix = BlockParser([lines.first], parser.document).parseLines();
    final postfix = BlockParser([lines.last], parser.document).parseLines();
    final children = BlockParser(
      lines.sublist(1, lines.length - 1),
      parser.document,
    ).parseLines();

    return Element('p', [...prefix, Element('center', children), ...postfix]);
  }
}

class _SpoilerSyntax extends BlockSyntax {
  const _SpoilerSyntax();

  @override
  RegExp get pattern => RegExp(r'^(.*?)~!(.*)$');

  @override
  bool canParse(BlockParser parser) =>
      pattern.firstMatch(parser.current) != null;

  // The text before the opening '~!' is the first element (prefix)
  // The text after  the closing '!~' is the last  element (postfix)
  @override
  List<String> parseChildLines(BlockParser parser) {
    final childLines = <String>[];
    final end = RegExp(r'^(.*?)!~(.*)$');

    final firstMatch = pattern.firstMatch(parser.current)!;
    childLines.add(firstMatch.group(1) ?? '');

    final lineEnd = firstMatch.group(2) ?? '';
    final earlyMatch = end.firstMatch(lineEnd);

    if (earlyMatch != null)
      return childLines
        ..add(earlyMatch.group(1) ?? '')
        ..add(earlyMatch.group(2) ?? '');

    childLines.add(lineEnd);
    parser.advance();

    while (!parser.isDone) {
      final match = end.firstMatch(parser.current);
      if (match == null) {
        childLines.add(parser.current);
        parser.advance();
      } else {
        childLines..add(match.group(1) ?? '')..add(match.group(2) ?? '');
        parser.advance();
        break;
      }
    }

    return childLines;
  }

  @override
  Node parse(BlockParser parser) {
    final lines = parseChildLines(parser);

    final prefix = BlockParser([lines.first], parser.document).parseLines();
    final postfix = BlockParser([lines.last], parser.document).parseLines();
    final text = lines.sublist(1, lines.length - 1).join('\n');

    return Element('p', [...prefix, Element.text('spoiler', text), ...postfix]);
  }
}
