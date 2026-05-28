import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path/path.dart' hide context;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:taipei_travel_audio/pages/play_page.dart';
import 'package:taipei_travel_audio/services/api_service.dart';
import 'package:taipei_travel_audio/services/audio_service.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  //controller
  ScrollController scrollController = ScrollController();
  bool isLoading = false;
  int page = 1;

  //data from api
  List<Map> audioList = [];
  List<int> pendingList = [];
  List<int> localList = [];

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      if ((scrollController.position.maxScrollExtent -
              scrollController.position.pixels) ==
          0) {
        if (!isLoading) {
          page++;
          getList();
        }
      }
    });
    listDir();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        titleSpacing: 0,
        shadowColor: Colors.black,
        flexibleSpace: Container(
          color: Colors.white,
        ),
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
      body: body(),
    );
  }

  //region widget

  Widget body() {
    return RefreshIndicator(
      onRefresh: () {
        return getList(clean: true);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white
        ),
        child: audioList.isEmpty
            ? _emptyState()
            : ListView.builder(
                controller: scrollController,
                itemCount: audioList.length,
                itemBuilder: (context, index) {
                  return listItem(audioList[index]);
                },
              ),
      ),
    );
  }

  Widget _emptyState() {
    return Container();
  }

  Widget listItem(Map data) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color.fromRGBO(58, 56, 56, 1.0)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(data['title']),
              ),
            ),
            Column(
              children: [
                if (pendingList.contains(data['id']))...[
                  const Center(child: CircularProgressIndicator())
                ] else if (localList.contains(data['id'])) ...[
                  TextButton(
                    onPressed: () async {
                     gotoPlay(data['title'],data['id']);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 2,
                      ),
                    ),
                    child: Row(children: [
                      Icon(Icons.play_arrow_rounded,),
                      SizedBox(width: 4,),
                      Text('播放'),
                    ]),
                  ),
                ] else
                TextButton(
                  onPressed: () async {
                    data['process'] = 'pending';
                    bool result = await downloadFile(data['url'],data['id']);

                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 2,
                    ),
                  ),
                  child: Row(children: [
                    Icon(Icons.file_download_outlined,),
                    SizedBox(width: 4,),
                    Text('下載'),
                  ]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  //endregion

  //region goto
  Future<Directory> getDir() async {
    final docDir = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${docDir.path}/audioDir');
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    return audioDir;
  }


  Future<void> gotoPlay(String title,int id) async {
    final audioDir = await getDir();
    AudioService().setFile("${audioDir.path}/$id");
    Navigator.push(context, MaterialPageRoute(builder: (context)=>PlayPage(title: title,)));
  }

  //endregion

  //region api
  Future<bool> downloadFile(String url, int id) async {
    setState(() {
      pendingList.add(id);
    });
    final audioDir = await getDir();
    final absolutePath = '${audioDir.path}/${url.split("/").last}';
    bool result =  await ApiService().downloadFile(url, absolutePath, );
    setState(() {
      pendingList.remove(id);
      if(result){
        localList.add(id);
      }
    });
    return result;
  }

  Future<void> getList({bool? clean}) async {
    if (clean == true) {
      page = 1;
      audioList.clear();
    }
    setState(() {
      isLoading = true;
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return SpinKitRing(color: Colors.black,);
      },
    );
    Response res = await ApiService().getList('zh-tw', page);
    setState(() {
      isLoading = false;
    });
    Navigator.pop(context);
    if (res.statusCode != 200) {
      return;
    }
    List list = res.data['data'];
    for (int i = 0; i < list.length; i++) {
      audioList.add(list[i]);
    }
    setState(() {});
  }

  Future<void> listDir() async {
    var dir = await getDir();
    List<FileSystemEntity> entities = await dir.list().toList();
    localList.addAll(entities.map((e)=>int.parse(basename(e.path))).toList());
    print(localList);
  }

  //endregion
}
