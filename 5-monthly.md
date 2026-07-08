# Module 5 — สรุปเดือน + อ่าน Inbox
> ภาพรวมทั้งเดือน + วิเคราะห์ว่าลูกค้าถามอะไร ติดตรงไหน
> คู่กับสไลด์ P6 (Monthly Loop)

> ⚙️ โค้ดใช้ `api_get`/`ACCOUNT_ID`/`PAGE_ID`/`PAGE_TOKEN` จาก **SKILL.md** — อ่าน SKILL.md + โหลด .env ก่อนรัน

---

## 💡 ทำไมต้องดูรายเดือน (ต่างจากรายสัปดาห์)

- รายสัปดาห์ = จับปัญหาเฉพาะหน้า
- **รายเดือน = ตัดสินใจใหญ่** — เดือนนี้คุ้มมั้ย? เดือนหน้าเพิ่มงบ/เปลี่ยนทิศมั้ย?
- + อ่าน Inbox = รู้ว่าคนที่ทักมา **ติดอะไร** → เอาไปแก้แอด/แก้การตอบ

---

## ขั้นตอน

```
1. ดึงผลแอด 3 เดือนล่าสุด (ดูแนวโน้ม)
2. ดึง Inbox ทั้งเดือน
3. จำแนกลูกค้า: Hot / Warm / Cold
4. นับคำถามยอดฮิต
5. สรุป Funnel: เห็น → ทัก → นัด
6. สรุปให้ทีม + Action เดือนหน้า
```

---

## Step 1 — ผลแอด 3 เดือน

```python
def month_range(y, m):
    import calendar
    last = calendar.monthrange(y, m)[1]
    return f"{y}-{m:02d}-01", f"{y}-{m:02d}-{last:02d}"

for (y, m) in [(2026,5),(2026,6),(2026,7)]:
    s, u = month_range(y, m)
    d = api_get(f"{ACCOUNT_ID}/insights", {
        "fields": "spend,reach,impressions,cpm,actions,cost_per_action_type",
        "time_range": json.dumps({"since": s, "until": u}),
        "level": "account",
    })["data"]
    # เก็บ spend, แชท, CPR ของแต่ละเดือน → เทียบแนวโน้ม
```

---

## Step 2 — ดึง Inbox

```python
# แลก Page Token ก่อน (ดู 1-setup.md Step 5)
convs = api_get(f"{PAGE_ID}/conversations",
    {"fields": "id,snippet,updated_time,participants", "limit": 50},
    token=PAGE_TOKEN)["data"]

# ดึงข้อความแต่ละ thread
for c in convs:
    msgs = api_get(f"{c['id']}/messages",
        {"fields": "message,from,created_time", "limit": 20},
        token=PAGE_TOKEN)["data"]
    # เก็บเฉพาะข้อความจากลูกค้า (from != เพจเรา)
```

> ⚠️ เวลาใน API เป็น UTC — บวก 7 ชม.เป็นเวลาไทยก่อนกรองเดือน

---

## Step 3 — จำแนกลูกค้า (นับใน Funnel)

| ประเภท | คำที่มักเจอ | นับ? |
|--------|------------|:---:|
| **Hot** | ขอนัด, อยากดูแบบ, โทรหา, ขอเบอร์, สนใจจริง | ✅ |
| **Warm** | ถามราคา, ขอรายละเอียด, ขอดูผลงาน | ✅ |
| **Cold** | ดูเฉยๆ, ไม่ตอบกลับ | ✅ |
| นายหน้า/ขายของ | ค่าคอม, รับเอเจนต์, ขายบริการอื่น | ❌ แยกออก |

---

## Step 4 — คำถามยอดฮิต (จับ Pain)

```python
# นับ keyword ในข้อความลูกค้า
buckets = {
    "ราคา/งบ":   ["ราคา","งบ","เท่าไหร่","กี่บาท","ล้าน"],
    "แบบบ้าน":    ["แบบ","ดีไซน์","กี่ห้อง","ชั้น"],
    "ระยะเวลา":   ["นานไหม","เสร็จ","กี่เดือน"],
    "ที่ดิน":     ["ที่ดิน","ไม่มีที่","หาที่"],
    "สินเชื่อ":   ["กู้","ผ่อน","ธนาคาร","สินเชื่อ"],
}
# สรุปเป็น % → รู้ว่าคนติดเรื่องอะไรมากสุด
```

### เอา insight ไปทำอะไร
- **ถามราคา 30%+** → ลองใส่ช่วงราคา/แพ็กเกจในแอป หรือตั้ง auto-reply บอกเริ่มต้น
- **ถามที่ดินเยอะ** → ทำคอนเทนต์ "ไม่มีที่ดินก็เริ่มได้" / จับ Persona ใหม่
- **คนทักแล้วเงียบ** → ปรับวิธีตอบ (ตอบเร็ว + ถามกลับ)

> **💡 คน comment ≠ คนซื้อ** — คนซื้อจริงมักทักเงียบๆ ใน Inbox

---

## Step 5 — Funnel รวม

```
เห็นแอด (Reach)      XX,XXX คน
   ↓ X.X%
ทักแชท               XX คน       CPR ฿XXX
   ↓ XX%
นัดคุย/ดูแบบ          XX นัด
   ↓ XX%
เซ็นสัญญา            X ดีล        (ทีมกรอกเอง — API ไม่รู้ยอดปิด)
```

> ยอดปิดการขายทีมต้องกรอกเอง (Facebook รู้แค่ถึงขั้น "ทัก")

---

## Step 6 — สรุปเดือน (Template ให้ทีม)

```
📅 สรุปแอดเดือน [มิ.ย. 2026] — [บ้านในฝัน]

💰 งบ: ฿XX,XXX | 💬 แชท: XX | 🎯 CPR: ฿XXX (เป้า <150)
📈 เทียบเดือนก่อน: CPR [ดีขึ้น/แย่ลง] XX%

🔥 Funnel: เห็น XX,XXX → ทัก XX → นัด XX → ปิด X

💡 ลูกค้าติดอะไรมากสุด:
1. [เรื่อง] XX%
2. [เรื่อง] XX%

✅ เดือนหน้าทำ:
- [ตัดสินใจใหญ่ เช่น เพิ่มงบ Persona คุณนุ่น / ทำคอนเทนต์เรื่องที่ดิน]
```

> **in-house ไม่ต้องทำ PPTX ส่งลูกค้า** — สรุปข้อความให้ทีมอ่านพอ
> จบแล้วอัปเดต baseline CPR/แชท ลง `BRAND_PROFILE.md` ข้อ 6

---

## Step 7 — ออกรายงานส่งหัวหน้า (PDF + PPTX + HTML)

> ใช้ **`6-report.md`** — generator `report/gen_report.py` ดึงตัวเลขเดือนนี้ + เติมบทวิเคราะห์ → ออก 3 รูปแบบ
> เลข funnel / questions / เลดจริง ที่ได้จาก Step 2–5 เอาไปเติมในรายงานได้เลย

```bash
cd report
python3 gen_report.py --period monthly --fetch     # ดึงเลขเดือนที่แล้ว
# Claude เติม exec/funnel/questions/goods/improves/next_plan ใน report_data.json
python3 gen_report.py --period monthly --render --out all
```
> ดูตัวอย่างก่อนได้: `python3 gen_report.py --period monthly --mock --out all`
> รายละเอียดครบใน `6-report.md`

**report ใช้ทำอะไร:** ส่งหัวหน้า · ขึ้นจอประชุม (PPTX) · แนบขอสินเชื่อ — เล่าจริง > เลขสวย

---

## ➡️ ต่อไปทำอะไร (เสนอให้นักเรียนเลือก — พิมพ์เลข)
```
✅ สรุปเดือน + inbox เสร็จ · ต่อไป?
  1. ออกรายงานส่งหัวหน้า PDF/PPTX/HTML → 6-report.md
  2. inbox เจอแชทผีเยอะ → เปิด/ปรับโหมดกรอง → GHOST_FILTER.md
  3. วางแผนเดือนหน้า (persona/งบใหม่) → 4-planning.md
  4. อัปเดต baseline + สิ่งที่เรียนรู้ลง BRAND_PROFILE.md ข้อ 6
```

---

*Module 5: สรุปเดือน — my-ads*
