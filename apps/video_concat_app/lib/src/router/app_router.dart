import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../views/home/home_page.dart';
import '../views/settings/settings_page.dart';
import '../views/trim/trim_page.dart';
import '../views/video_info/video_info_page.dart';

part 'app_router.g.dart';

/// 应用路由
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomePage()),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/trim',
        builder: (context, state) {
          final videoId = state.uri.queryParameters['id'] ?? '';
          return TrimPage(videoId: videoId);
        },
      ),
      GoRoute(
        path: '/video-info',
        builder: (context, state) {
          final filePath = state.uri.queryParameters['path'] ?? '';
          final refPath = state.uri.queryParameters['ref'];
          return VideoInfoPage(filePath: filePath, refPath: refPath);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('错误')),
      body: Center(child: Text('页面不存在: ${state.uri}')),
    ),
  );
}
