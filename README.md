# FUNDAY 台北語音導覽

串接[臺北旅遊網 Open API](https://www.travel.taipei/open-api/swagger/ui/index)，提供語音導覽音檔的列表瀏覽、下載與本地播放。

## Demo

<img src="Screen_recording_20260528_154031.gif" width="300" />

## 環境

- Flutter 3.12+

## 啟動

```bash
flutter pub get
flutter run
```

## 功能

- 音檔列表：分頁載入、下拉刷新
- 下載/播放切換：未下載顯示下載按鈕，已下載顯示播放按鈕
- 音檔播放：波形動畫、進度條拖曳、播放/暫停、時間顯示
- 多語系切換：繁中、简中、EN、JA、KO
- 本地檔案管理：查看已下載音檔、刪除

## 使用套件

| 套件 | 用途 |
|------|------|
| `flutter_riverpod` | 狀態管理（Notifier + immutable State） |
| `dio` | HTTP 請求與檔案下載 |
| `just_audio` + `rxdart` | 音訊播放、合併多個播放狀態 stream |
| `path_provider` | 本地儲存路徑 |

## 架構

透過 Riverpod 將業務邏輯與 UI 分離。

- **Model** — `AudioState`：集中管理列表、下載、分頁等狀態
- **ViewModel** — `AudioNotifier`：處理 API 呼叫、檔案下載/刪除、本地掃描
- **View** — `ListPage` / `PlayPage` / `LocalPage`：透過 `ref.watch` 監聽狀態自動更新 UI

## 設計說明

- 列表用 ScrollController 偵測捲動位置，自動載入下一頁
- 下載檔案以 `{id}_{title}` 命名，啟動時掃描資料夾還原已下載狀態與標題
- 語系切換時清空列表從第 1 頁重新載入
- API/下載錯誤透過 `ref.listen` 監聽 `message` 變化，以 SnackBar 通知
