import 'package:chatroom_uikit/chatroom_uikit.dart';
import 'package:chatroom_uikit/utils/extension.dart';

class UserEntity extends UserInfoProtocol {
  @override
  final String userId;

  @override
  final String? nickname;

  @override
  final String? avatarURL;

  @override
  final int? gender;

  @override
  final String? identify;

  UserEntity(
    this.userId, {
    this.nickname,
    this.avatarURL,
    this.gender = 1,
    this.identify,
  });

  UserEntity.fromJson(
    Map<String, dynamic> json,
  )   : userId = json["userId"]!,
        nickname = json['nickName'],
        avatarURL = json['avatarURL'],
        gender = json['gender'],
        identify = json['identify'];

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {};
    map.putIfNotNull('userId', userId);
    map.putIfNotNull('nickName', nickname);
    map.putIfNotNull('avatarURL', avatarURL);
    map.putIfNotNull('gender', gender);
    map.putIfNotNull('identify', identify);

    return map;
  }
}
