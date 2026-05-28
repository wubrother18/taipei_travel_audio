import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taipei_travel_audio/pages/play_page.dart';
import 'package:taipei_travel_audio/providers/audio_provider.dart';
import 'package:taipei_travel_audio/services/audio_service.dart';

class ListPage extends ConsumerStatefulWidget {
  const ListPage({super.key});

  @override
  ConsumerState<ListPage> createState() => _ListPageState();
}

class _ListPageState extends ConsumerState<ListPage> {
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 100) {
        final s = ref.read(audioProvider);
        if (!s.isLoading && s.hasMore) {
          ref.read(audioProvider.notifier).fetchList();
        }
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(audioProvider.notifier).fetchList();
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audioState = ref.watch(audioProvider);

    ref.listen<AudioState>(audioProvider, (prev, next) {
      if (next.message != null && next.message != prev?.message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message!)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        titleSpacing: 0,
        shadowColor: Colors.black,
        flexibleSpace: Container(color: Colors.white,),
        title: Row(
          children: [
            SizedBox(width: 16,),
            Text(
              "FUNDAY",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.0,
                fontWeight: FontWeight.w700,
                fontFamily: 'Lato',
                fontFamilyFallback: <String>['Noto Sans TC'],
              ),
            ),
          ],
        )
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(audioProvider.notifier).fetchList(clean: true),
        child: Container(
          color: Colors.white,
          child: _buildContent(audioState),
        ),
      ),
    );
  }

  //region widget

  Widget _buildContent(AudioState audioState) {
    if (audioState.audioList.isEmpty && audioState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (audioState.audioList.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 200),
          Center(child: Text('No data', style: TextStyle(fontSize: 16, color: Colors.grey),)),
        ],
      );
    }
    return ListView.builder(
      controller: scrollController,
      itemCount: audioState.audioList.length + (audioState.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == audioState.audioList.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return listItem(audioState, audioState.audioList[index]);
      },
    );
  }

  Widget listItem(AudioState audioState, Map data) {
    final int id = data['id'];
    final bool isPending = audioState.pendingList.contains(id);
    final bool isLocal = audioState.localList.contains(id);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(data['title'] ?? '', style: TextStyle(fontSize: 15),),
          ),
          SizedBox(width: 8,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isPending) ...[
                SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2,),)
              ] else if (isLocal) ...[
                TextButton(
                  onPressed: () => gotoPlay(data['title'] ?? '', id),
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4,),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.play_arrow_rounded, size: 20,),
                    SizedBox(width: 4,),
                    Text('播放'),
                  ]),
                ),
              ] else
                TextButton(
                  onPressed: () => ref.read(audioProvider.notifier).downloadFile(data['url'], id),
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4,),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.file_download_outlined, size: 20,),
                    SizedBox(width: 4,),
                    Text('下載'),
                  ]),
                ),
              SizedBox(height: 4,),
              if (data['modified'] != null)
                Text(
                  _formatDate(data['modified']),
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
            ],
          ),
        ],
      ),
    );
  }

  //endregion

  //region goto

  Future<void> gotoPlay(String title, int id) async {
    final filePath = await ref.read(audioProvider.notifier).getFilePath(id);
    AudioService().setFile(filePath);
    if (!mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (context) => PlayPage(title: title, id: "$id",)));
  }

  //endregion

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return '${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }
}
