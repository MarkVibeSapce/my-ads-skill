# my-ads — ผู้ช่วยยิงแอด Facebook สำหรับธุรกิจคุณเอง

> Student Skill · คอร์ส Facebook Ads × AI (AI Easy Pro)
> ใช้กับ **Claude Code CLI** — ดูแลแอดของแบรนด์คุณ ตั้งแต่วางแผน → สร้าง → ดูผล → ปรับ

---

> 🎓 **นักเรียนไม่มีพื้นฐาน?** อ่าน `QUICKSTART.md` แทน (5 นาที ไม่มีโค้ด) — หน้านี้เป็นเวอร์ชันละเอียด

## เริ่มใช้ 4 ขั้น (ทำครั้งเดียว)

### 1. ติดตั้ง skill
copy โฟลเดอร์ `my-ads/` ทั้งอันไปที่:
```bash
cp -r my-ads ~/.claude/skills/
```
เปิด Claude Code แล้วพิมพ์ **/my-ads** — ถ้าเจอ = ติดตั้งสำเร็จ

### 2. กรอกข้อมูลธุรกิจ
เปิด `~/.claude/skills/my-ads/BRAND_PROFILE.md` → แก้จากตัวอย่าง "บ้านในฝัน ดีไซน์" เป็น**ธุรกิจคุณ**:
- ข้อ 1 ธุรกิจ + USP + objection
- ข้อ 3 KPI (เป้า CPR)
- ข้อ 4 Persona (จาก workshop คอร์ส)
- ข้อ 7 ทีม + ใครอนุมัติได้

### 3. ต่อ Token (ทำตาม `SETUP.md`)
- สร้าง Meta App + Token (ต่อสไลด์ T4/T5)
- ใส่ `ACCOUNT_ID` + `PAGE_ID` ใน BRAND_PROFILE ข้อ 2
- สร้างไฟล์ `.env`:
  ```
  FB_ACCESS_TOKEN_ADS=...
  FB_ACCESS_TOKEN_PAGE=...
  ```
- โหลดก่อนใช้: `export $(grep -v '^#' .env | xargs)`
- 🔒 ห้าม commit `.env` · ห้ามส่ง token ให้ใคร

### 4. เริ่มทำงาน
บอก Claude Code เป็นภาษาคน — skill route ให้เอง:

| พูดว่า | ทำ |
|--------|-----|
| "วางแผนแอดใหม่" / "หา persona" | `4-planning.md` |
| "สร้างแคมเปญ" | `1-setup.md` |
| "ดูผลสัปดาห์นี้" | `2-weekly.md` |
| "แอดแพง / ปรับแอด" | `3-optimize.md` |
| "สรุปเดือน / ลูกค้าถามอะไร" | `5-monthly.md` |
| "แอดโดนแบน / งบหมด" | `EMERGENCY.md` |

---

## ลำดับใช้งานปกติ (loop)
```
เดือนแรก:  4-planning → 1-setup → (หัวหน้าเปิดแอด)
ทุกสัปดาห์: 2-weekly → (เจอปัญหา) 3-optimize
สิ้นเดือน:  5-monthly → ออก report PDF → อัปเดต BRAND_PROFILE ข้อ 6
```

---

## หน้าจอ 2 ตัว (dashboard + report)

| ไฟล์ | คือ |
|------|-----|
| `dashboard-mockup.html` | หน้า dashboard ดูผลรวม — เลือกช่วงเวลา (วัน/สัปดาห์/กำหนดเอง) + ปุ่มที่ปรึกษา AI |
| `report-monthly.html` | หน้ารายงานเดือน A4 พร้อมพิมพ์ PDF |

> ⚠️ ตอนนี้เป็น **mockup (เลขตัวอย่าง)** — เปิดดูดีไซน์ได้เลย แต่ยังไม่ดึงข้อมูลจริง

### ต่อข้อมูลจริง (ไม่ต้องมี server)
สถาปัตย์ที่วางไว้ = **static + token อยู่ในเบราว์เซอร์คุณเอง** (ไม่มี backend/DB):
```
[หน้า HTML]  ─ ใส่ Meta token + Account ID (เก็บใน browser คุณ)
     ├─ browser เรียก Meta Graph API ตรง → เติมเลขจริงลง dashboard/report
     └─ ปุ่มที่ปรึกษา → browser เรียก Claude API ตรง (คีย์คุณเอง) → วิเคราะห์
                         *กดเองทุกครั้ง เพราะใช้ token
```
- ไม่เก็บ token ที่ฝั่งเรา = ปลอดภัย ไม่ต้องทำ App Review
- เอาขึ้น online: deploy เป็น **static** บน Vercel/Cloudflare Pages ได้เลย
- รายละเอียดออก PDF จาก report → ดู `5-monthly.md` Step 7

---

## ⚠️ กฎความปลอดภัย (ห้ามข้าม)
- สร้างแอดอะไรก็ตาม **status = PAUSED เสมอ** → ให้หัวหน้าตรวจก่อนเปิด
- **ก่อนเพิ่มงบ / เปิดแอด** ต้องมีคนอนุมัติยืนยัน
- งบเป็น**หน่วยสตางค์** (฿250 = 25000) — พลาด = ผิด 100 เท่า
- ตัวเลขรายงานมาจาก **API จริงเท่านั้น** ห้ามเดา

---

## โครงสร้างไฟล์
```
my-ads/
├── README.md         ← ไฟล์นี้ (เริ่มที่นี่)
├── SKILL.md          ← router + API base + กฎ
├── BRAND_PROFILE.md  ← ข้อมูลธุรกิจคุณ (กรอกเอง)
├── SETUP.md          ← ทำ token + .env
├── 1-setup.md        ← สร้างแอด
├── 2-weekly.md       ← ดูผลสัปดาห์
├── 3-optimize.md     ← ปรับแอด
├── 4-planning.md     ← วางแผน + persona
├── 5-monthly.md      ← สรุปเดือน + PDF
├── EMERGENCY.md      ← วิกฤต
├── dashboard-mockup.html
└── report-monthly.html
```

---

*my-ads · AI Easy Pro — คอร์ส Facebook Ads × AI*
