import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taipei_travel_audio/providers/audio_provider.dart';

class LocalPage extends ConsumerStatefulWidget {
  const LocalPage({super.key});

  @override
  ConsumerState<LocalPage> createState() => _LocalPageState();
}

class _LocalPageState extends ConsumerState<LocalPage> {
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.message!)));
      }
    });

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        titleSpacing: 0,
        shadowColor: Colors.black,
        flexibleSpace: Container(color: Colors.white),
        title: Row(
          children: [
            SizedBox(width: 16),
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
        ),
      ),
      body: Container(color: Colors.white, child: _buildContent(audioState)),
    );
  }

  //region widget

  Widget _buildContent(AudioState audioState) {
    if (audioState.localList.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 200),
          Center(
            child: Text(
              'No data',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ],
      );
    }
    return ListView.builder(
      controller: scrollController,
      itemCount: audioState.localList.entries.length,
      itemBuilder: (context, index) {
        return listItem(audioState, audioState.localList.entries.toList()[index]);
      },
    );
  }

  Widget listItem(AudioState audioState, MapEntry<int, String> data) {

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(data.value ?? '', style: TextStyle(fontSize: 16)),
          ),
          SizedBox(width: 8),
          TextButton(
            onPressed: () => ref.read(audioProvider.notifier).deleteFile(data.key),
            child: Icon(Icons.delete, size: 20),
          ),
        ],
      ),
    );
  }

}
