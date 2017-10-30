From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH] lan78xx: Use common error handling code in
 lan78xx_phy_init()
Date: Mon, 30 Oct 2017 14:32:59 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40B9D816@CHN-SV-EXMX02.mchp-main.com>
References: <1aa46505-686c-8e92-78a8-b2a562ccbb9d@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: <linux-kernel@vger.kernel.org>, <kernel-janitors@vger.kernel.org>
To: <elfring@users.sourceforge.net>, <netdev@vger.kernel.org>,
        <linux-usb@vger.kernel.org>, <UNGLinuxDriver@microchip.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <1aa46505-686c-8e92-78a8-b2a562ccbb9d@users.sourceforge.net>
Content-Language: en-US
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PiBGcm9tOiBTRiBNYXJrdXMgRWxmcmluZyBbbWFpbHRvOmVsZnJpbmdAdXNlcnMuc291cmNlZm9y
Z2UubmV0XQ0KPiBTZW50OiBTYXR1cmRheSwgT2N0b2JlciAyOCwgMjAxNyA0OjU3IFBNDQo+IFRv
OiBuZXRkZXZAdmdlci5rZXJuZWwub3JnOyBsaW51eC11c2JAdmdlci5rZXJuZWwub3JnOyBVTkdM
aW51eERyaXZlcjsNCj4gV29vanVuZyBIdWggLSBDMjE2OTkNCj4gQ2M6IExLTUw7IGtlcm5lbC1q
YW5pdG9yc0B2Z2VyLmtlcm5lbC5vcmcNCj4gU3ViamVjdDogW1BBVENIXSBsYW43OHh4OiBVc2Ug
Y29tbW9uIGVycm9yIGhhbmRsaW5nIGNvZGUgaW4NCj4gbGFuNzh4eF9waHlfaW5pdCgpDQo+IA0K
PiBGcm9tOiBNYXJrdXMgRWxmcmluZyA8ZWxmcmluZ0B1c2Vycy5zb3VyY2Vmb3JnZS5uZXQ+DQo+
IERhdGU6IFNhdCwgMjggT2N0IDIwMTcgMjI6NDI6NTIgKzAyMDANCj4gDQo+ICogQWRkIGEganVt
cCB0YXJnZXQgc28gdGhhdCBhIHNwZWNpZmljIGVycm9yIG1lc3NhZ2UgaXMgc3RvcmVkIG9ubHkg
b25jZQ0KPiAgIGF0IHRoZSBlbmQgb2YgdGhpcyBmdW5jdGlvbiBpbXBsZW1lbnRhdGlvbi4NCj4g
DQo+ICogUmVwbGFjZSB0d28gY2FsbHMgb2YgdGhlIGZ1bmN0aW9uICJuZXRkZXZfZXJyIiBieSBn
b3RvIHN0YXRlbWVudHMuDQo+IA0KPiAqIEFkanVzdCB0d28gY29uZGl0aW9uIGNoZWNrcy4NCj4g
DQo+IFRoaXMgaXNzdWUgd2FzIGRldGVjdGVkIGJ5IHVzaW5nIHRoZSBDb2NjaW5lbGxlIHNvZnR3
YXJlLg0KPiANCj4gU2lnbmVkLW9mZi1ieTogTWFya3VzIEVsZnJpbmcgPGVsZnJpbmdAdXNlcnMu
c291cmNlZm9yZ2UubmV0Pg0KPiAtLS0NCg0KUmV2aWV3ZWQtYnk6IFdvb2p1bmcgSHVoIDxXb29q
dW5nLkh1aEBtaWNyb2NoaXAuY29tPg0K
