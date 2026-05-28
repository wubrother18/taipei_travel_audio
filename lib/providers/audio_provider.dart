import 'dart:io';

import 'package:path/path.dart' hide context;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:taipei_travel_audio/services/api_service.dart';

class AudioState {
  final String? message;
  final bool isLoading;
  final bool hasMore;
  final int page;
  final List<Map> audioList;
  final List<int> pendingList;
  final List<int> localList;

  const AudioState({this.message, this.isLoading = false, this.hasMore = true, this.page = 1, this.audioList = const [], this.pendingList = const [], this.localList = const []});

  AudioState copyWith({
    String? message,
    bool? isLoading,
    bool? hasMore,
    int? page,
    List<Map>? audioList,
    List<int>? pendingList,
    List<int>? localList,
  }) {
    return AudioState(
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

final audioProvider =
    NotifierProvider<AudioNotifier, AudioState>(AudioNotifier.new);

class AudioNotifier extends Notifier<AudioState> {
  @override
  AudioState build() {
    _scanLocalFiles();
    return const AudioState();
  }

  Future<void> fetchList({bool clean = false}) async {
    if (state.isLoading) return;

    final nextPage = clean ? 1 : state.page;
    state = state.copyWith(
      isLoading: true,
      audioList: clean ? [] : null,
      message: null,
    );
    final res = await ApiService().getList('zh-tw', nextPage);
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

  Future<bool> downloadFile(String url, int id) async {
    state = state.copyWith(pendingList: [...state.pendingList, id]);
    final audioDir = await _getDir();
    final result = await ApiService().downloadFile(url, '${audioDir.path}/$id');
    final newPending = [...state.pendingList]..remove(id);
    state = state.copyWith(
      pendingList: newPending,
      localList: result ? [...state.localList, id] : null,
      message: result ? null : '下載失敗，請稍後再試',
    );
    return result;
  }

  Future<String> getFilePath(int id) async {
    final audioDir = await _getDir();
    return '${audioDir.path}/$id';
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
    final ids = <int>[];
    for (final e in entities) {
      final id = int.tryParse(basename(e.path));
      if (id != null) ids.add(id);
    }
    if (ids.isNotEmpty) {
      state = state.copyWith(localList: ids);
    }
  }
}
