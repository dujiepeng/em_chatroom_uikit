import 'dart:convert';

import 'package:chatroom_uikit/chatroom_uikit.dart';

class UserServiceImplement extends UserService {
  List<UserStateChangedResponse> responseDelegates = [];

  UserServiceImplement({
    UserInfoProtocol? userInfo,
  }) {
    _addListener();
    if (userInfo != null) {
      updateUserInfo(user: userInfo);
    }
  }

  @override
  void dispose() {
    _removeListener();
  }

  @override
  void bindResponse(UserStateChangedResponse response) {
    if (responseDelegates.contains(response)) {
      return;
    }
    responseDelegates.add(response);
  }

  @override
  void unbindResponse(UserStateChangedResponse response) {
    responseDelegates.remove(response);
  }

  @override
  Future<void> login({
    required String userId,
    required String token,
  }) async {
    userId = userId.trim()..toLowerCase();
    await Client.getInstance.login(userId, token, false);
    await Client.getInstance.startCallback();
  }

  @override
  Future<void> logout() async {
    await Client.getInstance.logout(true);
  }

  @override
  Future<List<UserInfoProtocol>> fetchUserInfos({
    required List<String> userIds,
  }) async {
    Map<String, UserInfo> map =
        await Client.getInstance.userInfoManager.fetchUserInfoById(userIds);
    List<UserInfoProtocol> list = [];
    for (var element in map.values) {
      list.add(convertUserInfo(element));
    }

    ChatRoomContext.instance.updateUserInfos(list);

    return list;
  }

  @override
  Future<void> updateUserInfo({UserInfoProtocol? user}) async {
    if (user == null) return;

    String? identifyMap;
    if (user.identify?.isNotEmpty == true) {
      identifyMap = json.encode({'identify': user.identify});
    }
    await Client.getInstance.userInfoManager.updateUserInfo(
      nickname: user.nickname,
      avatarUrl: user.avatarURL,
      gender: user.gender,
      ext: identifyMap,
    );
    ChatRoomContext.instance.updateUserInfos([user]);
  }

  UserInfoProtocol convertUserInfo(UserInfo user) {
    String? identify;
    if (user.ext?.isNotEmpty == true) {
      try {
        identify = json.decode(user.ext!)['identify'];
        // ignore: empty_catches
      } catch (e) {}
    }
    return UserEntity(
      user.userId,
      avatarURL: user.avatarUrl,
      nickname: user.nickName,
      gender: user.gender,
      identify: identify,
    );
  }

  @override
  UserInfoProtocol? userFromJson(Map<String, dynamic>? json) {
    if (json?.isNotEmpty == true) {
      return UserEntity.fromJson(json!);
    }
    return null;
  }

  @override
  Map<String, dynamic>? userToJson(UserInfoProtocol? giftEntityProtocol) {
    if (giftEntityProtocol == null) return null;
    return (giftEntityProtocol as UserEntity).toJson();
  }
}

extension _ChatClientListener on UserServiceImplement {
  void _addListener() {
    Client.getInstance.addConnectionEventHandler(
      'UserServiceImplement',
      ConnectionEventHandler(
        onTokenDidExpire: () {
          for (var element in responseDelegates) {
            element.onUserTokenDidExpired();
          }
        },
        onTokenWillExpire: () {
          for (var element in responseDelegates) {
            element.onUserTokenWillExpired();
          }
        },
        onUserDidLoginFromOtherDevice: (deviceName) {
          for (var element in responseDelegates) {
            element.onUserLoginOtherDevice(deviceName);
          }
        },
        onConnected: () {
          for (var element in responseDelegates) {
            element.onSocketConnectionStateChanged(true);
          }
        },
        onDisconnected: () {
          for (var element in responseDelegates) {
            element.onSocketConnectionStateChanged(false);
          }
        },
        onUserDidForbidByServer: () {
          for (var element in responseDelegates) {
            element.userDidForbidden();
          }
        },
        onUserDidRemoveFromServer: () {
          for (var element in responseDelegates) {
            element.userAccountDidRemoved();
          }
        },
      ),
    );
  }

  void _removeListener() {
    Client.getInstance.removeConnectionEventHandler('UserServiceImplement');
  }
}
