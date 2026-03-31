#!/bin/bash
# postCreateCommand — ตั้งค่า git config จากไฟล์ .env.local

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

if [ -n "$GIT_CONFIG_EMAIL" ] && [ -n "$GIT_CONFIG_NAME" ]; then
  git config --global user.email "$GIT_CONFIG_EMAIL"
  git config --global user.name "$GIT_CONFIG_NAME"
  echo "✅ Git config ตั้งค่าเรียบร้อย: $GIT_CONFIG_NAME <$GIT_CONFIG_EMAIL>"
else
  echo "⚠️  GIT_CONFIG_EMAIL หรือ GIT_CONFIG_NAME ไม่ได้กรอกใน .env.local"
fi
