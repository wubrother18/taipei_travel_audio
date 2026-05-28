import 'dart:io';

import 'package:path/path.dart' hide context;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:taipei_travel_audio/services/api_service.dart';

class AudioState {
  final String? message;
  final String lang;
  final bool isLoading;
  final bool hasMore;
  final int page;
  final List<Map> audioList;
  final List<int> pendingList;
  final Map<int, String> localList;

  const AudioState({
    this.lang = 'zh-tw',
    this.message,
    this.isLoading = false,
    this.hasMore = true,
    this.page = 1,
    this.audioList = const [],
    this.pendingList = const [],
    this.localList = const {},
  });

  AudioState copyWith({
    String? lang,
    String? message,
    bool? isLoading,
    bool? hasMore,
    int? page,
    List<Map>? audioList,
    List<int>? pendingList,
    Map<int, String>? localList,
  }) {
    return AudioState(
      lang: lang ?? this.lang,
      message: message ?? this.message,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      audioList: audioList ?? this.audioList,
      pendingList: pendingList ?? this.pendingList,
      localList: localList ?? this.localList,
    );
  }
}

final audioProvider = NotifierProvider<AudioNotifier, AudioState>(
  AudioNotifier.new,
);

class AudioNotifier extends Notifier<AudioState> {
  @override
  AudioState build() {
    _scanLocalFiles();
    return const AudioState();
  }

  void setLang(String lang) {
    state = state.copyWith(lang: lang, audioList: [], page: 1, hasMore: true);
    fetchList(clean: true);
  }

  Future<void> fetchList({bool clean = false}) async {
    if (state.isLoading) return;

    final nextPage = clean ? 1 : state.page;
    state = state.copyWith(
      isLoading: true,
      audioList: clean ? [] : null,
      message: null,
    );
    final res = await ApiService().getList(state.lang, nextPage);
    if (res.statusCode != 200) {
      state = state.copyWith(isLoading: false, message: '載入失敗，請下拉重新整理');
      return;
    }
    final List newItems = res.data['data'] ?? [];
    state = state.copyWith(
      isLoading: false,
      audioList: [...state.audioList, ...newItems.cast<Map>()],
      page: nextPage + 1,
      hasMore: newItems.isNotEmpty,
    );
  }

  Future<bool> downloadFile(String url, int id, String title) async {
    state = state.copyWith(pendingList: [...state.pendingList, id]);
    final audioDir = await _getDir();
    final safeName = title.replaceAll(RegExp(r'[/\\:*?"<>|]'), '_');
    final result = await ApiService().downloadFile(
      url,
      '${audioDir.path}/${id}_$safeName',
    );
    final newPending = [...state.pendingList]..remove(id);
    state = state.copyWith(
      pendingList: newPending,
      localList: result ? {...state.localList, id: title} : null,
      message: result ? null : '下載失敗，請稍後再試',
    );
    return result;
  }

  Future<String> getFilePath(int id) async {
    final dir = await _getDir();
    final entities = await dir.list().toList();
    for (final e in entities) {
      if (basename(e.path).startsWith('${id}_')) {
        return e.path;
      }
    }
    return '${dir.path}/$id';
  }

  Future<Directory> _getDir() async {
    final docDir = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${docDir.path}/audioDir');
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    return audioDir;
  }

  Future<void> _scanLocalFiles() async {
    final dir = await _getDir();
    final entities = await dir.list().toList();
    final localMap = <int, String>{};
    for (final e in entities) {
      final name = basename(e.path);
      final underscoreIndex = name.indexOf('_');
      if (underscoreIndex > 0) {
        final id = int.tryParse(name.substring(0, underscoreIndex));
        final title = name.substring(underscoreIndex + 1);
        if (id != null) localMap[id] = title;
      }
    }
    if (localMap.isNotEmpty) {
      state = state.copyWith(localList: localMap);
    }
  }

  Future<void> deleteFile(int id) async {
    final dir = await _getDir();
    final entities = await dir.list().toList();
    for (final e in entities) {
      if (basename(e.path).startsWith('${id}_')) {
        await e.delete();
        break;
      }
    }
    final newLocal = Map<int, String>.from(state.localList)..remove(id);
    state = state.copyWith(localList: newLocal);
  }
}
