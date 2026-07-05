# Module 2 — ดูผลรายสัปดาห์
> ดึงผลแอด → เทียบสัปดาห์นี้ vs สัปดาห์ที่แล้ว → อ่าน KPI เป็น → สรุปให้ทีม
> คู่กับสไลด์ P5 (Weekly Review)

> ⚙️ โค้ดใช้ `api_get`/`ACCOUNT_ID` จาก **SKILL.md** — อ่าน SKILL.md + โหลด .env ก่อนรัน

---

## 💡 ทำไมต้องดูทุกสัปดาห์

แอดไม่ใช่ "ตั้งแล้วลืม" — ต้องดูว่า CPR ขึ้นหรือลง แล้วปรับทัน
รายสัปดาห์ = จับปัญหาได้ก่อนเสียงบเยอะ

---

## ขั้นตอน

```
1. กำหนดช่วงวันที่ (สัปดาห์นี้ + สัปดาห์ที่แล้ว)
2. ดึงผลทั้ง 2 สัปดาห์
3. คำนวณ % เปลี่ยน (WoW)
4. เทียบ KPI กับเป้าใน BRAND_PROFILE → ให้สถานะ ✅⚠️🔴
5. สรุปสั้นให้ทีมอ่าน + Action
```

---

## Step 1–2 — ดึงผล 2 สัปดาห์

```python
def fetch(since, until):
    params = {
        "fields": "spend,impressions,reach,cpm,frequency,actions,cost_per_action_type",
        "time_range": json.dumps({"since": since, "until": until}),
        "level": "account",
    }
    return api_get(f"{ACCOUNT_ID}/insights", params)["data"]

wk_now  = fetch("2026-06-29", "2026-07-05")   # สัปดาห์นี้
wk_prev = fetch("2026-06-22", "2026-06-28")   # สัปดาห์ที่แล้ว
```

### ดึงค่า CPR (แชท) ออกมา

```python
def get_cpr(row):
    # CPR = ค่าต่อ 1 messaging conversation started
    if not row: return None          # ช่วงไม่มีข้อมูล → กัน IndexError
    for c in row[0].get("cost_per_action_type", []):
        if c["action_type"] == "onsite_conversion.messaging_conversation_started_7d":
            return float(c["value"])
    return None

def get_msgs(row):
    if not row: return 0             # ช่วงไม่มีข้อมูล
    for a in row[0].get("actions", []):
        if a["action_type"] == "onsite_conversion.messaging_conversation_started_7d":
            return int(float(a["value"]))
    return 0
```

---

## Step 3 — คำนวณ % เปลี่ยน (WoW)

```python
def pct(now, prev):
    if not prev: return None
    return round((now - prev) / prev * 100, 1)

cpr_now, cpr_prev = get_cpr(wk_now), get_cpr(wk_prev)
change = pct(cpr_now, cpr_prev)
```

> **CPR:** ค่าลด (change < 0) = **ดี** ✅ (ถูกลง) · ค่าเพิ่ม (change > 0) = **แย่** ⚠️ (แพงขึ้น)
> (กลับกันกับจำนวนแชท ที่เพิ่ม = ดี)

---

## Step 4 — สถานะ KPI (เทียบเป้าใน BRAND_PROFILE)

| สัญลักษณ์ | หมายถึง | เงื่อนไข (เป้า CPR < ฿150) |
|:---:|---|---|
| ✅ | ดี | CPR ≤ ฿150 |
| ⚠️ | ระวัง | CPR ฿150–225 (เกินเป้า 1–1.5 เท่า) |
| 🔴 | ต้องแก้ | CPR > ฿225 (เกินเป้า 1.5 เท่า) → เปิด `3-optimize.md` |
| ▲ / ▼ | ขึ้น/ลง จากสัปดาห์ก่อน | |

---

## Step 5 — สรุปให้ทีมอ่าน (Template)

```
📊 สรุปแอดสัปดาห์นี้ — [บ้านในฝัน]
ช่วง 29 มิ.ย.–5 ก.ค.

💰 ใช้งบ: ฿X,XXX
💬 แชท: XX คน (▲/▼ XX% จากสัปดาห์ก่อน)
🎯 CPR: ฿XXX  [✅/⚠️/🔴]  (เป้า < ฿150)
👁️ Reach: XX,XXX คน | CPM ฿XX | Frequency X.Xx

🔍 อ่านออกมาว่า:
- [เช่น CPR ดีขึ้น 15% เพราะเปลี่ยนรูปใหม่]
- [เช่น กลุ่มคุณนุ่นทำดีสุด กลุ่มคุณต้นแพงกว่า]

✅ สัปดาห์หน้าทำอะไร:
- [1 action ชัดๆ เช่น เพิ่มงบกลุ่มคุณนุ่น]
```

> **กฎ:** ตัวเลขทุกตัวมาจาก API จริง — ถ้าดึงไม่ครบ บอกทีมตรงๆ อย่าเดา

---

## เช็คความผิดปกติ (Anomaly)

ถ้าเจอสัญญาณนี้ → ระวัง (ดู `3-optimize.md` หรือ `EMERGENCY.md`):

| สัญญาณ | แปลว่า |
|--------|--------|
| CPR พุ่ง > 50% สัปดาห์เดียว | รูปเริ่มเบื่อ / กลุ่มอิ่มตัว |
| Frequency > 3x | คนเดิมเห็นซ้ำเยอะ → เปลี่ยนรูป |
| Reach ตกแรง งบเท่าเดิม | อาจโดนจำกัดการมองเห็น |
| แชท = 0 ทั้งสัปดาห์ | ตรวจว่าแอด ACTIVE จริงมั้ย / ปุ่มถูกมั้ย |

---

*Module 2: ดูผลรายสัปดาห์ — my-ads*
