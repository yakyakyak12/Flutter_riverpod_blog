import 'package:flutter/material.dart';
import 'package:flutter_blog/_core/constants/http.dart';
import 'package:flutter_blog/_core/constants/move.dart';
import 'package:flutter_blog/data/dto/response_dto.dart';
import 'package:flutter_blog/data/dto/user_request.dart';
import 'package:flutter_blog/data/model/user.dart';
import 'package:flutter_blog/data/repository/user_repository.dart';
import 'package:flutter_blog/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. 창고 데이터
class SessionUser {
  // 1. 화면 context에 접근하는 법
  final mContext = navigatorKey.currentContext;

  User? user;
  String? jwt;
  bool isLogin; // 토큰이 유효하면 true이런식으로 체크 할 것이다.

  SessionUser({this.user, this.jwt, this.isLogin = false});

  Future<void> join(JoinReqDTO joinReqDTO) async {
    // 1. 통신 코드
    ResponseDTO responseDTO = await UserRepository().fetchJoin(joinReqDTO);

    // 2. 비지니스 로직
    if (responseDTO.code == 1) {
      Navigator.pushNamed(mContext!, Move.loginPage);
    } else {
      ScaffoldMessenger.of(mContext!)
          .showSnackBar(SnackBar(content: Text(responseDTO.msg)));
    }
  }

  Future<void> login(LoginReqDTO loginReqDTO) async {
    // 1. 통신 코드
    ResponseDTO responseDTO = await UserRepository().fetchLogin(loginReqDTO);

    // 2. 비지니스 로직
    if (responseDTO.code == 1) {
      // 1. 로그인 성공 시 세션값 갱신(창고 데이터 갱신)
      this.user = responseDTO.data as User;
      this.jwt = responseDTO.token;
      this.isLogin = true;

      // 2. 디바이스에 JWT 저장 (자동 로그인)
      await secureStorage.write(key: "jwt", value: responseDTO.token);

      // 3. 페이지 이동

      Navigator.pushNamed(mContext!, Move.postListPage);
    } else {
      ScaffoldMessenger.of(mContext!)
          .showSnackBar(SnackBar(content: Text(responseDTO.msg)));
    }
  }

  // JWT는 로그아웃할 때 서버측으로 요청할 필요가 없다.
  Future<void> logout() async {
    this.jwt = null;
    this.isLogin = false;
    this.user = null;

    await secureStorage.delete(key: "jwt");

    // 지금까지 쌓인 모든 것들을 날림.
    Navigator.pushNamedAndRemoveUntil(mContext!, "/login", (route) => false);
  }
}

// 2. 창고 관리자
final sessionProvider = Provider<SessionUser>((ref) {
  return SessionUser();
});
