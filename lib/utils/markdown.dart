import 'package:markdown/markdown.dart';

class Markdown {
  Markdown(this.text);

  String text;
  bool _parsed = false;

  bool get parsed => _parsed;

  void parse() {
    if (_parsed) return;
    text = markdownToHtml(
      text,
      extensionSet: ExtensionSet.none,
      blockSyntaxes: _blockSyntaxes,
      inlineSyntaxes: _inlineSyntaxes,
    );
    _parsed = true;
  }

  static const _blockSyntaxes = [
    // _CenterSyntax(),
    // _SpoilerSyntax(),
    FencedCodeBlockSyntax(),
  ];

  static final _inlineSyntaxes = [
    StrikethroughSyntax(),
    AutolinkExtensionSyntax(),
    InlineHtmlSyntax(),
  ];
}

// // TODO doesn't load bio on taluun

// class _CenterSyntax extends BlockSyntax {
//   const _CenterSyntax();

//   @override
//   RegExp get pattern => RegExp(r'~~~');

//   @override
//   bool canParse(BlockParser parser) => parser.current.contains('~~~');

//   // The text before the opening '~~~' is the first element (prefix)
//   // The text after  the closing '~~~' is the last  element (postfix)
//   @override
//   List<String> parseChildLines(BlockParser parser) {
//     final childLines = <String>[];
//     const patt = '~~~';

//     int startIndex = parser.current.indexOf(patt);
//     childLines.add(parser.current.substring(0, startIndex));

//     startIndex += 3;
//     if (startIndex < parser.current.length) {
//       final lineEnd = parser.current.substring(startIndex);
//       int endIndex = lineEnd.indexOf(patt);

//       if (endIndex >= 0) {
//         childLines.add(lineEnd.substring(0, endIndex));

//         endIndex += 3;
//         if (endIndex < lineEnd.length)
//           childLines.add(lineEnd.substring(endIndex));
//         else
//           childLines.add('');

//         return childLines;
//       }

//       childLines.add(lineEnd);
//     }

//     parser.advance();

//     while (!parser.isDone) {
//       int endIndex = parser.current.indexOf(patt);

//       if (endIndex < 0) {
//         childLines.add(parser.current);
//         parser.advance();
//         continue;
//       }

//       childLines.add(parser.current.substring(0, endIndex));

//       endIndex += 3;
//       if (endIndex < parser.current.length)
//         childLines.add(parser.current.substring(endIndex));
//       else if (childLines.last != '') childLines.add('');

//       parser.advance();
//       return childLines;
//     }

//     return [];

//     // final firstMatch = pattern.firstMatch(parser.current)!;
//     // childLines.add(firstMatch.group(1) ?? '');

//     // final lineEnd = firstMatch.group(2) ?? '';
//     // final earlyMatch = pattern.firstMatch(lineEnd);

//     // if (earlyMatch != null)
//     //   return childLines
//     //     ..add(earlyMatch.group(1) ?? '')
//     //     ..add(earlyMatch.group(2) ?? '');

//     // childLines.add(lineEnd);
//     // parser.advance();

//     // while (!parser.isDone) {
//     //   final match = pattern.firstMatch(parser.current);
//     //   if (match == null) {
//     //     childLines.add(parser.current);
//     //     parser.advance();
//     //   } else {
//     //     childLines..add(match.group(1) ?? '')..add(match.group(2) ?? '');
//     //     parser.advance();
//     //     break;
//     //   }
//     // }

//     // return childLines;
//   }

//   @override
//   Node? parse(BlockParser parser) {
//     final lines = parseChildLines(parser);
//     if (lines.length < 3) return null;

//     final prefix = BlockParser([lines.first], parser.document).parseLines();
//     final postfix = BlockParser([lines.last], parser.document).parseLines();
//     final children = BlockParser(
//       lines.sublist(1, lines.length - 1),
//       parser.document,
//     ).parseLines();

//     return Element('p', [...prefix, Element('center', children), ...postfix]);
//   }
// }

// class _SpoilerSyntax extends BlockSyntax {
//   const _SpoilerSyntax();

//   @override
//   RegExp get pattern => RegExp(r'~!');

//   @override
//   bool canParse(BlockParser parser) => parser.current.contains('~!');

//   // The text before the opening '~!' is the first element (prefix)
//   // The text after  the closing '!~' is the last  element (postfix)
//   @override
//   List<String> parseChildLines(BlockParser parser) {
//     final childLines = <String>[];
//     const end = '!~';

//     int startIndex = parser.current.indexOf('~!');
//     childLines.add(parser.current.substring(0, startIndex));

//     startIndex += 2;
//     if (startIndex < parser.current.length) {
//       final lineEnd = parser.current.substring(startIndex);
//       int endIndex = lineEnd.indexOf(end);

//       if (endIndex >= 0) {
//         childLines.add(lineEnd.substring(0, endIndex));

//         endIndex += 2;
//         if (endIndex < lineEnd.length)
//           childLines.add(lineEnd.substring(endIndex));
//         else
//           childLines.add('');

//         return childLines;
//       }

//       childLines.add(lineEnd);
//     }

//     parser.advance();

//     while (!parser.isDone) {
//       int endIndex = parser.current.indexOf(end);

//       if (endIndex < 0) {
//         childLines.add(parser.current);
//         parser.advance();
//         continue;
//       }

//       childLines.add(parser.current.substring(0, endIndex));

//       endIndex += 2;
//       if (endIndex < parser.current.length)
//         childLines.add(parser.current.substring(endIndex));
//       else if (childLines.last != '') childLines.add('');

//       parser.advance();
//       return childLines;
//     }

//     return [];
//   }

//   @override
//   Node? parse(BlockParser parser) {
//     final lines = parseChildLines(parser);
//     if (lines.length < 3) return null;

//     final prefix = BlockParser([lines.first], parser.document).parseLines();
//     final postfix = BlockParser([lines.last], parser.document).parseLines();
//     final text = renderToHtml(parser.document.parseInline(
//       lines.sublist(1, lines.length - 1).join('\n'),
//     ));

//     return Element('p', [...prefix, Element.text('spoiler', text), ...postfix]);
//   }
// }
