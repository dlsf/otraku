import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/utils/markdown.dart';
import 'package:otraku/widgets/loaders.dart/loader.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class MarkdownContent extends StatelessWidget {
  final Markdown markdown;

  MarkdownContent(this.markdown);

  @override
  Widget build(BuildContext context) => FutureBuilder<Widget>(
        future: _future(),
        builder: (_, snapshot) => snapshot.data ?? const _Placeholder(),
      );

  Future<Widget> _future() async {
    await markdown.parse();
    return HtmlContent(markdown.text);
  }
}

class HtmlContent extends StatelessWidget {
  final String html;

  HtmlContent(this.html);

  @override
  Widget build(BuildContext context) {
    return HtmlWidget(
      html,
      textStyle: Theme.of(context).textTheme.bodyText2,
      hyperlinkColor: Theme.of(context).accentColor,
      onTapUrl: (url) async {
        try {
          await launch(url);
        } catch (err) {
          Toast.show(context, 'Couldn\'t open link: $err');
        }
      },
      buildAsyncBuilder: (_, snapshot) => snapshot.data ?? const _Placeholder(),
      customStylesBuilder: (element) {
        if (element.localName == 'h1' ||
            element.localName == 'h2' ||
            element.localName == 'h3') return {'font-size': '20px'};
        if (element.localName == 'b' || element.localName == 'strong')
          return {'font-weight': '500'};
        if (element.localName == 'i' || element.localName == 'em')
          return {'font-style': 'italic'};
        return null;
      },
      customWidgetBuilder: (element) {
        if (element.localName == 'hr')
          return Container(
            height: 5,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: Theme.of(context).disabledColor,
              borderRadius: Config.BORDER_RADIUS,
            ),
          );

        if (element.localName == 'spoiler')
          return Center(
            child: ElevatedButton.icon(
              label: const Text('Spoiler'),
              icon: const Icon(Ionicons.eye_off_outline),
              onPressed: () => showPopUp(
                context,
                HtmlDialog(title: 'Spoiler', html: element.innerHtml),
              ),
            ),
          );

        return null;
      },
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();
  @override
  Widget build(BuildContext context) => const Center(child: Loader());
}
