# HANDOFF — my-ads Student Skill

> อัปเดต: 8 ก.ค. 2026 · Skill ผู้ช่วยยิงแอด Facebook สำหรับนักเรียน in-house (คอร์ส Facebook Ads × AI, พี่โอ/โอบิลิส)

## Goal
ทำ student skill `my-ads` ให้นักเรียน **ไม่มีพื้นฐาน** ใช้ได้จริง — ยิงแอด Facebook ผ่าน Claude Code CLI + Meta Marketing API แบรนด์เดียว (ธุรกิจแชท/Messages). KPI หลัก = CPR (Cost per Result = ค่าต่อ 1 แชท).

## Repo / Path
- **Local:** `~/Desktop/AI Easy Pro/คอร์ส Facebook Ads × AI/student-skill/my-ads/`
- **Repo:** `MarkVibeSapce/my-ads-skill` (private) — ⚠️ push ต้อง `gh` account **MarkVibeSapce** เท่านั้น (default อื่นได้ 403)
- **สถานะ:** commit ล่าสุด `56a158d` push ขึ้น main แล้ว (8 ก.ค. 2026) · working tree clean

## Current Progress (เสร็จ + push แล้ว)
รอบงาน 5 อย่างในเซสชันนี้:
1. **Thai mojibake fix** — Claude เขียน copy ไทยแล้วเพี้ยนเป็นต่างดาว. แก้ 3 ชั้น: เขียน copy ลงไฟล์ UTF-8 → อ่าน `encoding="utf-8"` → **readback verify** (อ่าน message กลับจาก API ก่อนเปลี่ยน ACTIVE). ที่ `1-setup.md` Step 6.5 + `EMERGENCY.md` Scenario 5 + `SKILL.md` safety rule.
2. **กรองแชทผี** — `GHOST_FILTER.md` (ย่อจาก `~/Desktop/Ads Optimize/_templates/GHOST_CHAT_STANDARD.md`). สกิลถาม "เปิดโหมดกรองแชทผีมั้ย?" ก่อนสร้างแคมเปญแชท. จำ choice ใน BRAND_PROFILE ข้อ 3.
3. **เมนูนำทาง** — นักเรียนไม่รู้จะสั่งอะไร. `SKILL.md` เพิ่ม behavior: เปิดสกิลโชว์เมนู 9 ข้อ (พิมพ์เลข) + จบงานทุก module ถาม "ต่อไปทำอะไร" เป็นข้อๆ. บล็อก "➡️ ต่อไปทำอะไร" ท้าย module 1-6 + GHOST_FILTER.
4. **รายงาน weekly/monthly** — `report/gen_report.py` ออก **HTML + PDF + PPTX** ดีไซน์มาตรฐานเอเจนซี่ (อ้างอิงรายงาน Daiichi: dark ribbon header + brand CI accent + cover + exec summary + KPI card). `6-report.md` = module doc. แยก "ตัวเลข" (API `--fetch`) จาก "บทวิเคราะห์" (Claude เติมใน `report_data.json`) → `--render`. มี `--mock` ดูตัวอย่าง.
5. **cross-OS auto-install** — นักเรียนอาจไม่มี Python/ใช้ Windows. `report/setup_env.sh` (Mac/Linux) + `setup_env.ps1` (Windows) ติดตั้ง Python/pip/python-pptx อัตโนมัติ. `SKILL.md` rule: ขาดอะไรติดตั้งเลยไม่ถาม. gen_report หา Chrome/Edge ข้าม OS.

## What Worked
- **แยกตัวเลข/บทวิเคราะห์** ใน gen_report — API ดึงเลขจริง, Claude เติม analysis ใน json, script render 3 formats. กัน Claude มั่วตัวเลข.
- **Brand CI 1 ตัวแปร** — `BRAND_ACCENT` (hex) → script คำนวณเฉดเข้ม/อ่อนเอง (`_mix/_dark/_soft`), ribbon/KPI/funnel/chip เปลี่ยนสีทั้งชุด. Verified เปลี่ยนน้ำเงิน→เขียวมรกต OK.
- **Single-source config** — gen_report `load_brand_profile()` parse `KEY=value` จาก BRAND_PROFILE.md เป็น fallback (`.env > env > BRAND_PROFILE > default`). นักเรียนกรอกไฟล์เดียวจบ (ACCOUNT_ID/BRAND_NAME/BRAND_ACCENT/CPR_TARGET). แก้ปัญหา docs บอกใส่ BRAND_PROFILE แต่ script อ่าน .env.
- **Font portable** — EN font default = Sarabun (ทุกเครื่องมี) แทน Montserrat (Daiichi ใช้ แต่เครื่องนักเรียนไม่มี). Override ผ่าน `REPORT_EN_FONT`.
- **PPTX verify แบบ inspect** — ไม่มี LibreOffice แปลง PPTX→ภาพ. ตรวจ shape bounds (out-of-bounds=0), ribbon, สี, ไทยอ่านออก, font ผ่าน python-pptx inspect แทน.
- HTML verify ด้วย Chrome headless `--screenshot` → อ่านภาพ (ไทยไม่เพี้ยน, layout ครบ).

## What Didn't Work / ข้อควรระวัง
- **LibreOffice/PowerPoint/aspose ไม่มีในเครื่อง** → แปลง PPTX เป็นภาพไม่ได้. Verify PPTX ได้แค่เชิงโครงสร้าง (inspect). Mark เปิด `.pptx` ดูจริงเองได้ (`--mock`).
- **เคยเขียนผิด** ว่า "Module 1-5 ไม่ต้องใช้ Python" — ผิด. ทุก module รัน python ยิง API (urllib). แก้แล้ว: Python = core ตั้งแต่สร้างแอด.
- **PEP 668** (Homebrew Python externally-managed) block `pip install`. setup_env.sh มี fallback `--user` → `--break-system-packages`.
- **caveman mode** เปิดอยู่ (SessionStart hook) — ตอบผู้ใช้แบบ caveman full. โค้ด/commit เขียนปกติ.

## โครงสร้างไฟล์ (17 ไฟล์)
```
my-ads/
├── SKILL.md          ← router + เมนูนำทาง + bootstrap rule + safety + API base
├── BRAND_PROFILE.md  ← ★ นักเรียนกรอก: ธุรกิจ/KPI/persona/config รายงาน/memory
├── QUICKSTART.md     ← เริ่ม 5 นาที ไม่มีโค้ด (Mac+Win)
├── README.md · SETUP.md  ← ติดตั้ง + Step 0 เตรียมเครื่อง + token
├── 1-setup.md .. 5-monthly.md  ← สร้าง/weekly/optimize/planning/monthly
├── 6-report.md       ← รายงานส่งหัวหน้า
├── GHOST_FILTER.md · EMERGENCY.md
├── report/
│   ├── gen_report.py   ← generator 3 formats (mock/fetch/render)
│   ├── setup_env.sh · setup_env.ps1  ← bootstrap auto-install
│   └── (report_data.json + รายงานแอด-*.{html,pdf,pptx} = gitignored)
├── dashboard-mockup.html · report-monthly.html  ← mockup เดิม (ยังไม่ต่อ API)
└── HANDOFF.md (ไฟล์นี้)
```

## Next Steps (ค้าง — Mark ยังไม่เคาะ)
1. **dashboard-mockup.html + report-monthly.html** ยังเป็น mockup (เลขสมมติ) — จะต่อ API จริงในเบราว์เซอร์ (static + token ฝั่ง client ตาม README) หรือปล่อยเป็นตัวอย่าง? report-monthly.html ตอนนี้ซ้ำซ้อนกับ gen_report แล้ว — พิจารณาลบ/รวม.
2. **ทดสอบ end-to-end จริง** — ยังทดสอบด้วย `--mock` เท่านั้น. ยังไม่เคย `--fetch` ด้วย token จริง (ไม่มี .env ในเครื่องนี้). ควรลองกับบัญชีจริง 1 ครั้งก่อนส่งนักเรียน.
3. **ทดสอบบน Windows จริง** — setup_env.ps1 + gen_report cross-OS ผ่าน syntax/logic check แต่ยังไม่รันบน Windows จริง.
4. **งานพี่โอค้างอื่น** (ไม่เกี่ยว skill โดยตรง) — ดู `HANDOFF-พี่โอ.md`: วันอบรมจริง (placeholder 6 ก.ค.), วันชำระในใบวางบิล.

## เชื่อมโยง
- Ghost chat standard ต้นฉบับ: `~/Desktop/Ads Optimize/_templates/GHOST_CHAT_STANDARD.md`
- รายงาน Daiichi (มาตรฐานดีไซน์อ้างอิง): `~/Desktop/Ads Optimize/Daiichi/build_report_daiichi_jun2026.py`
- Context พี่โอ/คอร์ส: `../HANDOFF-พี่โอ.md` · memory `project_obilix_pi_o_course.md`
