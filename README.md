# Setup k8s kind

[kind](https://kind.sigs.k8s.io/)を起動するためのMakefileです。

## 使い方

### セットアップ

```console
$ make setup
```

関連するコマンドをWebからダウンロードして、ローカル(`/usr/local/bin`)にインストールします。
すでにファイルがある場合は上書きされます。



インストールされるコマンドは以下のとおり。

| コマンド   | バージョン |
| --------- | ------- |
| argocd    | v1.3.6  |
| kind      | v0.6.1  |
| kubectl   | v1.16.3 |
| kustomize | v3.1.0  |

### kindの起動
```console
$ make start
```

kind が起動されます。control-plane 1台、worker 1台の2台構成のクラスタです。

起動後にコンソールに以下のような文字列が表示されます。これをshell上で実行すると、kubectlが実行できるようになります。

```
*******************************************

export KUBECONFIG=output/kind_config

*******************************************
```

### kindの停止

```console
$ make stop
```

### Argo CD のデプロイ

```console
$ make run-argocd
```

### Argo CD のログイン

```console
$ make login-argocd
```

起動したArgo CDにログインします。成功するとローカルかあargocdコマンドが実行できるようになります。

`kubectl get pods -n argocd`で、Argo CDのPodが起動してから実行してください。

### 一時ファイルの削除

```console
$ make clean
```
