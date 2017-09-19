From: <Tristram.Ha@microchip.com>
Subject: RE: [PATCH RFC 6/6] Modify tag_ksz.c to support other KSZ switch
 drivers
Date: Tue, 19 Sep 2017 00:45:41 +0000
Message-ID: <93AF473E2DA327428DE3D46B72B1E9FD41124E47@CHN-SV-EXMX02.mchp-main.com>
References: <93AF473E2DA327428DE3D46B72B1E9FD41121901@CHN-SV-EXMX02.mchp-main.com>
 <93AF473E2DA327428DE3D46B72B1E9FD41121A22@CHN-SV-EXMX02.mchp-main.com>
 <20170907214834.GT11248@lunn.ch>
 <93AF473E2DA327428DE3D46B72B1E9FD41124D2E@CHN-SV-EXMX02.mchp-main.com>
 <20170918195708.GE15606@lunn.ch>
 <93AF473E2DA327428DE3D46B72B1E9FD41124D7C@CHN-SV-EXMX02.mchp-main.com>
 <20170918225142.GC29615@lunn.ch>
 <93AF473E2DA327428DE3D46B72B1E9FD41124E0C@CHN-SV-EXMX02.mchp-main.com>
 <c812edb6-9a8d-e8de-a288-3c2030b72bbd@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: <muvarov@gmail.com>, <pavel@ucw.cz>,
        <nathan.leigh.conrad@gmail.com>,
        <vivien.didelot@savoirfairelinux.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <Woojung.Huh@microchip.com>,
        <andrew@lunn.ch>
To: <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <c812edb6-9a8d-e8de-a288-3c2030b72bbd@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PiBJIGFtIG5vdCByZWFsbHkgc3VyZSB3aHkgdGhpcyBpcyBzdWNoIGEgY29uY2VybiBmb3IgeW91
IHNvIHNvb24gd2hlbg0KPiB5b3VyIGRyaXZlciBpcyBub3QgZXZlbiBpbmNsdWRlZCB5ZXQuIFlv
dSBzaG91bGQgcmVhbGx5IGFpbSBmb3IgYmFieQ0KPiBzdGVwcyBoZXJlOiBnZXQgdGhlIGJhc2lj
IGRyaXZlcihzKSBpbmNsdWRlZCwgd2l0aCBhIGxpbWl0ZWQgc2V0IG9mDQo+IGZlYXR1cmVzLCBh
bmQgZ3JhZHVhbGx5IGFkZCBtb3JlIGZlYXR1cmVzIHRvIHRoZSBkcml2ZXIuIFdoZW4NCj4gZndk
X29mZmxvYWRfbWFyayBhbmQgUlNUUCBiZWNvbWUgYSByZWFsIHByb2JsZW0sIHdlIGNhbiBtb3N0
DQo+IGRlZmluaXRpdmVseSBmaW5kIGEgd2F5IHRvIGZpeCB0aG9zZSBpbiBEU0EgYW5kIGRlcGVu
ZGluZyBkcml2ZXJzLg0KDQpJIHdhcyB1bmRlciB0aGUgaW1wcmVzc2lvbiB0aGF0IHRoZXJlIGlz
IGEgbmV3IHB1c2ggb2YgdGhpcyBuZXcgc3dpdGNoZGV2DQptb2RlbCBhbmQgc28gdGhlIERTQSBt
b2RlbCB3YXMgb3ZlcmhhdWxlZCB0byBzdXBwb3J0IHRoYXQuDQoNClRoZSBLU1o5NDc3IGRyaXZl
ciBpcyBhbHJlYWR5IGluIHRoZSBrZXJuZWwsIGFuZCBpdHMgcmVnaXN0ZXIgYWNjZXNzIGlzIGFj
dHVhbGx5DQptdWNoIGRpZmZlcmVudCBmcm9tIHRoZSBvdGhlciBvbGRlciBzd2l0Y2hlcy4gIFRo
ZXJlIGFyZSBub3QgbXVjaCBjb21tb24NCmNvZGUgdG8gYmUgcmV1c2VkLiAgSSBhbHdheXMga25v
dyB0aGlzIHRhaWwgdGFnIGhhbmRsaW5nIGlzIHRoZSBzdGlja2luZyBwb2ludC4NCkkgd2lsbCBz
dWJtaXQgYSBtdWNoIHNpbXBsaWZpZWQgZHJpdmVyIGFuZCB3YWl0IGZvciBzd2l0Y2ggYWNjZXNz
IGluIHRoZSBmdXR1cmUuDQo=
