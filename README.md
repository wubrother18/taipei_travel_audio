# FUNDAY 台北語音導覽

串接臺北旅遊網 Open API 的語音導覽 App，可以瀏覽音檔列表、下載音檔到手機、離線播放。

## 環境

- Flutter 3.12+

## 啟動

```bash
flutter pub get
flutter run
```

## 使用套件

- `flutter_riverpod` - 狀態管理
- `dio` - HTTP 請求與檔案下載
- `just_audio` + `rxdart` - 音訊播放
- `path_provider` - 本地儲存路徑

## 設計說明

- 列表頁用 ScrollController 偵測捲動到底部，自動載入下一頁
- 下載的音檔存在 App 的 documents 目錄，啟動時掃描資料夾還原已下載狀態
- 用 Riverpod 的 Notifier 集中管理列表狀態（載入、下載中、已下載），UI 透過 ref.watch 響應更新
- 播放頁用 just_audio 播放本地檔案，rxdart 合併播放位置與總時長的 stream
