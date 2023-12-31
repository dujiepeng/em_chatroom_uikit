import 'package:chatroom_uikit/chatroom_uikit.dart';
import 'package:flutter/material.dart';

typedef EmojiClick = void Function(String emoji);

class ChatInputEmoji extends StatelessWidget {
  static List<String> emojis = [
    '[U+1F600.png]',
    '[U+1F604.png]',
    '[U+1F609.png]',
    '[U+1F62E.png]',
    '[U+1F92A.png]',
    '[U+1F60E.png]',
    '[U+1F971.png]',
    '[U+1F974.png]',
    '[U+263A.png]',
    '[U+1F641.png]',
    '[U+1F62D.png]',
    '[U+1F610.png]',
    '[U+1F607.png]',
    '[U+1F62C.png]',
    '[U+1F913.png]',
    '[U+1F633.png]',
    '[U+1F973.png]',
    '[U+1F620.png]',
    '[U+1F644.png]',
    '[U+1F910.png]',
    '[U+1F97A.png]',
    '[U+1F928.png]',
    '[U+1F62B.png]',
    '[U+1F637.png]',
    '[U+1F912.png]',
    '[U+1F631.png]',
    '[U+1F618.png]',
    '[U+1F60D.png]',
    '[U+1F922.png]',
    '[U+1F47F.png]',
    '[U+1F92C.png]',
    '[U+1F621.png]',
    '[U+1F44D.png]',
    '[U+1F44E.png]',
    '[U+1F44F.png]',
    '[U+1F64C.png]',
    '[U+1F91D.png]',
    '[U+1F64F.png]',
    '[U+2764.png]',
    '[U+1F494.png]',
    '[U+1F495.png]',
    '[U+1F4A9.png]',
    '[U+1F48B.png]',
    '[U+2600.png]',
    '[U+1F31C.png]',
    '[U+1F308.png]',
    '[U+2B50.png]',
    '[U+1F31F.png]',
    '[U+1F389.png]',
    '[U+1F490.png]',
    '[U+1F382.png]',
    '[U+1F381.png]',
  ];

  const ChatInputEmoji({
    this.deleteOnTap,
    this.crossAxisCount = 7,
    this.mainAxisSpacing = 2.0,
    this.crossAxisSpacing = 2.0,
    this.childAspectRatio = 1.0,
    this.bigSizeRatio = 0.0,
    this.emojiClicked,
    super.key,
  });

  final int crossAxisCount;

  final double mainAxisSpacing;

  final double crossAxisSpacing;

  final double childAspectRatio;

  final double bigSizeRatio;

  final EmojiClick? emojiClicked;

  final VoidCallback? deleteOnTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 280,
          child: GridView.custom(
            controller: ScrollController(),
            padding:
                const EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 60),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: mainAxisSpacing,
              crossAxisSpacing: crossAxisSpacing,
            ),
            childrenDelegate: SliverChildBuilderDelegate((context, position) {
              return _getEmojiItemContainer(position);
            }, childCount: emojis.length),
          ),
        ),
        Positioned(
          right: 20,
          width: 36,
          bottom: 20,
          height: 36,
          child: InkWell(
            onTap: deleteOnTap?.call,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                boxShadow: ChatUIKitTheme.of(context).color.isDark
                    ? ChatUIKitShadow.darkSmall
                    : ChatUIKitShadow.lightSmall,
                borderRadius: BorderRadius.circular(24),
                color: (ChatUIKitTheme.of(context).color.isDark
                    ? ChatUIKitTheme.of(context).color.neutralColor3
                    : ChatUIKitTheme.of(context).color.neutralColor98),
              ),
              child: ChatImageLoader.delete(
                size: 40,
                color: (ChatUIKitTheme.of(context).color.isDark
                    ? ChatUIKitTheme.of(context).color.neutralColor98
                    : ChatUIKitTheme.of(context).color.neutralColor3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  _getEmojiItemContainer(int index) {
    var emoji = emojis[index];
    return ChatExpression(emoji, bigSizeRatio, emojiClicked);
  }
}

class ChatExpression extends StatelessWidget {
  final String emoji;

  final double bigSizeRatio;

  final EmojiClick? emojiClicked;

  const ChatExpression(
    this.emoji,
    this.bigSizeRatio,
    this.emojiClicked, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Widget icon = ChatImageLoader.emoji(emoji, size: 36);
    return TextButton(
      style: ButtonStyle(
        padding: MaterialStateProperty.all(
          EdgeInsets.all(bigSizeRatio),
        ),
      ),
      onPressed: () {
        emojiClicked?.call(emoji);
      },
      child: icon,
    );
  }
}

class EmojiMapping {
  // 将字符串中所有ChatInputEmoji.emoji中的字段替换为 mappingList 中的字段
  static String replaceEmoji(String str) {
    var result = str;
    for (var emoji in ChatInputEmoji.emojis) {
      result = result.replaceAll(
          emoji, mappingList[ChatInputEmoji.emojis.indexOf(emoji)]);
    }
    return result;
  }

  // 将字符串中所有mappingList中的字段替换为ChatInputEmoji.emoji中的字段
  static String replaceEmojiBack(String str) {
    var result = str;
    for (var emoji in mappingList) {
      result = result.replaceAll(
          emoji, ChatInputEmoji.emojis[mappingList.indexOf(emoji)]);
    }
    return result;
  }

  static final mappingList = [
    'U+1F600',
    'U+1F604',
    'U+1F609',
    'U+1F62E',
    'U+1F92A',
    'U+1F60E',
    'U+1F971',
    'U+1F974',
    'U+263A',
    'U+1F641',
    'U+1F62D',
    'U+1F610',
    'U+1F607',
    'U+1F62C',
    'U+1F913',
    'U+1F633',
    'U+1F973',
    'U+1F620',
    'U+1F644',
    'U+1F910',
    'U+1F97A',
    'U+1F928',
    'U+1F62B',
    'U+1F637',
    'U+1F912',
    'U+1F631',
    'U+1F618',
    'U+1F60D',
    'U+1F922',
    'U+1F47F',
    'U+1F92C',
    'U+1F621',
    'U+1F44D',
    'U+1F44E',
    'U+1F44F',
    'U+1F64C',
    'U+1F91D',
    'U+1F64F',
    'U+2764',
    'U+1F494',
    'U+1F495',
    'U+1F4A9',
    'U+1F48B',
    'U+2600',
    'U+1F31C',
    'U+1F308',
    'U+2B50',
    'U+1F31F',
    'U+1F389',
    'U+1F490',
    'U+1F382',
    'U+1F381',
  ];
}
