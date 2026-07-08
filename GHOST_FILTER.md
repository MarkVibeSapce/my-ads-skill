# GHOST_FILTER — โหมดกรองแชทผี (เพิ่มคุณภาพแชท)
> เปิดโหมดนี้เมื่อทำแอชแบบ "ทักแชท" (Messages/CONVERSATIONS)
> ที่มา: มาตรฐาน Ghost Chat ของทีม Ads Optimize — ย่อให้ทีม in-house ใช้เอง

---

## 👻 แชทผีคืออะไร (พูดง่ายๆ)

**แชทผี** = คนกดปุ่มทักแชทมั่วๆ หรือทักแล้วไม่คุยต่อ — Facebook นับเป็น "แชท" แต่**ไม่ใช่ลูกค้าจริง**

**อาการหลอกตา:**
```
Cost/Message ดูถูก (เช่น ฿120/แชท)  ← ดูดี
แต่ 50–65% ไม่คุยต่อ → ลูกค้าจริงแค่ ~7 คน
= ต้นทุนลูกค้าจริงแพงกว่าที่เห็น 5–8 เท่า
```

> ตัวเลข "จำนวนแชท" หลอกตา — ต้องดู **คุณภาพ** (คุยลึก/พิมพ์เอง) ไม่ใช่แค่ปริมาณ

---

## 🤖 สกิลต้องถามก่อนสร้างแคมเปญแชท

ทุกครั้งที่จะสร้างแคมเปญ objective = แชท (`OUTCOME_ENGAGEMENT` + `CONVERSATIONS`) **ถามผู้ใช้ก่อน:**

> "แคมเปญนี้เป็นแบบทักแชท — **เปิดโหมดกรองแชทผีมั้ย?**
> เปิด = แชทน้อยลงนิดแต่คุณภาพสูงขึ้น (คนทักจริงจัง ไม่ใช่กดมั่ว)"

- **เปิด** → apply 6 ข้อด้านล่างตอนสร้าง + จด `BRAND_PROFILE.md` ว่าเปิดไว้
- **ปิด** → สร้างปกติ แต่เตือนให้วัด depth (ข้อ "วัดผล") หลังยิง 1 สัปดาห์

> จำ choice ไว้ใน `BRAND_PROFILE.md` ข้อ 3 → ครั้งหน้าไม่ต้องถามซ้ำ (ถามยืนยันสั้นๆ พอ)

---

## ✅ เปิดโหมดกรอง = ทำ 6 ข้อ

| # | ทำอะไร | ทำที่ไหน | โค้ด/ค่า |
|---|--------|---------|---------|
| 1 | **ตัด Audience Network** (placement คุณภาพต่ำ กดผิดเยอะ) | Ads Manager (API) | `publisher_platforms: ["facebook","instagram"]` เท่านั้น |
| 2 | **ปิด Advantage+ audience** (กัน Meta ขยายกลุ่มมั่ว) | Ads Manager (API) | `targeting_automation: {"advantage_audience": 0}` |
| 3 | **Ice Breaker = คำถามคัดกรอง** ไม่ใช่ปุ่ม "ฉันสนใจ" | **Business Suite** → Inbox → Automations (⚠️ ไม่ใช่ Ads Manager) | ถามงบ / จุดประสงค์ / ช่วงเวลาตัดสินใจ |
| 4 | **Interest เจาะจง / LAL** ไม่ broad | Ads Manager (API) | interest ตรงกำลังซื้อ หรือ LAL 1% จากคนดูวิดีโอ 75%+/ลูกค้าเก่า |
| 5 | **ปักหมุดพื้นที่ + radius** (ห้าม province/ทั้งประเทศ) | Ads Manager (API) | `custom_locations` + `radius` (default 30km) |
| 6 | **Exclude คนทักแล้วหาย** (กันคนกลุ่มเดิมกดซ้ำ) | Audiences UI (1 คลิก) แล้ว apply | "People who messaged Page" → ใส่ช่อง exclude ของ Ad Set |

> ข้อ 1, 2, 5 = สกิลนี้ตั้ง default ให้อยู่แล้วใน `1-setup.md` Step 4 — โหมดกรองแค่ **ย้ำ + เพิ่มข้อ 3, 4, 6**
> ⚠️ ข้อ 6 ถ้าสร้าง exclude ผ่าน API ติด error #2654 → สร้างใน **Audiences UI** แทน (คลิกเดียว)

### ข้อ 3 — ตัวอย่างคำถามคัดกรอง (Ice Breaker / Welcome)
```
ปุ่มเก่า (ได้แชทผี):   "ฉันสนใจ"  · "ขอคุยเจ้าหน้าที่"   ← ใครก็กด
ปุ่มใหม่ (คัดคุณภาพ):
  • "มีที่ดินแล้วหรือยัง?"        (จุดประสงค์)
  • "งบประมาณคร่าวๆ เท่าไหร่?"    (กำลังซื้อ)
  • "อยากเริ่มเมื่อไหร่?"         (ช่วงเวลาตัดสินใจ)
```
> โชว์ราคา/เงื่อนไข upfront ในข้อความต้อนรับด้วย → คนไม่จริงเด้งออกเอง

---

## 📊 วัดผล — เลิกดู Cost/Message เดี่ยว

หลังยิง ~1 สัปดาห์ ดึง funnel ความลึกของแชท:

```python
# ดูว่าคนทักแล้ว "คุยลึก" แค่ไหน (ไม่ใช่แค่กดเปิด)
r = api_get(f"{ACCOUNT_ID}/insights", {
    "fields": "actions,cost_per_action_type",
    "date_preset": "last_7d",
    "level": "campaign",
})
# ในผลลัพธ์ actions มองหา:
#   messaging_conversation_started_7d      (เริ่มแชท / connection)
#   messaging_user_depth_2_message_send    (คุยลึก 2+ ข้อความ)  ← KEY
#   messaging_user_depth_3_message_send    (คุยลึก 3+)
#   messaging_block                        (โดนบล็อก = สัญญาณ ghost)
```

| Metric | ความหมาย | เป้า |
|--------|----------|------|
| **Reply depth rate** = depth 2+ ÷ connection | คนทักแล้วคุยต่อจริงกี่ % | **> 20%** |
| **Ghost %** = ปุ่มมั่ว + spam + ไม่ตอบ | สัดส่วนแชทผี | **< 20%** |
| Qualified rate | พิมพ์เอง + เข้าเกณฑ์ | > 30% |

> ⚠️ เกณฑ์นี้เป็นค่าเริ่มต้น — สินค้าราคาสูง/ตัดสินใจนาน depth จะต่ำกว่าธรรมชาติ
> → ตั้งเป้าเทียบ baseline เดือนแรกของธุรกิจคุณเอง (จดใน `BRAND_PROFILE.md` ข้อ 6)

### เกณฑ์ตัดสิน
| Ghost % | สถานะ | ทำอะไร |
|---------|-------|--------|
| < 20% | 🟢 ปกติ | ดูต่อ |
| 20–40% | 🟡 เฝ้าระวัง | ย้ำข้อ 3, 4, 6 |
| > 50% | 🔴 วิกฤต | เปลี่ยน objective → Lead Form / Call Ads + ปิด Ice Breaker generic |

---

## 🔎 เช็คแชทผีจาก Inbox (ดูว่าใครพิมพ์เอง vs กดปุ่ม)

```python
# ข้อความแรกของแต่ละแชท — ถ้าซ้ำกันเป๊ะหลายคน = ปุ่ม Ice Breaker (ghost)
convos = api_get(f"{PAGE_ID}/conversations",
    {"fields": "id,updated_time,message_count,snippet"}, token=PAGE_TOKEN)
# ข้อความแรก unique = พิมพ์เอง (intent จริง) · ซ้ำ = ปุ่ม (ghost)
# snippet ขึ้นต้นด้วยคำทักทายของเพจเอง = re-blast (เพจส่งหาก่อน ลูกค้าไม่ตอบ = ghost)
```

**Quality rate = จำนวนคนพิมพ์เองจริง ÷ แชททั้งหมด**

---

## เชื่อมกับสไลด์คอร์ส
| สไลด์ | เกี่ยวกับ |
|-------|----------|
| P5 · Weekly Review | วัด depth แทน Cost/Message |
| P6 · Monthly Loop | สรุป Ghost % + qualified rate ต่อเดือน |

---

## ➡️ ต่อไปทำอะไร (เสนอให้นักเรียนเลือก — พิมพ์เลข)
```
✅ ตั้งค่ากรองแชทผีแล้ว · ต่อไป?
  1. สร้าง/เปิดแคมเปญแชทตามที่กรองไว้ → 1-setup.md
  2. รอ 1 สัปดาห์ แล้ววัด depth 2+ / Ghost% → 2-weekly.md
  3. บันทึกโหมดกรอง = เปิด + baseline ลง BRAND_PROFILE.md ข้อ 3, 6
```

---

*GHOST_FILTER — my-ads · อ้างอิง Ghost Chat Standard (Ads Optimize)*
