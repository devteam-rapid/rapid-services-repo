#!/bin/bash

# 기본 변수 설정
APP_NAME=$1
ENVIRONMENT=$2
REPO_ROOT=$(git rev-parse --show-toplevel)
APP_DIR="$REPO_ROOT/apps/$APP_NAME/$ENVIRONMENT"
TEMPLATE_DIR="$REPO_ROOT/templates/dockerfile"

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

# template.json에서 템플릿 타입 추출
TEMPLATE_TYPE=$(jq -r '.type' "$APP_DIR/template.json")
TEMPLATE_FILE="$TEMPLATE_DIR/${TEMPLATE_TYPE}.dockerfile.template"

# Dockerfile 템플릿 파일 존재 여부 확인
if [ ! -f "$TEMPLATE_FILE" ]; then
  echo "에러: 템플릿 파일을 찾을 수 없습니다: $TEMPLATE_FILE"
  exit 1
fi

# 환경변수 설정을 위한 임시 파일 생성
echo "template.json 처리 중..."
while IFS= read -r line; do
 export "$line"
done < <(jq -r 'to_entries | .[] | select(.key != "type") | "\(.key)=\(.value)"' "$APP_DIR/template.json")

# 템플릿의 변수들을 실제 값으로 치환하여 Dockerfile 생성
echo "도커 파일 생성 중..."
envsubst < "$TEMPLATE_FILE" > "$APP_DIR/Dockerfile"

echo "$APP_NAME의 $ENVIRONMENT 환경용 Dockerfile 생성이 완료되었습니다"