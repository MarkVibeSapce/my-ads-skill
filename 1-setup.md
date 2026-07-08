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

## ⚠️ ก่อนเริ่ม (แคมเปญแบบแชท) — ถามผู้ใช้ก่อน

ถ้าแคมเปญนี้ objective = แชท (`OUTCOME_ENGAGEMENT` + `CONVERSATIONS`) **ถามก่อนสร้าง:**

> "แคมเปญนี้เป็นแบบทักแชท — **เปิดโหมดกรองแชทผีมั้ย?**
> เปิด = แชทน้อยลงนิดแต่คุณภาพสูงขึ้น (คนทักจริงจัง ไม่กดมั่ว)"

**เปิด** → เปิด `GHOST_FILTER.md` แล้ว apply 6 ข้อระหว่างสร้าง (Placement/Advantage/Ice Breaker/Interest/Geo/Exclude)
· ค่า default ใน Step 4 ตัด Audience Network + `advantage_audience:0` ให้อยู่แล้ว
เช็ค `BRAND_PROFILE.md` ข้อ 3 ว่าเคยตอบไว้มั้ย → ถ้ามีแล้ว ยืนยันสั้นๆ พอ

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

## Step 6.5 — เขียน copy ไทยไม่ให้เพี้ยน (สำคัญ — เจอบ่อย)

> อาการ: Claude เขียนแอดภาษาไทย แต่ในแอดจริงกลายเป็น **ต่างดาว** (`à¸šà¹‰à¸²à¸™` หรือ `บ`)
> = ปัญหา **encoding** ตอนส่งข้อความ — กันได้ 3 ชั้น

### ชั้น 1 — เขียน copy ลงไฟล์ UTF-8 (ห้ามพิมพ์ไทยยาว inline ใน command)
```python
# เขียน copy ลงไฟล์ก่อน — encoding="utf-8" เสมอ
with open("copy.txt", "w", encoding="utf-8") as f:
    f.write("มีที่ดินแล้ว? ออกแบบบ้านในฝันฟรี เริ่มจากงบที่คุณมี 🏡")

# อ่านกลับด้วย encoding="utf-8" — อย่าพึ่ง default ของเครื่อง
message = open("copy.txt", encoding="utf-8").read()
```

### ชั้น 2 — สร้างโพสต์ใหม่ด้วยข้อความจากไฟล์ (ต้องใช้ PAGE_TOKEN)
```python
# โพสต์ลงเพจต้องใช้ Page Token (แลกไว้แล้วใน Step 5) — urlencode เข้ารหัส UTF-8 ให้ถูกเอง
data = urllib.parse.urlencode({
    "message": message, "published": "true", "access_token": PAGE_TOKEN
}).encode()
with urllib.request.urlopen(f"{API}/{PAGE_ID}/feed", data) as r:
    post = json.loads(r.read())   # post["id"] = "PAGEID_POSTID" → เอาไป Step 6
```
> `urlencode` เข้ารหัส UTF-8 ถูกอยู่แล้ว — ปัญหามักเกิดตอน **พิมพ์ไทยยาวๆ ใส่ตรงๆ ใน shell/`-c`** ที่ locale ไม่ใช่ UTF-8 → เลี่ยงด้วยชั้น 1 (เขียนลงไฟล์)

### ชั้น 3 — อ่าน message กลับมาเช็ค (safety net — จับได้ทุกกรณี)
```python
# ดึงข้อความที่ Facebook เก็บจริงกลับมาดู ก่อนเปิดแอด
check = api_get(f"{post['id']}", {"fields": "message"}, token=PAGE_TOKEN)
print("copy ที่เก็บจริง:", check.get("message"))
# ✅ อ่านภาษาไทยออก = OK   ❌ เห็น à¸/\u เพี้ยน = แก้ก่อน ห้ามเปิดแอด
```

> **กฎ:** ถ้าอ่าน message กลับมาแล้วไทยเพี้ยน → **ห้ามเปลี่ยนเป็น ACTIVE** จนกว่าจะแก้ให้อ่านออก

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
- [ ] **อ่าน message/copy กลับมา ภาษาไทยไม่เพี้ยน** (Step 6.5 ชั้น 3)
- [ ] (ถ้าแคมเปญแชท) ถามเรื่อง **กรองแชทผี** แล้ว + apply ตามที่ตกลง (GHOST_FILTER.md)
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
| ไทยเพี้ยน/ต่างดาว (`à¸`) | encoding ผิดตอนส่ง copy | เขียน copy ลงไฟล์ UTF-8 + readback (Step 6.5) |

---

## ➡️ ต่อไปทำอะไร (เสนอให้นักเรียนเลือก — พิมพ์เลข)
```
✅ สร้างแอดเสร็จ (PAUSED ไว้แล้ว ยังไม่วิ่ง) · ต่อไป?
  1. ตรวจ checklist + ให้หัวหน้ายืนยัน "เปิดได้" → เปลี่ยนเป็น ACTIVE
  2. สร้าง ad set อีกกลุ่ม (persona อื่นใน BRAND_PROFILE)
  3. (แคมเปญแชท) เปิดโหมดกรองแชทผี → GHOST_FILTER.md
  4. ตั้งใจมาดูผลอีก 3 วัน → 2-weekly.md
```

---

*Module 1: สร้างแอด — my-ads*
