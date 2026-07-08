# Module 3 — ปรับแอด (Optimize)
> ผลออกมาแล้ว → ปรับอะไร? งบ / กลุ่ม / รูป / placement
> ใช้เมื่อ CPR เกินเป้า หรืออยากรีดผลให้ดีขึ้น

> ⚙️ โค้ดใช้ `api_get`/`api_post`/`ACCOUNT_ID`/`ADSET_ID`/`CAMPAIGN_ID` จาก **SKILL.md** — อ่าน SKILL.md + โหลด .env ก่อนรัน

---

## 💡 หลักคิด

อย่าปรับมั่ว — ดูข้อมูลก่อน แล้วปรับ **ทีละอย่าง** (ปรับหลายอย่างพร้อมกัน = ไม่รู้ว่าอันไหนได้ผล)

---

## Step 1 — ดึงผลระดับ Ad Set (สำคัญสุด)

```python
adsets = api_get(f"{ACCOUNT_ID}/insights", {
    "fields": "adset_name,spend,cost_per_action_type,actions,cpm,frequency",
    "level": "adset",
    "time_range": json.dumps({"since": "2026-06-29", "until": "2026-07-05"}),
})["data"]
# ดู CPR แต่ละ Ad Set (แต่ละ Persona) → ตัวไหนถูก ตัวไหนแพง
```

> **💡 ทำไมดู Ad Set:** CBO แจกงบเอง แต่เราต้องรู้ว่า Persona ไหนเวิร์ค เพื่อตัดสินใจ

---

## Step 2 — Decision Tree (เจออะไร → ทำอะไร)

```
CPR เกินเป้ามาก (🔴 > ฿225)?
├── มี Ad Set บางตัวถูก บางตัวแพง?
│   └─→ [2.1] ปิด Ad Set แพง / ย้ายงบไปตัวถูก
├── ทุก Ad Set แพงเหมือนกัน?
│   ├── Frequency > 3x? →─→ [2.3] เปลี่ยนรูป/วิดีโอใหม่
│   └── กลุ่มเล็กไป/interest แคบ? →─→ [2.2] ขยายกลุ่ม
└── เพิ่งเปิด < 3 วัน?
    └─→ รอก่อน (ยังอยู่ช่วง Learning — Facebook กำลังเรียนรู้)
```

---

## 2.1 — ย้ายงบ / ปิด Ad Set แพง

```python
# ปิด Ad Set ที่ CPR แพงเกิน
api_post(f"{ADSET_ID}", {"status": "PAUSED"})

# เพิ่มงบ Campaign (CBO) — ⚠️ ต้องถามยืนยันก่อนเสมอ
# "จะเพิ่มงบจาก ฿250 → ฿350/วัน ใช่ไหม?"
api_post(f"{CAMPAIGN_ID}", {"daily_budget": 35000})   # สตางค์
```

> ⚠️ **เพิ่ม/ลดงบ = ต้องให้คนอนุมัติยืนยันก่อน** (BRAND_PROFILE ข้อ 7)
> อย่าเพิ่มงบทีเดียวเยอะ (spike) — ค่อยๆ +20–30% ไม่งั้น CPR เด้ง

---

## 2.2 — ขยาย/เปลี่ยนกลุ่ม (Targeting)

```python
# ⚠️ ดึง targeting เดิมก่อนเสมอ — ถ้า update ตรงๆ targeting เดิมจะถูกเขียนทับหมด
cur = api_get(f"{ADSET_ID}", {"fields": "targeting"})["targeting"]

# แก้เฉพาะที่ต้องการ เช่น ขยาย radius 30 → 40 กม. / เพิ่ม interest
# (หา interest ใหม่: ดู 4-planning.md Step หา Interest)
cur["geo_locations"]["custom_locations"][0]["radius"] = 40

api_post(f"{ADSET_ID}", {"targeting": json.dumps(cur)})
```

---

## 2.3 — เปลี่ยนรูป/วิดีโอ (Creative Rotation)

```python
# ปิด Ad เก่า
api_post(f"{OLD_AD_ID}", {"status": "PAUSED"})

# สร้าง Creative + Ad ใหม่จากโพสต์ใหม่ (ดู 1-setup.md Step 5–7)
# เก็บ Ad Set เดิมไว้ (targeting ที่เวิร์คแล้ว)
```

> **💡 เมื่อไหร่เปลี่ยนรูป:** Frequency > 3x (คนเห็นซ้ำจนเบื่อ) หรือ CTR ตกเรื่อยๆ
> จดใน BRAND_PROFILE ว่ารูปแบบไหนเวิร์ค → ครั้งหน้าทำแนวนั้น

---

## 2.4 — ปรับ Placement

```python
cur = api_get(f"{ADSET_ID}", {"fields": "targeting"})["targeting"]
cur["facebook_positions"] = ["feed", "story"]   # เพิ่ม story
api_post(f"{ADSET_ID}", {"targeting": json.dumps(cur)})
```

---

## ✅ หลังปรับทุกครั้ง

- [ ] ปรับ **ทีละอย่าง** — รอดูผล 3–5 วันก่อนปรับอีก
- [ ] จดใน `BRAND_PROFILE.md` ข้อ 6: ปรับอะไร ได้ผลยังไง
- [ ] ถ้าเป็นการเพิ่มงบ/เปลี่ยนกลุ่มใหญ่ → หัวหน้ายืนยันก่อน

---

## อย่าทำ (กับดักมือใหม่)

- ❌ ปรับทุกวัน — Facebook รีเซ็ต Learning ทุกครั้งที่แก้ใหญ่ → CPR เด้ง
- ❌ ปิด Ad Set เพราะแพงวันเดียว — ดูอย่างน้อย 3 วัน
- ❌ เพิ่มงบเท่าตัวทันที — ค่อยๆ ขึ้น
- ❌ ยิงทั้งประเทศเพื่อ "ให้ถูกลง" — ได้คนนอกพื้นที่ ทักแล้วเสียเปล่า

---

## ➡️ ต่อไปทำอะไร (เสนอให้นักเรียนเลือก — พิมพ์เลข)
```
✅ ปรับแอดเสร็จ · ต่อไป?
  1. ให้หัวหน้ายืนยันก่อนเปิด (ถ้าแก้แล้วต้อง ACTIVE ใหม่)
  2. รอ 3-4 วันให้ Learning นิ่ง แล้วมาดูผล → 2-weekly.md
  3. จดสิ่งที่แก้ + ผลที่ได้ลง BRAND_PROFILE.md ข้อ 6 (เวิร์ค/ไม่เวิร์ค)
```

---

*Module 3: ปรับแอด — my-ads*
