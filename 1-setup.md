# Module 1 — สร้าง Campaign / Ad Set / Ad
> สร้างแอดผ่าน Meta Marketing API
> คู่กับสไลด์ P2 (Campaign→AdSet→Ad, Audience, Placement, CBO)

> ⚙️ โค้ดใช้ `api_get`/`api_post`/`ACCOUNT_ID`/`PAGE_ID`/`TOKEN_PAGE` จาก **SKILL.md** — อ่าน SKILL.md + โหลด .env ก่อนรัน

---

## 💡 ทำไมต้องรู้ 3 ชั้น (จากสไลด์)

```
Campaign  = ตั้งเป้าหมาย + งบรวม   (จะเอาอะไร? แชท/ยอดขาย/คนเห็น)
  └ Ad Set = ตั้งกลุ่มเป้าหมาย       (ยิงหาใคร? Persona + พื้นที่ + Interest)
      └ Ad  = ตัวโฆษณาจริง           (โชว์อะไร? รูป/วิดีโอ + ปุ่มทักแชท)
```

---

## ขั้นตอนมาตรฐาน (ทำตามลำดับ)

```
1. ดึงแคมเปญเดิม → กันสร้างซ้ำ
2. เช็ค targeting ด้วย delivery_estimate ก่อนสร้าง (มีคนพอมั้ย?)
3. สร้าง Campaign (PAUSED)
4. สร้าง Ad Set + targeting (PAUSED)
5. ดึงโพสต์จากเพจ → เลือกโพสต์ที่จะโปรโมท
6. สร้าง Ad Creative (ผูกโพสต์ + ปุ่มทักแชท)
7. สร้าง Ad (PAUSED)
8. ตรวจ Checklist → ให้หัวหน้าตรวจ → ค่อยเปิด
```

> ทุกอย่าง `status = PAUSED` — ไม่มีอะไรวิ่งกินเงินจนกว่าจะตรวจเสร็จ

---

## Step 1 — ดึงแคมเปญเดิม

```python
campaigns = api_get(f"{ACCOUNT_ID}/campaigns", {
    "fields": "id,name,status,objective,daily_budget",
    "limit": 50
})
# แคมเปญของเราตั้งชื่อขึ้นต้นด้วยชื่อแบรนด์ (ดู Naming ล่าง)
ours = [c for c in campaigns["data"] if c["name"].startswith("[บ้านในฝัน]")]
```

---

## Step 2 — เช็คก่อนสร้าง: มีคนพอมั้ย?

```python
targeting = { ... }  # ดู Step 4

result = api_get(f"{ACCOUNT_ID}/delivery_estimate", {
    "targeting_spec": json.dumps(targeting),
    "optimization_goal": "CONVERSATIONS",
})
mau = result["data"][0]["estimate_mau_lower_bound"]
# เกณฑ์: estimate_ready = True และ MAU > 100,000 → กลุ่มใหญ่พอ
```

> **💡 ทำไม:** กลุ่มเล็กเกิน (< 100k) = แอดวิ่งไม่ออก CPR แพง · กลุ่มใหญ่เกิน (ทั้งประเทศ) = ยิงมั่ว เปลืองงบ

---

## Step 3 — สร้าง Campaign (CBO)

```python
campaign = api_post(f"{ACCOUNT_ID}/campaigns", {
    "name": "[บ้านในฝัน] MOF : Chat 1",
    "objective": "OUTCOME_ENGAGEMENT",   # อยากได้แชท → ใช้อันนี้
    "status": "PAUSED",
    "daily_budget": 25000,               # สตางค์! 25000 = ฿250/วัน
    "bid_strategy": "LOWEST_COST_WITHOUT_CAP",
    "special_ad_categories": "[]",
})
CAMPAIGN_ID = campaign["id"]
```

**เลือก Objective ตามสิ่งที่อยากได้:**

| อยากได้ | Objective |
|---------|-----------|
| คนทักแชท (รับออกแบบบ้าน = อันนี้) | `OUTCOME_ENGAGEMENT` |
| คลิกไปเว็บ/Shopee | `OUTCOME_TRAFFIC` |
| ยอดขายออนไลน์ | `OUTCOME_SALES` |
| แค่คนเห็นเยอะๆ | `OUTCOME_AWARENESS` |

> **💡 CBO** = ใส่งบที่ Campaign แล้ว Facebook แจกงบให้ Ad Set ที่ทำดีเอง (สไลด์ S13)

---

## Step 4 — สร้าง Ad Set + Targeting

```python
targeting = {
    "age_min": 35,
    "age_max": 50,
    "geo_locations": {
        # ปักหมุดพื้นที่เสมอ — ห้ามยิงทั้งประเทศ
        "custom_locations": [
            {"latitude": 13.7563, "longitude": 100.5018, "radius": 30, "distance_unit": "kilometer"}
        ]
    },
    "publisher_platforms": ["facebook"],
    "facebook_positions": ["feed"],          # Feed only สำหรับแอดแชท
    "device_platforms": ["mobile"],
    "targeting_automation": {"advantage_audience": 0},   # ⚠️ ต้องมีเสมอ ไม่งั้น error
    "flexible_spec": [
        {"interests": [
            {"id": "6003693537583", "name": "อสังหาริมทรัพย์"},
            {"id": "6002986908368", "name": "บ้าน"},
        ]}
    ]
}

adset = api_post(f"{ACCOUNT_ID}/adsets", {
    "name": "คุณนุ่น - มีที่ดิน",          # ชื่อ Persona
    "campaign_id": CAMPAIGN_ID,
    "billing_event": "IMPRESSIONS",
    "optimization_goal": "CONVERSATIONS",
    "destination_type": "MESSENGER",
    "promoted_object": json.dumps({"page_id": PAGE_ID}),
    "targeting": json.dumps(targeting),
    "status": "PAUSED",
})
ADSET_ID = adset["id"]
```

> **💡 ปักหมุด + radius เสมอ** (สไลด์ S11) — ธุรกิจบ้านขายเฉพาะพื้นที่ ยิงไกลไป = คนทักแต่มาดูไม่ได้

### Placement (เลือกตามงาน)

| แบบ | publisher_platforms | facebook_positions | ใช้กับ |
|-----|--------------------|--------------------|-------|
| Feed อย่างเดียว | `["facebook"]` | `["feed"]` | แอดแชท (แนะนำ) |
| Feed + Story | `["facebook"]` | `["feed","story"]` | ทั่วไป |
| FB + IG | `["facebook","instagram"]` | feed+story | มี IG |

---

## Step 5 — ดึงโพสต์จากเพจ

```python
# แลก Page Token ก่อน (TOKEN_PAGE ใช้แลกอย่างเดียว)
with urllib.request.urlopen(
    f"{API}/{PAGE_ID}?fields=access_token,name&access_token={TOKEN_PAGE}"
) as r:
    PAGE_TOKEN = json.loads(r.read())["access_token"]

page_params = urllib.parse.urlencode({
    "fields": "id,message,created_time,full_picture", "limit": 10,
    "access_token": PAGE_TOKEN
})
with urllib.request.urlopen(f"{API}/{PAGE_ID}/posts?{page_params}") as r:
    posts = json.loads(r.read())["data"]
    # id รูปแบบ "PAGEID_POSTID"
```

---

## Step 6 — สร้าง Ad Creative

```python
creative = api_post(f"{ACCOUNT_ID}/adcreatives", {
    "name": "[บ้านในฝัน] คุณนุ่น - มีที่ดิน",
    "object_story_id": "PAGEID_POSTID",     # จาก Step 5
    "call_to_action": json.dumps({
        "type": "MESSAGE_PAGE",
        "value": {"app_destination": "MESSENGER"}
    }),
})
CREATIVE_ID = creative["id"]
```

> **💡 CTA = MESSAGE_PAGE** = ปุ่ม "ส่งข้อความ" → คนกดแล้วทักแชทเลย (มาตรฐานแอดแชท)
> บางโพสต์ไม่รองรับ CTA → error ให้ลองโพสต์อื่น

---

## Step 7 — สร้าง Ad

```python
ad = api_post(f"{ACCOUNT_ID}/ads", {
    "name": "คุณนุ่น - มีที่ดิน",           # ชื่อเดียวกับ Ad Set
    "adset_id": ADSET_ID,
    "creative": json.dumps({"creative_id": CREATIVE_ID}),
    "status": "PAUSED",
})
```

---

## ✅ Checklist ก่อนเปิดแอด (ให้หัวหน้าตรวจ)

- [ ] Ad Account มีวิธีจ่ายเงินแล้ว
- [ ] Post ID ถูก + โพสต์ยังอยู่
- [ ] Targeting: Interest + พื้นที่(ปักหมุด) + อายุ ครบ
- [ ] Placement ถูก (Feed สำหรับแอดแชท)
- [ ] ปุ่ม = ส่งข้อความ (MESSAGE_PAGE)
- [ ] งบถูก (สตางค์! ฿250 = 25000)
- [ ] ทุกชั้น status = PAUSED
- [ ] ชื่อถูก convention
- [ ] **หัวหน้ายืนยัน "เปิดได้"** ← ค่อยเปลี่ยนเป็น ACTIVE

---

## Naming Convention

```
Campaign: [ชื่อแบรนด์] {PHASE} : {OBJECTIVE} {N}
          เช่น [บ้านในฝัน] MOF : Chat 1
Ad Set:   ชื่อ Persona          เช่น คุณนุ่น - มีที่ดิน
Ad:       เหมือน Ad Set
```

---

## Error ที่เจอบ่อย

| Error | สาเหตุ | แก้ |
|-------|--------|-----|
| 100: Invalid targeting | ขาด `targeting_automation` | เพิ่ม `{"advantage_audience": 0}` |
| 1870199 | มี `location_types` ใน geo | ลบออก |
| 210: Invalid OAuth | ใช้ user token อ่านโพสต์ | แลก Page Token ก่อน (Step 5) |
| No payment method | ไม่มีบัตร | เพิ่มที่ Billing ใน Ads Manager |

---

*Module 1: สร้างแอด — my-ads*
