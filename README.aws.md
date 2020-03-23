# locust on AWS

## コンテナイメージのビルド

`docker build -t locust .`でlocustのDockerイメージを作成

``` bash
$ docker build -t locust .
Sending build context to Docker daemon   50.5MB
Step 1/5 : FROM locustio/locust
 ---> 2f0163e62e90
Step 2/5 : COPY ./scripts/ /scripts/
 ---> 12a60135afc2
Step 3/5 : EXPOSE 8089
 ---> Running in 6b2fd3abd0ef
Removing intermediate container 6b2fd3abd0ef
 ---> 16da3b412c93
 ---> e0716e4da44e
Step 5/5 : EXPOSE 5558
 ---> Running in bd95b679cd1b
Removing intermediate container bd95b679cd1b
 ---> 12c8bb3f8599
Successfully built 12c8bb3f8599
Successfully tagged locust:latest
SECURITY WARNING: You are building a Docker image from Windows against a non-Windows Docker host. All files and directories added to build context will have '-rwxr-xr-x' permissions. It is recommended to double check and reset permissions for sensitive files and directories.

$ docker images
REPOSITORY                TAG                 IMAGE ID            CREATED             SIZE
locust                    latest              12c8bb3f8599        20 seconds ago      155MB
```

## AWS ECRの準備

`aws ecr create-repository --region ap-northeast-1 --repository-name locust`でECRにリポジトリlocustを作成

``` bash
$ aws ecr create-repository --region ap-northeast-1 --repository-name locust
{
    "repository": {
        "repositoryArn": "arn:aws:ecr:ap-northeast-1:xxxxxxxxxxxx:repository/locust",
        "registryId": "xxxxxxxxxxxx",
        "repositoryName": "locust",
        "repositoryUri": "xxxxxxxxxxxx.dkr.ecr.ap-northeast-1.amazonaws.com/locust",
        "createdAt": 9999999999.0
    }
}
```

## AWS ECRへのログイン

`aws ecr get-login --no-include-email --region ap-northeast-1`を実行し、ECRへのログインするdockerコマンドを取得・ログインする。

``` bash
$ aws ecr get-login --no-include-email --region ap-northeast-1
 .....略.....
$ docker login -u AWS -p eyJwYXlsb2FkIjoi　中略　0VZIiwiZZSJhdGlvbiI6ZZT4MDc1OTQwOH0= https://xxxxxxxxxxxxxx.dkr.ecr.ap-northeast-1.amazonaws.com
WARNING! Using --password via the CLI is insecure. Use --password-stdin.
Login Succeeded
```

## タグ付けとプッシュ

`docker tag locust:latest xxxxxxxxxxxxxx.dkr.ecr.ap-northeast-1.amazonaws.com/locust:latest`でタグをイメージに付与し、
`docker push xxxxxxxxxxxxxx.dkr.ecr.ap-northeast-1.amazonaws.com/locust:latest`でECRにpushする。

``` bash
$ docker tag locust:latest xxxxxxxxxxxxxx.dkr.ecr.ap-northeast-1.amazonaws.com/locust:latest
$ docker push xxxxxxxxxxxxxx.dkr.ecr.ap-northeast-1.amazonaws.com/locust:latest
The push refers to repository [xxxxxxxxxxxxxx.dkr.ecr.ap-northeast-1.amazonaws.com/locust]
ee557db2d617: Pushed
e04871e73d14: Pushed
2cea04c09211: Pushed
7cf714406e1d: Pushed
ac32dd0e7e17: Pushed
2cf615a1451a: Pushed
1753f93c1116: Pushed
4a533fc8bd1b: Pushed
f0c962283e11: Pushed
dcd185b84316: Pushed
77cae8ab231f: Pushed
latest: digest: sha256:4d8e765b129bfb62218f7e54fbdb6a26b4ee420566c5ed4b15a7684ca2dd30ba size: 2618
```

## 登録したイメージの確認

`aws ecr describe-images --repository-name locust`で登録されたイメージの情報を確認

``` bash
$ aws ecr describe-images --repository-name locust
{
    "imageDetails": [
        {
            "registryId": "xxxxxxxxxxxxxx",
            "repositoryName": "locust",
            "imageDigest": "sha256:4d8e765b5d9bfb62218f7e5412db6a26b4ee420566c5ed4b15a7684ca2dd30ba",
            "imageTags": [
                "latest"
            ],
            "imageSizeInBytes": 47998069,
            "imagePushedAt": 1581496293.0
        }
    ]
}
```

## [terraform](https://www.terraform.io/downloads.html)を使ったデプロイ

`variables.tf`でaws-cliのデフォルトのcredentialの使用とlocustコンテナの場所を設定

```json
provider "aws" {
  profile = "default"
  region  = "ap-northeast-1"
}

…略…

variable "locust_container" {
  default = "xxxxxxxxxxxxxx.dkr.ecr.ap-northeast-1.amazonaws.com/locust:latest"
}
```

## 実行

`terraform init`&`terraform apply`でデプロイ。
endpointとしてURLが表示されるのでそこにアクセス。

``` bash
$ ./terraform init

Initializing the backend...

Initializing provider plugins...

The following providers do not have any version constraints in configuration,
so the latest version was installed.

To prevent automatic upgrades to new major versions that may contain breaking
changes, it is recommended to add version = "..." constraints to the
corresponding provider blocks in configuration, with the constraint strings
suggested below.

* provider.aws: version = "~> 2.47"

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

```bash
$ ./terraform apply
data.aws_iam_role.ecs_task_execution_role: Refreshing state...

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

　…略…

Plan: 20 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

　…略…

Apply complete! Resources: 20 added, 0 changed, 0 destroyed.

Outputs:

endpoint = access to here (wait a minute): http://locust-xxxxxxxxxxxxxxxxxxx.ap-northeast-1.elb.amazonaws.com
```

## 削除

```bash
$ ./terraform destroy

　…略…

Plan: 0 to add, 0 to change, 20 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

　…略…

Destroy complete! Resources: 20 destroyed.
```
