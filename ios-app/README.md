ctbc-facecheck 臉部辨識
========================================================================

### 環境及注意事項:
- iOS 14
- XCode 11.3.1


### 編譯設定:
- 請調整 `/config.plist` 中的設定值為符合環境之設定 (詳見下方表格說明)
- SDK相關 (請放置於 `ctbc-hrface` 資料夾下)
    - `FaceCore.framework` 客戶提供之SDK
    - `AWSDK.framework` 客戶提供之AirWatch SDK
    - `AWCMWrapper.framework` 客戶提供之AirWatch SDK
- 其餘相關設定由辨識服務提供 ( 來源為 Aigo 的 Model Config )


### 設定檔說明:
- 公用設定儲存於config.plist中 
- 請注意 URL 需帶結尾 `/` 符號, 例 `http://domain/`

| key                                   | value         | desc                                          |
| ------------------------------------- | ------------- | --------------------------------------------- |
| SDK_License_Endpoint                  | {URL}         | (請參閱Facecore SDK文件)                      |
| SDK_License_Key                       | {URL}         | (請參閱Facecore SDK文件)                      |
| SDK_Token_Endpoint                    | {URL}         | (請參閱Facecore SDK文件)                      |
| SDK_Token_UserName                    | {URL}         | (請參閱Facecore SDK文件)                      |
| SDK_Token_Password                    | {URL}         | (請參閱Facecore SDK文件)                      |
| SDK_Log_Url                           | {URL}         | (請參閱Facecore SDK文件)                      |
| SDK_Service_Endpoint                  | {URL}         | Hrface Service URL                            |


### AirWatch說明:
- 必需在 Info.plist 裡設定AirWatch相關的設定值
- App會自動讀取 Info.plist 位於 `URL Types` -> `URL Schemes` 的第0位做為callbackScheme


### Aigo: 設定檔對應
-設定檔由Hrface Service經由 `/dbms/model/configs/all` 取得


以下為機IP對應, 請對照機器的固定IP設置, 影響到api呼叫識別機器的來源及批次作業  
鍵格式為 `IP:{ 群組序號 }:{ 名稱 }`

| key                        | value                    | desc                                              |
| -------------------------- | ------------------------ | ------------------------------------------------- |
| IP:1:A棟1樓－東            | 192.168.0.1              | 位置IP (群組1: 南港)                              |
| IP:1:A棟1樓－北            | 192.168.0.2              | 位置IP (群組1: 南港)                              |
| IP:1:A棟3樓－左            | 192.168.0.3              | 位置IP (群組1: 南港)                              |
| IP:1:A棟3樓－右            | 192.168.0.4              | 位置IP (群組1: 南港)                              |
| IP:1:A棟4樓                | 192.168.0.5              | 位置IP (群組1: 南港)                              |
| IP:1:B棟1樓                | 192.168.0.6              | 位置IP (群組1: 南港)                              |
| IP:2:行政1樓               | 192.168.0.7              | 位置IP (群組2: 行政大樓)                          |


#### 動態設定檔說明

以下為iOS動態設定檔, 詳細設定說明請見FaceCore.framework文檔  
- 如果未填寫指定裝置IP之設定，將套用無IP的公用設定
- 有需要特別設定的, 再填寫IP的專用設定
- 指定裝置ip請填寫與上方相同之ip使其對應 ( 例 `iOS.SDK:192.168.0.1:HoldSecond` )
- 若LivingDetect設定為true, 將使用活體判斷流程, 否則使用非活體流程

#### 獨立設定

| key                                 | value                   | desc                                          |
| ----------------------------------- | ----------------------- | --------------------------------------------- |
| iOS:EncodeKey                       | {base64字串}            | 錄製特徵值通訊用的加密Key(原始長度為16或32)   |
| iOS:FeatureAdminStaffIds            | 00060355,00091999       | IPad管理員員編, 多組員編以逗號分隔            |
| iOS:FeatureAdminValidCode           | {字串}                  | IPad管理員驗證碼                              |
| iOS:TempOffLivingDetectTimes        | 08:00-09:00,11:45-12:30 | 在指定時段內, 不使用活體偵測                  |

#### 公用設定

| key                                       | value             | desc                                          |
| ----------------------------------------- | ----------------- | --------------------------------------------- |
| iOS:AllowLocalLog                         | true              | 是否開啟Ipad落地log檔                         |
| iOS:AllowServerLog                        | true              | 是否開啟Log發送至Server                       |
| iOS:ServerLogFullMode                     | true              | 是否回傳完整Log訊息至Server, false為簡單版    |
| iOS:MaintainMessage                       | {字串訊息}        | 維護訊息, 預設空值, 若有值將顯示維護畫面      |
| iOS:DisableButtons                        | false             | 關閉按鈕功能                                  |
| iOS:FeatureAdminEnable                    | false             | 是否啟用Ipad設定功能                          |
| iOS:DepthCheck:Enable                     | true              | 是否啟用深度攝影機檢查功能                    |
| iOS:DepthCheck:CheckSecs                  | 15                | 兩張深度圖採樣間隔時間                        |

| key                                       | value             | desc                                          |
| ----------------------------------------- | ----------------- | --------------------------------------------- |
| iOS.SDK:HoldSecond                        | 30                | 請參閱FaceCore SDK文件                        |
| iOS.SDK:MatchCount                        | 20                | 請參閱FaceCore SDK文件                        |
| iOS.SDK:NameCount                         | 0                 | 請參閱FaceCore SDK文件                        |
| iOS.SDK:LivingDetect                      | false             | 請參閱FaceCore SDK文件 (bool)                 |
| iOS.SDK:LivingThreshold                   | 0.92              | 請參閱FaceCore SDK文件 (float)                |
| iOS.SDK:LivingCount                       | 10                | 請參閱FaceCore SDK文件                        |
| iOS.SDK:SmileDetect                       | true              | 請參閱FaceCore SDK文件 (bool)                 |
| iOS.SDK:CheckSmile                        | true              | 請參閱FaceCore SDK文件 (bool)                 |
| iOS.SDK:TrackingMatch.is_tracking         | true              | 請參閱FaceCore SDK文件 (bool)                 |
| iOS.SDK:TrackingMatch.threshold           | 1.5               | 請參閱FaceCore SDK文件 (float)                |
| iOS.SDK:HappyCount                        | 2                 | 請參閱FaceCore SDK文件                        |
| iOS.SDK:HappyThreshold                    | 0.9               | 請參閱FaceCore SDK文件 (float)                |
| iOS.SDK:DetectWithService.min_size        | 50                | 請參閱FaceCore SDK文件                        |
| iOS.SDK:RequestTimeout                    | 8.0               | 請參閱FaceCore SDK文件 (float)                |
| iOS.SDK:TempCount                         | 0                 | 請參閱FaceCore SDK文件                        |

#### 對應指定裝置

| key                                       | value             | desc                                          |
| ----------------------------------------- | ----------------- | --------------------------------------------- |
| iOS:{ ip }:AllowLocalLog                  | true              | 是否開啟Ipad落地log檔                         |
| iOS:{ ip }:MaintainMessage                | {字串訊息}        | 維護訊息, 預設空值, 若有值將顯示維護畫面      |
| iOS:{ ip }:DisableButtons                 | false             | 關閉按鈕功能                                  |
| iOS:{ ip }:FeatureAdminEnable             | false             | 是否在該裝置啟用Ipad設定功能                  |
| iOS:{ ip }:DepthCheck:Enable              | true              | 是否啟用深度攝影機檢查功能                    |
| iOS:{ ip }:DepthCheck:CheckSecs           | 15                | 兩張深度圖採樣間隔時間                        |

| key                                       | value             | desc                                          |
| ----------------------------------------- | ----------------- | --------------------------------------------- |
| iOS.SDK:{ ip }:HoldSecond                 | 30                | 請參閱FaceCore SDK文件                        |
| iOS.SDK:{ ip }:MatchCount                 | 20                | 請參閱FaceCore SDK文件                        |
| iOS.SDK:{ ip }:NameCount                  | 0                 | 請參閱FaceCore SDK文件                        |
| iOS.SDK:{ ip }:LivingDetect               | false             | 請參閱FaceCore SDK文件 (bool)                 |
| iOS.SDK:{ ip }:LivingThreshold            | 0.92              | 請參閱FaceCore SDK文件 (float)                |
| iOS.SDK:{ ip }:LivingCount                | 10                | 請參閱FaceCore SDK文件                        |
| iOS.SDK:{ ip }:SmileDetect                | true              | 請參閱FaceCore SDK文件 (bool)                 |
| iOS.SDK:{ ip }:CheckSmile                 | true              | 請參閱FaceCore SDK文件 (bool)                 |
| iOS.SDK:{ ip }:TrackingMatch.is_tracking  | true              | 請參閱FaceCore SDK文件 (bool)                 |
| iOS.SDK:{ ip }:TrackingMatch.threshold    | 1.5               | 請參閱FaceCore SDK文件 (float)                |
| iOS.SDK:{ ip }:HappyCount                 | 2                 | 請參閱FaceCore SDK文件                        |
| iOS.SDK:{ ip }:HappyThreshold             | 0.9               | 請參閱FaceCore SDK文件 (float)                |
| iOS.SDK:{ ip }:DetectWithService.min_size | 50                | 請參閱FaceCore SDK文件                        |
| iOS.SDK:{ ip }:RequestTimeout             | 8.0               | 請參閱FaceCore SDK文件 (float)                |
| iOS.SDK:{ ip }:TempCount                  | 0                 | 請參閱FaceCore SDK文件                        |

