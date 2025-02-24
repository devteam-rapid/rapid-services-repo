#!/bin/bash
# 기본 변수 설정
APP_NAME=$1
ENVIRONMENT=$2
REPO_ROOT=$(git rev-parse --show-toplevel)
APP_DIR="$REPO_ROOT/apps/$APP_NAME/$ENVIRONMENT"
HELM_DIR="$REPO_ROOT/templates/helm"

# 인자 확인
if [ -z "$APP_NAME" ] || [ -z "$ENVIRONMENT" ]; then
  echo "사용법: $0 <앱-이름> <환경>"
  exit 1
fi

# 앱 디렉토리 존재 여부 확인
if [ ! -d "$APP_DIR" ]; then
  echo "에러: 애플리케이션 디렉토리를 찾을 수 없습니다: $APP_DIR"
  exit 1
fi

# template.json 파일 존재 여부 확인
if [ ! -f "$APP_DIR/template.json" ]; then
  echo "에러: $APP_DIR 에서 template.json을 찾을 수 없습니다"
  exit 1
fi

# Helm 디렉토리 존재 여부 확인
if [ ! -d "$HELM_DIR" ]; then
  echo "에러: Helm 템플릿 디렉토리를 찾을 수 없습니다: $HELM_DIR"
  exit 1
fi

# template.json에서 필요한 값들 추출
PORT=$(jq -r '.port' "$APP_DIR/template.json")
HOSTNAME=$(jq -r '.host' "$APP_DIR/template.json")

# 필수 값 확인
if [ -z "$PORT" ] || [ "$PORT" == "null" ]; then
  echo "에러: template.json에서 port를 찾을 수 없습니다"
  exit 1
fi

if [ -z "$HOSTNAME" ] || [ "$HOSTNAME" == "null" ]; then
  echo "에러: template.json에서 hostname을 찾을 수 없습니다"
  exit 1
fi

# Helm 매니페스트 생성
echo "Helm 매니페스트 생성 중..."
helm template "$APP_NAME-$ENVIRONMENT" "$HELM_DIR" \
  --set appName="$APP_NAME-$ENVIRONMENT" \
  --set imageTag=latest \
  --set port="$PORT" \
  --set hostname="$HOSTNAME" \
  --set namespace="$APP_NAME" \
  > "$APP_DIR/manifest.yaml"

if [ $? -eq 0 ]; then
  echo "$APP_NAME 의 $ENVIRONMENT 환경용 매니페스트 생성이 완료되었습니다"
  echo "생성된 파일: $APP_DIR/manifest.yaml"
else
  echo "에러: 매니페스트 생성 중 오류가 발생했습니다"
  exit 1
fi