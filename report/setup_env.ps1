# ============================================================
# setup_env.ps1 — เตรียมเครื่องอัตโนมัติสำหรับ my-ads (Windows)
# ตรวจ + ติดตั้งของที่จำเป็นให้เอง: Python 3 · python-pptx · Edge (ทำ PDF)
# ใช้ (PowerShell):  powershell -ExecutionPolicy Bypass -File report\setup_env.ps1
# ============================================================
Write-Host "🔧 เตรียมเครื่องสำหรับ my-ads..."

# ---- 1. Python ----
$py = $null
foreach ($c in @("python", "py", "python3")) {
  if (Get-Command $c -ErrorAction SilentlyContinue) {
    try { & $c --version *> $null; if ($LASTEXITCODE -eq 0) { $py = $c; break } } catch {}
  }
}
if ($py) {
  Write-Host "✅ Python: $(& $py --version 2>&1)"
} else {
  Write-Host "⚠️ ไม่มี Python — กำลังติดตั้งผ่าน winget..."
  if (Get-Command winget -ErrorAction SilentlyContinue) {
    winget install -e --id Python.Python.3.12 --accept-source-agreements --accept-package-agreements
    Write-Host "ℹ️ ติดตั้งเสร็จแล้ว — ถ้า python ยังเรียกไม่ได้ ให้ปิด PowerShell แล้วเปิดใหม่ 1 ครั้ง"
    $py = "python"
  } else {
    Write-Host "❌ ไม่มี winget — โหลด Python ตรง: https://www.python.org/downloads/  (ติ๊ก 'Add to PATH' ตอนติดตั้ง)"
    exit 1
  }
}

# ---- 2. python-pptx (ทำ PPTX) ----
& $py -c "import pptx" *> $null
if ($LASTEXITCODE -ne 0) {
  Write-Host "📦 ติดตั้ง python-pptx..."
  & $py -m pip install --user python-pptx
  & $py -c "import pptx" *> $null
  if ($LASTEXITCODE -eq 0) { Write-Host "✅ ติดตั้ง python-pptx สำเร็จ" }
  else { Write-Host "⚠️ ติดตั้งไม่สำเร็จ — HTML/PDF ยังทำได้ · ลองใหม่: $py -m pip install python-pptx" }
} else {
  Write-Host "✅ python-pptx พร้อม"
}

# ---- 3. Chrome/Edge (ทำ PDF) — Edge มากับ Windows เสมอ ----
Write-Host "✅ Microsoft Edge (ทำ PDF ได้) มากับ Windows อยู่แล้ว"

Write-Host "🎉 เตรียมเครื่องเสร็จ — พร้อมใช้ my-ads"
