#!/bin/bash
set -e

PM2_NAME=${PM2_NAME:-gemini-api}

print_step() { echo "[STEP] $1"; }
print_info() { echo "[INFO] $1"; }
print_error() { echo "[ERROR] $1"; }

if ! command -v pm2 >/dev/null 2>&1; then
  print_error "pm2 未安装或不在 PATH 中"
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  print_error "python3 未安装或不在 PATH 中"
  exit 1
fi

if ! command -v npm >/dev/null 2>&1; then
  print_error "npm 未安装或不在 PATH 中"
  exit 1
fi

echo "请选择重建类型："
echo "1) 构建前端"
echo "2) 构建后端"
echo "3) 全部构建"
read -r -p "请输入选项 [1-3]: " choice

target=${choice:-3}

build_frontend() {
  print_step "构建前端"
  cd frontend
  npm install
  npm run build
  cd - >/dev/null
}

build_backend() {
  print_step "构建后端（依赖安装）"
  if [ ! -d .venv ]; then
    python3 -m venv .venv
  fi
  # shellcheck source=/dev/null
  source .venv/bin/activate
  pip install -r requirements.txt --upgrade
}

case "$target" in
  1)
    build_frontend
    ;;
  2)
    build_backend
    ;;
  3)
    build_backend
    build_frontend
    ;;
  *)
    print_error "无效选项"
    exit 1
    ;;
esac

print_step "重启 pm2 服务: ${PM2_NAME}"
pm2 restart "${PM2_NAME}"
print_info "完成"
