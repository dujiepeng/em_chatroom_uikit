import 'package:chatroom_uikit/chatroom_uikit.dart';

import 'package:flutter/material.dart';

class DefaultMutesController extends ChatRoomParticipantPageController {
  int pageSize = 20;
  int pageNum = 1;

  @override
  Future<List<String>> loadMoreUsers(String roomId, String ownerId) async {
    try {
      List<String> result = await ChatRoomUIKitClient.instance
          .fetchMutes(roomId, pageNum, pageNum);

      pageNum++;
      return result;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<String>> reloadUsers(String roomId, String ownerId) async {
    pageNum = 1;
    try {
      List<String> result = await ChatRoomUIKitClient.instance
          .fetchMutes(roomId, pageNum, pageNum);
      return result;
    } catch (e) {
      return [];
    }
  }

  @override
  List<ChatEventItemAction>? itemMoreActions(
      BuildContext context, String? roomId, String? ownerId) {
    if (Client.getInstance.currentUserId != ownerId) return null;
    return [
      ChatEventItemAction(
        title: ChatroomLocal.bottomSheetUnmute.getString(context),
        onPressed: (context, roomId, userId, user) async {
          try {
            await ChatRoomUIKitClient.instance.operatingUser(
              roomId: roomId,
              userId: userId,
              type: ChatroomUserOperationType.unmute,
            );
            // ignore: empty_catches
          } catch (e) {}
        },
      ),
      ChatEventItemAction(
        title: ChatroomLocal.bottomSheetRemove.getString(context),
        highlight: true,
        onPressed: (context, roomId, userId, user) async {
          showDialog(
            context: context,
            builder: (context) {
              return ChatDialog(
                title:
                    "${ChatroomLocal.wantRemove.getString(context)} '@${user?.nickname ?? userId}'",
                items: [
                  ChatDialogItem.cancel(
                    onTap: () async {
                      Navigator.of(context).pop();
                    },
                  ),
                  ChatDialogItem.confirm(
                    onTap: () async {
                      Navigator.of(context).pop();
                      try {
                        await ChatRoomUIKitClient.instance.roomService
                            .operatingUser(
                          roomId: roomId,
                          userId: userId,
                          type: ChatroomUserOperationType.kick,
                        );
                        // ignore: empty_catches
                      } catch (e) {}
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    ];
  }

  @override
  String title(BuildContext context, String? roomId, String? ownerId) {
    return ChatroomLocal.muteListTitle.getString(context);
  }
}
