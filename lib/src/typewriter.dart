import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

/// Custom Animated Text that displays a [Text] element as if it is being typed one
/// character at a time with support for styling untyped text.
///
/// This extends the standard TypewriterAnimatedText to show the remaining
/// (not yet typed) text with a custom style.
class TypewriterAnimatedText extends AnimatedText {
  // The text length is padded to cause extra cursor blinking after typing.
  static const extraLengthForBlinks = 8;

  /// The [Duration] of the delay between the apparition of each characters
  ///
  /// By default it is set to 30 milliseconds.
  final Duration speed;

  /// The [Curve] of the rate of change of animation over time.
  ///
  /// By default it is set to Curves.linear.
  final Curve curve;

  /// Cursor text. Defaults to underscore.
  final String cursor;

  /// Text style for the untyped (remaining) text.
  /// If null, the remaining text will not be shown.
  final TextStyle? untypedTextStyle;

  TypewriterAnimatedText(
    String text, {
    TextAlign textAlign = TextAlign.start,
    TextStyle? textStyle,
    this.speed = const Duration(milliseconds: 30),
    this.curve = Curves.linear,
    this.cursor = '_',
    this.untypedTextStyle,
  }) : super(
          text: text,
          textAlign: textAlign,
          textStyle: textStyle,
          duration: speed * (text.characters.length + extraLengthForBlinks),
        );

  late Animation<double> _typewriterText;

  @override
  Duration get remaining =>
      speed *
      (textCharacters.length + extraLengthForBlinks - _typewriterText.value);

  @override
  void initAnimation(AnimationController controller) {
    _typewriterText = CurveTween(
      curve: curve,
    ).animate(controller);
  }

  @override
  Widget completeText(BuildContext context) => RichText(
        text: TextSpan(
          children: [
            TextSpan(text: text),
            TextSpan(
              text: cursor,
              style: const TextStyle(color: Colors.transparent),
            )
          ],
          style: DefaultTextStyle.of(context).style.merge(textStyle),
        ),
        textAlign: textAlign,
      );

  /// Widget showing partial text with styled remaining text
  @override
  Widget animatedBuilder(BuildContext context, Widget? child) {
    /// Output of CurveTween is in the range [0, 1] for majority of the curves.
    /// It is converted to [0, textCharacters.length + extraLengthForBlinks].
    final textLen = textCharacters.length;
    final typewriterValue = (_typewriterText.value.clamp(0, 1) *
            (textCharacters.length + extraLengthForBlinks))
        .round();

    var showCursor = true;
    var visibleString = text;
    String remainingString = '';

    if (typewriterValue == 0) {
      visibleString = '';
      remainingString = text;
      showCursor = false;
    } else if (typewriterValue > textLen) {
      showCursor = (typewriterValue - textLen) % 2 == 0;
      remainingString = '';
    } else {
      visibleString = textCharacters.take(typewriterValue).toString();
      remainingString = textCharacters.skip(typewriterValue).toString();
    }

    return RichText(
      text: TextSpan(
        children: [
          // Typed (visible) text
          TextSpan(
            text: visibleString,
            style: DefaultTextStyle.of(context).style.merge(textStyle),
          ),
          // Cursor
          TextSpan(
            text: cursor,
            style: showCursor
                ? DefaultTextStyle.of(context).style.merge(textStyle)
                : const TextStyle(color: Colors.transparent),
          ),
          // Remaining (untyped) text - only shown if untypedTextStyle is provided
          if (untypedTextStyle != null && remainingString.isNotEmpty)
            TextSpan(
              text: remainingString,
              style: DefaultTextStyle.of(context).style.merge(untypedTextStyle),
            ),
        ],
      ),
      textAlign: textAlign,
    );
  }
}
