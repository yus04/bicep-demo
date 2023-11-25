# 事前準備
以下のインストール
- Visual Studio Code
- Bicep 拡張機能
- Azure CLI

# 手順
Azure アカウントへログイン
```
az login
```
Azure サブスクリプションの切り替え
```
az account set --subscription <your subscription id>
```
(Bicep 未インストールの場合) Bicep インストール
```
az bicep install
```
(任意) Bicep アップグレード
```
az bicep upgrade
```
リソースグループの作成
```
az group create --name <resource group name> --location japaneast
```
リソースグループへ Bicep ファイルをデプロイ

(VMの管理者パスワードは、大文字・小文字・数字を含む12文字以上の文字列に設定)
```
az deployment group create --resource-group <resource group name> --template-file main.bice
```

# 参考文献
「クイックスタート: Bicep ファイルを使用して Windows 仮想マシンを作成する」
https://learn.microsoft.com/ja-jp/azure/virtual-machines/windows/quick-create-bicep?tabs=CLI