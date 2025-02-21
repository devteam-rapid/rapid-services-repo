#!/bin/bash

# 기본 변수 설정
APP_NAME=$1
ENVIRONMENT=$2
REPO_ROOT=$(git rev-parse --show-toplevel)
APP_DIR="$REPO_ROOT/apps/$APP_NAME/$ENVIRONMENT"
TEMPLATE_DIR="$REPO_ROOT/templates/dockerfile"

# 앱 디렉토리 존재 여부 확인
if [ ! -d "$APP_DIR" ]; then
  echo "Error: Application directory not found: $APP_DIR"
  exit 1
fi

# template.json 파일 존재 여부 확인
if [ ! -f "$APP_DIR/template.json" ]; then
  echo "Error: template.json not found in $APP_DIR"
  exit 1
fi

# template.json에서 템플릿 타입 추출
TEMPLATE_TYPE=$(jq -r '.type' "$APP_DIR/template.json")
TEMPLATE_FILE="$TEMPLATE_DIR/${TEMPLATE_TYPE}.dockerfile.template"

# Dockerfile 템플릿 파일 존재 여부 확인
if [ ! -f "$TEMPLATE_FILE" ]; then
  echo "Error: Template file not found: $TEMPLATE_FILE"
  exit 1
fi

# 환경변수 설정을 위한 임시 파일 생성
echo "Processing template.json..."
while IFS= read -r line; do
 export "$line"
done < <(jq -r 'to_entries | .[] | select(.key != "type") | "\(.key)=\(.value)"' "$APP_DIR/template.json")

# 템플릿의 변수들을 실제 값으로 치환하여 Dockerfile 생성
echo "Generating Dockerfile..."
envsubst < "$TEMPLATE_FILE" > "$APP_DIR/Dockerfile"

echo "Successfully generated Dockerfile for $APP_NAME in $ENVIRONMENT environment"