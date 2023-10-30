import 'package:flutter/widgets.dart';
import 'package:otraku/common/utils/consts.dart';

/// Horizontally constrains [child] into the center.
class ConstrainedView extends StatelessWidget {
  const ConstrainedView({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Consts.layoutBig),
          child: child,
        ),
      ),
    );
  }
}

class SliverConstrainedView extends StatelessWidget {
  const SliverConstrainedView({required this.sliver});

  final Widget sliver;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final side = (constraints.crossAxisExtent - Consts.layoutMedium) / 2;
        return SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: side < 10 ? 10 : side),
          sliver: sliver,
        );
      },
    );
  }
}
