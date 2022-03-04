// import 'package:flutter/foundation.dart';
import 'package:markdown/markdown.dart';

class Markdown {
  Markdown(this.text);

  String text;
  bool _parsed = false;

  bool get parsed => _parsed;

  void parse() {
    if (_parsed) return;
    final stopwatch = Stopwatch();
    stopwatch.start();
    text = markdownToHtml(
      text,
      extensionSet: ExtensionSet.none,
      blockSyntaxes: _blockSyntaxes,
      inlineSyntaxes: _inlineSyntaxes,
    );
    stopwatch.stop();
    print('elapsed time: ${stopwatch.elapsedMilliseconds}');
    _parsed = true;
  }

  // Future<void> parse() async {
  //   if (_parsed) return;
  //   text = await compute(_parse, text);
  //   _parsed = true;
  // }

  // String _parse(String data) => markdownToHtml(
  //       data,
  //       extensionSet: ExtensionSet.none,
  //       blockSyntaxes: _blockSyntaxes,
  //       inlineSyntaxes: _inlineSyntaxes,
  //     );

  static const _blockSyntaxes = [
    BlockquoteSyntax(),
    UnorderedListSyntax(),
    HorizontalRuleSyntax(),
    _CenterSyntax(),
    _FencedCodeBlockLimitedSyntax(),
  ];

  static final _inlineSyntaxes = [
    LinkSyntax(),
    CodeSyntax(),
    EscapeSyntax(),
    StrikethroughSyntax(),
    _BoldSyntax(),
    _ItalicSyntax(),
  ];
}

// TODO not matching?
class _BoldSyntax extends TagSyntax {
  _BoldSyntax() : super(r'\*\*', requiresDelimiterRun: true);

  @override
  bool tryMatch(InlineParser parser, [int? startMatchPos]) {
    print('try');
    final a = super.tryMatch(parser, startMatchPos);
    print('with $a');
    return a;
  }

  @override
  Node close(
    InlineParser parser,
    Delimiter opener,
    Delimiter closer, {
    required List<Node> Function() getChildren,
  }) {
    print('was here');
    return Element('b', getChildren());
  }
}

class _ItalicSyntax extends TagSyntax {
  _ItalicSyntax() : super(r'\*', requiresDelimiterRun: true);

  @override
  Node close(
    InlineParser parser,
    Delimiter opener,
    Delimiter closer, {
    required List<Node> Function() getChildren,
  }) =>
      Element('i', getChildren());
}

// AL markdown treats content surrounded with ~~~ as centered,
// instead of code, so it should be excluded from this pattern.
class _FencedCodeBlockLimitedSyntax extends FencedCodeBlockSyntax {
  const _FencedCodeBlockLimitedSyntax();

  @override
  RegExp get pattern => _codeFencePattern;

  static final _codeFencePattern = RegExp(r'^[ ]{0,3}(`{3,})(.*)$');
}

// Centering with a pair of ~~~
class _CenterSyntax extends BlockSyntax {
  const _CenterSyntax();

  @override
  RegExp get pattern => RegExp('~~~');

  @override
  bool canParse(BlockParser parser) => parser.current.contains('~~~');

  // The text before the opening ~~~ is the first element (prefix)
  // The text after  the closing ~~~ is the last  element (postfix)
  @override
  List<String> parseChildLines(BlockParser parser) {
    final childLines = <String>[];

    int startIndex = parser.current.indexOf('~~~');
    childLines.add(parser.current.substring(0, startIndex));

    startIndex += 3;
    if (startIndex < parser.current.length) {
      final lineEnd = parser.current.substring(startIndex);
      int endIndex = lineEnd.indexOf('~~~');

      if (endIndex >= 0) {
        childLines.add(lineEnd.substring(0, endIndex));

        endIndex += 3;
        if (endIndex < lineEnd.length)
          childLines.add(lineEnd.substring(endIndex));
        else
          childLines.add('');

        parser.advance();
        return childLines;
      }

      childLines.add(lineEnd);
    }

    parser.advance();

    while (!parser.isDone) {
      int endIndex = parser.current.indexOf('~~~');

      if (endIndex < 0) {
        childLines.add(parser.current);
        parser.advance();
        continue;
      }

      childLines.add(parser.current.substring(0, endIndex));

      endIndex += 3;
      if (endIndex < parser.current.length)
        childLines.add(parser.current.substring(endIndex));
      else
        childLines.add('');

      parser.advance();
      return childLines;
    }

    return [];
  }

  @override
  Node? parse(BlockParser parser) {
    final lines = parseChildLines(parser);
    if (lines.length < 3) return null;

    final prefix = BlockParser([lines.first], parser.document).parseLines();
    final postfix = BlockParser([lines.last], parser.document).parseLines();
    final children = BlockParser(
      lines.sublist(1, lines.length - 1),
      parser.document,
    ).parseLines();

    return Element('p', [...prefix, Element('center', children), ...postfix]);
  }
}

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
