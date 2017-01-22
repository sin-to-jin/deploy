<< "#__CO__"
AWSへの自動デプロイをするための簡素なスクリプト。CircleCIから呼ばれることを想定している。

対象AWSのセキュリティグループにCircleCIのGlocalIPアドレスを登録することで、デプロイを可能にする。
デプロイが完了後、対象AWSのセキュリティグループからCircleCIのGlocalIPアドレスを削除する。
#__CO__

#!/bin/sh

# 処理失敗次第落とす
set -ex

# 東京リージョン
export AWS_DEFAULT_REGION="ap-northeast-1"

# セキュリティグループ
SECURITY_GROUP="sg-staging"
GL_IP=`curl inet-ip.info`

# security groupにipを登録する
# http://docs.aws.amazon.com/cli/latest/reference/ec2/authorize-security-group-ingress.html
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP --protocol tcp --port 22 --cidr $GL_IP/32

# デプロイ (to staging環境)
bundle exec cap staging deploy --trace

# security groupからipを削除する
# http://docs.aws.amazon.com/cli/latest/reference/ec2/revoke-security-group-ingress.html
aws ec2 revoke-security-group-ingress --group-id $SECURITY_GROUP --protocol tcp --port 22 --cidr $GL_IP/32
