import 'package:chatroom_uikit/chatroom_uikit.dart';

import 'package:flutter/material.dart';

class ChatTextEditingController extends TextEditingController {
  List<EmojiIndex> includeEmojis = [];

  // @override
  // set value(TextEditingValue newValue) {
  //   super.value = newValue;
  //   debugPrint('value: $newValue');
  // }

  @override
  set selection(TextSelection newSelection) {
    super.selection = newSelection;
    debugPrint('selection: $selection');
  }

  @override
  set text(String newText) {
    value = value.copyWith(
      text: newText,
      selection: TextSelection.fromPosition(
        TextPosition(
          affinity: TextAffinity.downstream,
          offset: value.selection.extentOffset + newText.length,
        ),
      ),
      composing: TextRange.empty,
    );
  }

  @override
  TextSpan buildTextSpan(
      {required BuildContext context,
      TextStyle? style,
      required bool withComposing}) {
    int firstIndex = 0;
    includeEmojis.clear();
    do {
      firstIndex = text.indexOf('[', firstIndex);
      if (firstIndex != -1 && text.isNotEmpty) {
        final secondIndex = text.indexOf(']', firstIndex);
        if (secondIndex != -1) {
          String subTxt = text.substring(firstIndex, secondIndex + 1);
          if (ChatInputEmoji.emojis.contains(subTxt)) {
            includeEmojis.add(EmojiIndex(
              index: firstIndex,
              length: subTxt.length,
              emoji: subTxt,
            ));
          }
        } else {
          break;
        }
        firstIndex = secondIndex + 1;
      }
    } while (firstIndex != -1);

    List<InlineSpan> tp = [];

    if (includeEmojis.isNotEmpty) {
      int index = 0;
      for (var item in includeEmojis) {
        if (item.index > index) {
          tp.add(TextSpan(
            text: text.substring(index, item.index),
            style: style,
          ));
        }
        tp.add(
          WidgetSpan(
            child: ChatImageLoader.emoji(item.emoji, size: 20),
          ),
        );
        index = item.index + item.length;
      }
      if (index < text.length) {
        tp.add(TextSpan(
          text: text.substring(index, text.length),
          style: style,
        ));
      }
    } else {
      tp.add(TextSpan(
        text: text,
        style: style,
      ));
    }

    return TextSpan(children: tp);
  }

  void addEmoji(String emoji) {
    text = text + emoji;
    // value = TextEditingValue(
    //   text: text + emoji,
    //   selection: TextSelection.fromPosition(
    //     TextPosition(
    //       affinity: TextAffinity.downstream,
    //       offset: emoji.length,
    //     ),
    //   ),
    // );
  }

  void deleteOnTap([int index = -1]) {
    TextEditingValue value = this.value;
    if (value.text.isNotEmpty) {
      int currentIndex = value.selection.extentOffset;
      if (currentIndex == 0) {
        return;
      }

      String subText = value.text.substring(0, currentIndex);
      do {
        // 如果当前光标结尾是], 并且包含[, 需要判断它们之间是否是表情
        if (subText.endsWith(']')) {
          int index = subText.lastIndexOf('[');
          if (index == -1) {
            break;
          } else {
            String content = subText.substring(index);
            // 判断是否是表情
            if (ChatInputEmoji.emojis.contains(content)) {
              // 如果是表情，需要移除[]之间的所有内容
              subText = subText.substring(0, index);
            }
          }
        }
      } while (false);

      subText = subText + value.text.substring(currentIndex);

      this.value = value.copyWith(
        text: subText,
        selection: TextSelection.fromPosition(
          TextPosition(
            affinity: TextAffinity.downstream,
            offset: currentIndex - 1,
          ),
        ),
      );
    }

    return;
  }
}

class EmojiIndex {
  int index;
  int length;
  String emoji;
  EmojiIndex({
    required this.index,
    required this.length,
    required this.emoji,
  });
}
