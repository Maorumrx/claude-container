#!/bin/bash
# postCreateCommand — ตั้งค่า git config, proxy, และติดตั้ง Claude Code CLI

ENV_FILE="/workspace/.env.local"

if [ ! -f "$ENV_FILE" ]; then
  echo ""
  echo "⚠️  ไม่พบไฟล์ .env.local"
  echo "   กรุณา copy .env.example → .env.local แล้วกรอกข้อมูล"
  echo "   จากนั้นรัน: bash .devcontainer/scripts/setup.sh"
  echo ""
  exit 0
fi

# อ่านค่าจากไฟล์ (ข้ามบรรทัดที่เป็น comment หรือว่างเปล่า)
export $(grep -v '^\s*#' "$ENV_FILE" | grep -v '^\s*$' | xargs)

# ─── Git config ────────────────────────────────────────────────────────────────
if [ -n "$GIT_CONFIG_EMAIL" ] && [ -n "$GIT_CONFIG_NAME" ]; then
  git config --global user.email "$GIT_CONFIG_EMAIL"
  git config --global user.name "$GIT_CONFIG_NAME"
  echo "✅ Git config: $GIT_CONFIG_NAME <$GIT_CONFIG_EMAIL>"
else
  echo "⚠️  GIT_CONFIG_EMAIL หรือ GIT_CONFIG_NAME ไม่ได้กรอกใน .env.local"
fi

# ─── npm proxy + SSL ───────────────────────────────────────────────────────────
# อ่านจาก environment ที่ devcontainer.json ส่งมาจาก localEnv (ไม่ใช้จาก .env.local)
# ล้าง config เก่าก่อนทุกครั้งเพื่อป้องกัน stale value
npm config delete proxy 2>/dev/null || true
npm config delete https-proxy 2>/dev/null || true
npm config delete noproxy 2>/dev/null || true
npm config set strict-ssl false  # รองรับ corporate proxy ที่ทำ SSL inspection

if [ -n "$HTTP_PROXY" ]; then
  npm config set proxy "$HTTP_PROXY"
  npm config set https-proxy "${HTTPS_PROXY:-$HTTP_PROXY}"
  [ -n "$NO_PROXY" ] && npm config set noproxy "$NO_PROXY"
  echo "✅ npm proxy: $HTTP_PROXY"
else
  echo "ℹ️  ไม่ใช้ proxy"
fi

# ─── Claude Code CLI ───────────────────────────────────────────────────────────
if ! command -v claude &>/dev/null; then
  echo "📦 กำลังติดตั้ง Claude Code CLI..."
  npm install -g --no-fund --no-audit @anthropic-ai/claude-code \
    && echo "✅ Claude Code CLI ติดตั้งเรียบร้อย" \
    || echo "❌ ติดตั้ง Claude Code CLI ไม่สำเร็จ ลองรัน: npm install -g @anthropic-ai/claude-code"
else
  echo "✅ Claude Code CLI พร้อมใช้งาน"
fi

if ! command -v ccusage &>/dev/null; then
  echo "📦 กำลังติดตั้ง ccusage..."
  npm install -g --no-fund --no-audit ccusage@latest \
    && echo "✅ ccusage ติดตั้งเรียบร้อย" \
    || echo "⚠️  ccusage ติดตั้งไม่สำเร็จ (ไม่บังคับ)"
fi
