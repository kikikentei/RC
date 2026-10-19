# DWG → DXF 一括変換（AutoCAD レギュラー版）

AutoCAD の `accoreconsole.exe`（画面なしで動く AutoCAD）を使い、フォルダ内の DWG をまとめて DXF にします。
AutoCAD LT には accoreconsole がないため使えません。

## ファイル
| ファイル | 役割 |
|---|---|
| `dwg2dxf.bat` | DWG の入ったフォルダをドラッグ＆ドロップして実行 |
| `dwg2dxf.ps1` | 本体（フォルダを回して accoreconsole を呼ぶ） |
| `dwg2dxf.scr` | AutoCAD に渡すスクリプト（DXFOUT） |

3つは同じフォルダに置いてください。

## 使い方
### かんたん
DWG の入ったフォルダを `dwg2dxf.bat` にドラッグ＆ドロップ。
→ `<そのフォルダ>\DXF` に DXF（2018形式）ができます。サブフォルダも対象で、構成はそのまま保たれます。

### オプション付き（PowerShell）
```powershell
powershell -ExecutionPolicy Bypass -File dwg2dxf.ps1 -InDir "C:\図面\DWG" -OutDir "C:\図面\DXF" -Version R12 -Recurse
```
- `-Version` : `R12` / `2000` / `2004` / `2007` / `2010` / `2013` / `2018`（既定 2018）
  - Jw_cad で開く場合、うまく読めないときは `R12` を試してください。
  - Python（ezdxf）で読むならどれでも可。
- `-OutDir` : 省略時は入力フォルダ内の `DXF`
- `-Recurse` : サブフォルダも変換

## 注意
- 元の DWG は変更しません（DXF を書き出すだけ）。
- 外部参照（XREF）は DXF に取り込まれません。必要なら先に BIND してください。
- 失敗したファイルは最後に一覧表示されます。
