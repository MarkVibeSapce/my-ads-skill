#!/usr/bin/env bash
# ============================================================
# setup_env.sh — เตรียมเครื่องอัตโนมัติสำหรับ my-ads (Mac / Linux)
# ตรวจ + ติดตั้งของที่จำเป็นให้เอง: Python 3 · python-pptx · เช็ค Chrome/Edge
# ใช้: bash report/setup_env.sh
# ============================================================
echo "🔧 เตรียมเครื่องสำหรับ my-ads..."

# ---- 1. Python 3 ----
if command -v python3 >/dev/null 2>&1; then
  echo "✅ Python: $(python3 --version 2>&1)"
else
  echo "⚠️ ไม่มี Python 3 — กำลังติดตั้ง..."
  if command -v brew >/dev/null 2>&1; then
    brew install python
  elif command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update && sudo apt-get install -y python3 python3-pip
  else
    echo "❌ ติดตั้งอัตโนมัติไม่ได้ (ไม่มี brew/apt)"
    echo "   Mac: ติดตั้ง Homebrew ก่อน https://brew.sh  แล้วรันสคริปต์นี้ใหม่"
    echo "   หรือโหลด Python ตรง: https://www.python.org/downloads/"
    exit 1
  fi
fi

# ---- 2. pip ----
python3 -m pip --version >/dev/null 2>&1 || python3 -m ensurepip --upgrade >/dev/null 2>&1

# ---- 3. python-pptx (ทำ PPTX) ----
if python3 -c "import pptx" >/dev/null 2>&1; then
  echo "✅ python-pptx พร้อม"
else
  echo "📦 ติดตั้ง python-pptx..."
  python3 -m pip install --user python-pptx >/dev/null 2>&1 \
    || python3 -m pip install --user --break-system-packages python-pptx >/dev/null 2>&1 \
    || python3 -m pip install --break-system-packages python-pptx
  if python3 -c "import pptx" >/dev/null 2>&1; then
    echo "✅ ติดตั้ง python-pptx สำเร็จ"
  else
    echo "⚠️ ติดตั้ง python-pptx ไม่สำเร็จ — HTML/PDF ยังทำได้ · ลองใหม่: python3 -m pip install python-pptx"
  fi
fi

# ---- 4. Chrome/Edge (ทำ PDF — แค่เช็ค ไม่ auto-install browser) ----
if [ -d "/Applications/Google Chrome.app" ] || [ -d "/Applications/Microsoft Edge.app" ] \
   || command -v google-chrome >/dev/null 2>&1 || command -v chromium >/dev/null 2>&1 \
   || command -v chromium-browser >/dev/null 2>&1; then
  echo "✅ เบราว์เซอร์สำหรับทำ PDF พร้อม"
else
  echo "⚠️ ไม่เจอ Chrome/Edge — ทำ PDF โดยเปิดไฟล์ HTML แล้วกด Cmd+P → บันทึกเป็น PDF ได้"
  echo "   (หรือติดตั้ง Chrome: https://www.google.com/chrome/)"
fi

echo "🎉 เตรียมเครื่องเสร็จ — พร้อมใช้ my-ads"
