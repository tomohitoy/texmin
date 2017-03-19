## Text Mining Tool

### はじめに
本ツールは、Python2(Anaconda)とMongoDB, PostgreSQL9.5.3を利用して、テキストマイニング、ウェブテキストの探索を行うためのツールです。
docker-composeを使い、Ubuntuサーバを立ち上げ、そのなかでPython3で作業を行うことができます。
データベースと接続し、データを保存したりすることができます。

### 使い方
```
$ cd ~
$ git clone https://github.com/tomohitoy/texmin.git
$ mkdir ~/.ssh
$ cd .ssh
$ ssh-keygen -t rsa -b 4096 -C "t07840ty@gmail.com"
$ cp id_rsa.pub ~/texmin/
$ cd ~/texmin
$ docker-compose build
$ docker-compose pull
$ docker-compose up -d
$ ssh tomohitoy@0.0.0.0 -p 2222 -i ~/.ssh/id_rsa
```

