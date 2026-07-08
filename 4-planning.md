# Module 4 — วางแผนแอด
> Persona → Interest → พื้นที่ → โครงสร้าง Campaign
> คู่กับสไลด์ P3 (Persona Workshop) + P4 (Campaign Blueprint)
> ทำก่อน `1-setup.md` เสมอ (มีแผนก่อน ค่อยสร้าง)

> ⚙️ โค้ดใช้ `api_get`/`ACCOUNT_ID`/`TOKEN_ADS` จาก **SKILL.md** — อ่าน SKILL.md + โหลด .env ก่อนรัน

---

## ขั้นตอน

```
1. กำหนดเป้าหมาย (อยากได้แชท/ยอด/คนเห็น) + งบ
2. ทำ Persona 2–4 กลุ่ม (จาก workshop คอร์ส)
3. หา Interest ให้แต่ละ Persona
4. กำหนดพื้นที่ (ปักหมุด)
5. วางโครงสร้าง Campaign → Ad Set
6. เช็คด้วย delivery_estimate
7. บันทึกแผนใน BRAND_PROFILE + สร้างจริงใน 1-setup.md
```

---

## Step 1 — เป้าหมาย + Funnel

| ธุรกิจแบบเรา | Funnel | Objective |
|-------------|--------|-----------|
| รับออกแบบ/สร้างบ้าน (อยากได้แชท) | MOF → BOF | OUTCOME_ENGAGEMENT |
| ขายของออนไลน์ | TOF+MOF+BOF | AWARENESS/TRAFFIC/SALES |
| แค่ให้คนรู้จัก | TOF | OUTCOME_AWARENESS |

> **MOF** = คนเริ่มสนใจแต่ยังไม่ตัดสินใจ → ชวนทักแชทมาคุย (เหมาะธุรกิจบ้าน ราคาสูง ตัดสินใจนาน)

---

## Step 2 — ทำ Persona (จาก Workshop)

ใช้ใบงาน Persona จากคอร์ส · ทำ 2–4 กลุ่ม แยกตาม:
- **อาชีพ/รายได้** — เจ้าของกิจการ / พนักงาน / ข้าราชการ
- **ไลฟ์สไตล์** — มีที่ดินแล้ว / คู่แต่งงานใหม่ / ครอบครัวขยาย
- **พื้นที่** — คนในย่านนั้น

### Template (กรอกลง BRAND_PROFILE ข้อ 4)

```
Persona: [ชื่อเล่นให้จำง่าย เช่น "คุณนุ่น"]
อายุ: XX–XX
อาชีพ/รายได้: [...]
พื้นที่: [...]
Pain: [ทำไมเขาถึงอยากได้บ้าน/ติดอะไร]
Hook: [ประโยคเปิดแอดที่โดนใจกลุ่มนี้]
Interest: [รายการ — หาใน Step 3]
```

> ดูตัวอย่างเต็ม "คุณนุ่น" + "คุณต้น" ใน BRAND_PROFILE.md

---

## Step 3 — หา Interest IDs

```python
def search_interest(keyword):
    params = urllib.parse.urlencode({
        "type": "adinterest", "q": keyword, "limit": 5,
        "locale": "th_TH", "access_token": TOKEN_ADS
    })
    with urllib.request.urlopen(f"{API}/search?{params}") as r:
        return json.loads(r.read()).get("data", [])

for it in search_interest("อสังหาริมทรัพย์"):
    print(it["id"], it["name"], it.get("audience_size_lower_bound"))
```

### เคล็ดลับค้นหา

| คำไทยไม่เจอ | ลองภาษาอังกฤษ |
|------------|--------------|
| ราชการ/ตำรวจ | `government`, `civil servant` |
| ช่างซ่อม/รับเหมา | `contractor`, `renovation` |
| เฟอร์นิเจอร์/ตกแต่ง | `interior design`, `home decor` |

> ⚠️ ตรวจว่า interest ที่เจอ **เกี่ยวจริง** — หลายคำดึงผลมั่ว

### Interest บ้าน/อสังหา (ใช้ได้เลย)

| ID | ชื่อ |
|----|------|
| `6003693537583` | อสังหาริมทรัพย์ |
| `6002986908368` | บ้าน |
| `6003188857305` | สินเชื่อเพื่อที่อยู่อาศัย |
| `6003446239080` | การลงทุนด้านอสังหาริมทรัพย์ |
| `6003476182657` | ครอบครัว |

> เจอ interest ดีๆ เพิ่ม → จดใน BRAND_PROFILE ข้อ 5 ไว้ใช้ซ้ำ

---

## Step 4 — พื้นที่ (ปักหมุดเสมอ)

```python
# พื้นที่ที่ไม่มีในฐาน Facebook → ใช้ปักหมุด lat/long + radius
"geo_locations": {
    "custom_locations": [
        {"latitude": 13.7563, "longitude": 100.5018, "radius": 30, "distance_unit": "kilometer"}
    ]
}
```

> **💡 default radius 30 กม.** รอบพื้นที่บริการ (ปรับได้) · ธุรกิจบ้าน = ห้ามยิงทั้งประเทศเด็ดขาด
> หาพิกัด: ค้นชื่อสถานที่ใน Google Maps → คลิกขวา → copy lat,long

---

## Step 5 — โครงสร้าง Campaign

```
[บ้านในฝัน] MOF : Chat 1          งบ CBO ฿250/วัน
├── Ad Set: คุณนุ่น - มีที่ดิน     (35–50 | กทม.+ปริมณฑล | อสังหา, บ้าน)
└── Ad Set: คุณต้น - คู่แต่งใหม่   (28–38 | กทม.+ปริมณฑล | บ้าน, ครอบครัว)

[บ้านในฝัน] MOF : Chat 2          งบ CBO ฿250/วัน   (ทดสอบมุมใหม่)
└── Ad Set: ...
```

> ไม่เกิน 3–5 Ad Set ต่อ Campaign — เยอะไป CBO แจกงบไม่ทั่ว

---

## Step 6 — เช็คก่อนจบ

```python
result = api_get(f"{ACCOUNT_ID}/delivery_estimate", {
    "targeting_spec": json.dumps(targeting),
    "optimization_goal": "CONVERSATIONS"
})
# ready = True และ MAU > 100,000 → ผ่าน
```

---

## Step 7 — บันทึกแผน

- [ ] เขียน Persona ลง `BRAND_PROFILE.md` ข้อ 4
- [ ] จด Interest ที่เจอลง ข้อ 5
- [ ] ทีมเห็นชอบแผน → ไป `1-setup.md` สร้างจริง (PAUSED)

> **หมายเหตุ:** in-house ไม่ต้องทำสไลด์เสนอลูกค้า — แผนอยู่ใน BRAND_PROFILE พอ ทีมอ่านเข้าใจตรงกัน

---

## ➡️ ต่อไปทำอะไร (เสนอให้นักเรียนเลือก — พิมพ์เลข)
```
✅ วางแผน + ได้ persona/interest แล้ว · ต่อไป?
  1. สร้างแคมเปญตามแผนนี้ (PAUSED) → 1-setup.md
  2. บันทึก persona + interest IDs ลง BRAND_PROFILE.md ข้อ 4–5 (ใช้ซ้ำได้)
  3. (แคมเปญแชท) เตรียมเปิดโหมดกรองแชทผี → GHOST_FILTER.md
```

---

*Module 4: วางแผนแอด — my-ads*
