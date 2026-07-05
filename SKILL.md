---
name: my-ads
description: |
  ผู้ช่วยยิงแอด Facebook สำหรับทีม in-house — ดูแลแบรนด์ของคุณเองแบบครบวงจร
  ไม่ใช่แค่กดตามคำสั่ง แต่เรียนรู้ธุรกิจคุณ จำ Persona จำ KPI จำสิ่งที่เคยได้ผล
  แล้วช่วยตัดสินใจให้ดีขึ้นทุกสัปดาห์

  ใช้กับ Claude Code CLI + Meta Marketing API (ธุรกิจเดียว = ของคุณ)
  KPI หลัก: CPR (Cost per Result — ค่าต่อ 1 ผลลัพธ์ เช่น 1 แชท)

  ทำงานทุกครั้งที่ถูกเรียก:
  1. อ่าน BRAND_PROFILE.md ก่อนเสมอ → รู้ธุรกิจ / KPI / Persona / สิ่งที่เรียนรู้ไว้
  2. ดู task → เปิด module ที่ตรง
  3. ทำงาน → จบแล้วอัปเดต BRAND_PROFILE.md ด้วยสิ่งใหม่ที่รู้

  Trigger เมื่อ:
  - "ตั้งค่าครั้งแรก", "ต่อ token", "เชื่อม API" → SETUP.md
  - "สร้างแคมเปญ", "สร้างแอด", "เพิ่ม ad set" → 1-setup.md
  - "ดูผลสัปดาห์นี้", "weekly", "แอดเป็นไง" → 2-weekly.md
  - "ปรับแอด", "optimize", "แอดแพง", "เปลี่ยน targeting" → 3-optimize.md
  - "วางแผน", "หา persona", "หา interest", "แผนแอดใหม่" → 4-planning.md
  - "สรุปเดือน", "monthly", "ลูกค้าถามอะไร", "inbox" → 5-monthly.md
  - "แอดโดนแบน", "account disabled", "ad rejected", "งบหมด", "ยอดดิ่ง" → EMERGENCY.md
---

# my-ads — ผู้ช่วยยิงแอด Facebook ทีม In-house

> ผู้ช่วยที่ดูแลแอดของ **แบรนด์คุณเอง** ตั้งแต่วางแผน → สร้าง → ดูผล → ปรับ
> เป้าหมาย: ทีมเล็กไม่มีพื้นฐาน ก็ยิงแอดเองได้ อ่านผลเป็น ตัดสินใจถูก
> คู่กับสไลด์คอร์ส "Facebook Ads × AI"

---

## เริ่มยังไง (อ่านก่อนทุกครั้ง)

```
ครั้งแรกสุด (ทำครั้งเดียว):
  1. เปิด SETUP.md → ทำ Meta App + Token → ใส่ .env
  2. เปิด BRAND_PROFILE.md → กรอกธุรกิจคุณให้ครบ

ทุก session หลังจากนั้น:
  1. อ่าน BRAND_PROFILE.md      → รู้ธุรกิจ / KPI / Persona / สิ่งที่เรียนรู้
  2. ดูว่างานนี้ตรง module ไหน  → เปิด module นั้น
  3. ทำงานตามขั้นตอนใน module
  4. เสร็จแล้ว → อัปเดต BRAND_PROFILE.md (Persona ใหม่, KPI ที่ได้จริง, สิ่งที่เวิร์ค/ไม่เวิร์ค)
```

---

## โครงสร้าง Skill

> 🆕 **ติดตั้งครั้งแรก / ยังไม่เคยใช้** → เปิด `README.md` ก่อน (copy skill, กรอก profile, ต่อ token)

```
my-ads/
├── README.md         ← เริ่มที่นี่ (ติดตั้ง + ต่อ API จริง)
├── SKILL.md          ← ไฟล์นี้ — index + วิธีใช้ + กฎความปลอดภัย
├── BRAND_PROFILE.md  ← ★ หัวใจ — ธุรกิจคุณ + KPI + Persona + "สมอง" จำ session
├── SETUP.md          ← ครั้งแรก: ทำ Token + .env + ทดสอบ API
├── 1-setup.md        ← สร้าง Campaign / Ad Set / Ad
├── 2-weekly.md       ← ดูผลรายสัปดาห์ + WoW + อ่าน KPI เป็น
├── 3-optimize.md     ← ปรับงบ / targeting / creative (decision tree)
├── 4-planning.md     ← วางแผน: Persona → Interest → โครงสร้าง
├── 5-monthly.md      ← สรุปเดือน + วิเคราะห์ Inbox (ลูกค้าถามอะไร) + ออก PDF
├── EMERGENCY.md      ← แอดโดนแบน / งบหมด / ยอดดิ่ง — ทำไงทันที
│
├── dashboard-mockup.html  ← หน้า dashboard ดูผลรวม (เลือกช่วงเวลา + ที่ปรึกษา AI)
└── report-monthly.html    ← หน้ารายงานเดือน A4 พร้อมพิมพ์ PDF (ดู 5-monthly.md Step 7)
```

**หลักการ:** แต่ละ module อิสระ อ่านเฉพาะที่ต้องใช้ ไม่ต้องอ่านหมด

---

## KPI หลัก: CPR (Cost per Result)

> **CPR = เงินที่จ่าย ÷ จำนวนผลลัพธ์ที่ได้**

ธุรกิจ Messages (เช่น รับออกแบบบ้าน) → 1 Result = 1 คนทักแชท
- CPR ฿120 = จ่าย ฿120 ได้ 1 คนทัก
- **ยิ่งต่ำยิ่งดี** (ตรงข้ามกับ ROAS ที่ยิ่งสูงยิ่งดี)

ดูเป้า CPR ของคุณใน `BRAND_PROFILE.md`

---

## ⚠️ กฎความปลอดภัย (ห้ามข้าม — สำคัญที่สุด)

ทีมไม่มีพื้นฐาน + เงินจริงหมุน → กฎพวกนี้กันพลาด:

| กฎ | ทำไม |
|----|------|
| **สร้างอะไรก็ตาม status = PAUSED เสมอ** | กันแอดวิ่งกินเงินก่อนตรวจ |
| **ก่อนกด "เปิด" (ACTIVE) ต้องมีคนในทีมตรวจ + ยืนยัน** | แอดพลาด = เสียเงินจริง |
| **ก่อนเพิ่มงบ ต้องถามยืนยันตัวเลข** | "จะเปลี่ยนงบจาก ฿X → ฿Y ใช่ไหม?" |
| **งบเป็นหน่วยสตางค์** | ฿250 = ใส่ `25000` — พลาดตรงนี้ = งบผิด 100 เท่า |
| **ตัวเลขในรายงานมาจาก API จริงเท่านั้น** | ห้ามเดา ห้ามประมาณ |

---

## Growth Path — ผู้ช่วยเก่งขึ้นเรื่อยๆ

ยิ่งใช้ ยิ่งกรอก BRAND_PROFILE.md → ยิ่งช่วยได้แม่น:

| ระดับ | ลักษณะ | เมื่อไหร่ |
|-------|--------|---------|
| **มือใหม่** | ถามทุกขั้น ทำตาม module ทีละ step | เริ่มต้น |
| **คุ้นงาน** | รู้ workflow แล้ว ถามเฉพาะจุดตัดสินใจ | หลังทำ ~3–5 ครั้ง |
| **เชื่อมือ** | ทำเองได้ รายงานทีมตอนเสร็จ + เตือนสิ่งที่ควรทำ | รู้ธุรกิจครบ |

**เตือนล่วงหน้า** เมื่อเชื่อมือแล้ว เช่น:
- "สัปดาห์นี้ CPR ขึ้น 30% — น่าจะเปลี่ยนรูปใหม่"
- "สิ้นเดือนแล้ว ทำสรุปเดือนมั้ย?"

---

## API Base Pattern (ทุก module ใช้ร่วมกัน)

```python
import urllib.request, urllib.parse, json, os

# อ่าน token จาก .env (ทำใน SETUP.md) — ห้าม hardcode token ในโค้ด
TOKEN_ADS  = os.environ["FB_ACCESS_TOKEN_ADS"]    # งานแอด
TOKEN_PAGE = os.environ["FB_ACCESS_TOKEN_PAGE"]   # งานเพจ (inbox/posts)
API = "https://graph.facebook.com/v21.0"

def api_get(path, params, token=None):
    params["access_token"] = token or TOKEN_ADS
    url = f"{API}/{path}?{urllib.parse.urlencode(params)}"
    with urllib.request.urlopen(url) as r:
        return json.loads(r.read())

def api_post(path, data):
    data["access_token"] = TOKEN_ADS
    body = urllib.parse.urlencode(data).encode()
    with urllib.request.urlopen(f"{API}/{path}", body) as r:
        return json.loads(r.read())
```

> ค่า `ACCOUNT_ID` และ `PAGE_ID` อยู่ใน `BRAND_PROFILE.md` — ของธุรกิจคุณเอง

---

## เชื่อมกับสไลด์คอร์ส

| สไลด์ | Module ที่คู่กัน |
|-------|----------------|
| P2 · Ads Manager (Campaign→AdSet→Ad, Audience, Placement, CBO) | `1-setup.md` |
| P3 · Persona Workshop | `4-planning.md` |
| P4 · Campaign Blueprint | `4-planning.md` |
| P5 · Weekly Review | `2-weekly.md` |
| P6 · Monthly Loop | `5-monthly.md` |

สไลด์ = สอน "ทำไม" · skill นี้ = ลงมือ "ทำจริง"

---

*my-ads — Student Skill สำหรับคอร์ส Facebook Ads × AI · AI Easy Pro*
