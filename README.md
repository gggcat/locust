# LOCUST

## What is LOCUST

[LOCUST](https://locust.io/) is an open source load testing tool.

[locustio/locust](https://github.com/locustio/locust)

## scripts

- locust.config.json …どのサーバに対してどのタスクセットを実行するか
- locustfile.py …テストスクリプト

## run

### ex1) masterを起動し、salve数2に設定

``` bash
docker-compose up -d
docker-compose scale slave=2
```

### ex2) スレーブ数3で起動

``` bash
docker-compose up --scale slave=3 -d
```

### 管理画面へのアクセス

[ローカルホストのport8089へアクセス](http://localhost:8089)
