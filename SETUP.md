# SETUP — ตั้งค่าครั้งแรก (ทำครั้งเดียว)

> ต่อจากสไลด์ T4 (Meta API) + T5 (App + Token) ในคอร์ส
> เป้าหมาย: ได้ Token + ใส่ .env + ทดสอบว่าดึงข้อมูลแอดได้จริง

---

## ต้องมีก่อน

- [ ] Facebook Page ของธุรกิจ (ที่จะยิงแอด)
- [ ] Ad Account (บัญชีโฆษณา) + ใส่บัตร/วิธีจ่ายเงินแล้ว
- [ ] เป็น Admin ของ Page + Ad Account
- [ ] ติดตั้ง Claude Code CLI แล้ว (Setup 0 ในคอร์ส)

---

## Step 0 — เตรียมเครื่อง (ติดตั้งอัตโนมัติ) · ทำครั้งเดียว

> skill รัน **Python** เพื่อยิง API (ใช้ตั้งแต่สร้างแอด ไม่ใช่แค่รายงาน)
> **นักเรียนไม่ต้องทำเอง** — พิมพ์กับผู้ช่วย: **"ช่วยเตรียมเครื่องให้ใช้ my-ads ได้"**

ผู้ช่วยจะรัน bootstrap ให้ตาม OS — ตรวจ+ติดตั้งของที่ขาดเองอัตโนมัติ:
```
Mac / Linux :  bash report/setup_env.sh
Windows     :  powershell -ExecutionPolicy Bypass -File report\setup_env.ps1
```

สคริปต์จัดการให้ครบ:
| ของ | ใช้ทำอะไร | ไม่มี → ทำอะไร |
|-----|-----------|---------------|
| **Python 3** | ยิง API ทุก module | ติดตั้งเอง (Mac brew · Linux apt · Win winget) |
| **python-pptx** | ทำ PPTX (Module 6) | `pip install python-pptx` อัตโนมัติ |
| **Chrome / Edge** | ทำ PDF (Module 6) | Windows มี Edge อยู่แล้ว · ไม่มี → เปิด HTML พิมพ์เอง |

> Windows ถ้าเพิ่งติดตั้ง Python ผ่าน winget → ปิด PowerShell เปิดใหม่ 1 ครั้งให้ PATH อัปเดต

---

## Step 1 — หา Ad Account ID + Page ID

**Ad Account ID:**
1. เข้า [business.facebook.com](https://business.facebook.com) → Ads Manager
2. มุมซ้ายบนมีเลขบัญชี เช่น `123456789012` → ใส่เป็น `act_123456789012`

**Page ID:**
1. เข้าเพจ → About / เกี่ยวกับ → เลื่อนล่างสุด เจอ "Page ID"
2. หรือถามผู้ช่วย: "ช่วยหา Page ID จากชื่อเพจ [ชื่อ]"

→ เอาไปใส่ใน `BRAND_PROFILE.md` ข้อ 2

---

## Step 2 — สร้าง App + Token (2 ทาง)

### ทาง A (ง่ายสุด — แนะนำมือใหม่): Graph API Explorer
1. เข้า [developers.facebook.com/tools/explorer](https://developers.facebook.com/tools/explorer)
2. สร้าง App (ถ้ายังไม่มี) → เลือกประเภท "Business"
3. เลือก Permissions พวกนี้:
   - `ads_management`, `ads_read` (งานแอด)
   - `pages_read_engagement`, `pages_show_list` (อ่านเพจ)
   - `pages_messaging`, `pages_read_user_content` (อ่าน inbox — ใช้ตอน monthly)
4. กด **Generate Access Token** → copy token ที่ได้

> 🔑 **สำคัญ — ทำ token ยาว 60 วันเลย** (ไม่งั้นเจ็บซ้ำ):
> Token จาก Explorer อายุสั้น **~1–2 ชม.** → ใช้ๆ อยู่ตายกลางคัน
> **บอกผู้ช่วย: "ช่วยแลก token เป็นแบบ 60 วันให้หน่อย"** → ผู้ช่วยแลกให้ (endpoint `oauth/access_token`) แล้วเอาตัวยาวไปใส่ .env
> ครบ 60 วันค่อยทำใหม่ · ถ้าวันไหน "แอดดึงข้อมูลไม่ได้" ให้เดาไว้ก่อนว่า **token หมดอายุ → ทำใหม่**

### ทาง B: ให้ผู้ช่วยพาทำทีละขั้น
พิมพ์: **"ช่วยพาทำ Meta App + Token ทีละขั้น"** → ผู้ช่วยไล่ให้ทีละหน้าจอ

---

## Step 3 — ใส่ Token ลง .env (ห้ามใส่ในโค้ด)

สร้างไฟล์ `.env` ในโฟลเดอร์ skill:

```
FB_ACCESS_TOKEN_ADS=วางtokenตรงนี้
FB_ACCESS_TOKEN_PAGE=วางtokenตรงนี้
```

> ทั้งสองใช้ token เดียวกันก็ได้ ถ้า token มี permission ครบทั้งงานแอด+เพจ

**เสร็จแล้วใช้ได้เลย** — skill อ่าน `.env` จากในโฟลเดอร์เอง ไม่ต้องพิมพ์คำสั่งอะไรเพิ่ม
(ถ้าวางไฟล์ผิดที่ ผู้ช่วยจะเตือน "ไม่เจอ token — ทำ .env ก่อน")

> 🔒 **ห้าม** commit `.env` ขึ้น git · ห้ามส่ง token ให้ใคร · token = กุญแจบัญชีโฆษณา
> (`.gitignore` กัน `.env` ให้แล้ว)

---

## Step 4 — ทดสอบว่าต่อติด

พิมพ์กับผู้ช่วย: **"ทดสอบว่าต่อ API ติดมั้ย"** — ผู้ช่วยจะใช้ตัวโหลด `.env` จาก SKILL.md แล้วลองดึงชื่อบัญชี

```python
# (ผู้ช่วยรันให้ — ใช้ TOKEN_ADS ที่โหลดจาก .env ใน SKILL.md)
r = api_get("act_XXXXXXXXXXXX", {"fields": "name,account_status,currency"})   # ใส่ Account ID ของคุณ
print(r)
```

**ผ่าน** = เห็นชื่อบัญชี + `account_status: 1` (1 = ใช้งานได้)
**ไม่ผ่าน** → ดูตาราง Error ล่าง

---

## Error ตอน setup ที่เจอบ่อย

| Error | แปลว่า | แก้ |
|-------|--------|-----|
| `Invalid OAuth 2.0 Access Token` | token หมดอายุ/ผิด | สร้าง token ใหม่ (Step 2) |
| `(#200) permission` | ขาด permission | เพิ่ม scope ตอน generate token |
| `Unsupported get request` | ID ผิด (ลืม `act_`) | Ad Account ต้องมี `act_` นำ |
| `account_status: 2` | บัญชีถูกระงับ | ดู EMERGENCY.md Scenario 1 |

---

## เสร็จแล้วทำอะไรต่อ

- [ ] กรอก `BRAND_PROFILE.md` ให้ครบ (ธุรกิจ + KPI + Persona)
- [ ] ยังไม่มีแคมเปญ → ไป `4-planning.md` (วางแผน) แล้ว `1-setup.md` (สร้าง)
- [ ] มีแคมเปญแล้ว → ไป `2-weekly.md` (ดูผล)

---

*SETUP — my-ads*
