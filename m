From: Chris Brandt <Chris.Brandt@renesas.com>
Subject: RE: [PATCH v2] sh_eth: remove unchecked interrupts
Date: Thu, 1 Dec 2016 18:53:22 +0000
Message-ID: <SG2PR06MB1165C7D7B7DFBAC4B5BAB09A8A8F0@SG2PR06MB1165.apcprd06.prod.outlook.com>
References: <20161201140642.28583-1-chris.brandt@renesas.com>
 <CAMuHMdU80M2qcK74YgPC8SZ20tNcKrZhj7MXo_Ok=6m4Aa0=-w@mail.gmail.com>
 <25b92de0-806b-342b-7556-06b96b948b2c@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: David Miller <davem@davemloft.net>,
        Simon Horman <horms+renesas@verge.net.au>,
        Geert Uytterhoeven <geert+renesas@glider.be>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <25b92de0-806b-342b-7556-06b96b948b2c@cogentembedded.com>
Content-Language: en-US
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

SGkgR2VlcnQsDQoNCk9uIDEyLzEvMjAxNiwgU2VyZ2VpIFNodHlseW92IHdyb3RlOg0KPiANCj4g
T24gMTIvMDEvMjAxNiAwNTo0MiBQTSwgR2VlcnQgVXl0dGVyaG9ldmVuIHdyb3RlOg0KPiANCj4g
Pj4gLS0tIGEvZHJpdmVycy9uZXQvZXRoZXJuZXQvcmVuZXNhcy9zaF9ldGguYw0KPiA+PiArKysg
Yi9kcml2ZXJzL25ldC9ldGhlcm5ldC9yZW5lc2FzL3NoX2V0aC5jDQo+ID4+IEBAIC01MTgsNyAr
NTE4LDcgQEAgc3RhdGljIHN0cnVjdCBzaF9ldGhfY3B1X2RhdGEgcjdzNzIxMDBfZGF0YSA9IHsN
Cj4gPj4NCj4gPj4gICAgICAgICAuZWNzcl92YWx1ZSAgICAgPSBFQ1NSX0lDRCwNCj4gPj4gICAg
ICAgICAuZWNzaXByX3ZhbHVlICAgPSBFQ1NJUFJfSUNESVAsDQo+ID4+IC0gICAgICAgLmVlc2lw
cl92YWx1ZSAgID0gMHhmZjdmMDA5ZiwNCj4gPj4gKyAgICAgICAuZWVzaXByX3ZhbHVlICAgPSAw
eGU3N2YwMDlmLA0KPiA+DQo+ID4gQ29tbWVudCBub3QgZGlyZWN0bHkgcmVsYXRlZCB0byB0aGUg
bWVyaXRzIG9mIHRoaXMgcGF0Y2g6IHRoZSBFRVNJUFINCj4gPiBiaXQgZGVmaW5pdGlvbnMgc2Vl
bSB0byBiZSBpZGVudGljYWwgdG8gdGhvc2UgZm9yIEVFU1IsIHNvIHdlIGNhbiBnZXQNCj4gPiBy
aWQgb2YgdGhlIGhhcmRjb2RlZCB2YWx1ZXMgaGVyZT8NCj4gDQo+ICAgICBEbyB5b3UgbWVhbiB1
c2luZyB0aGUgQGRlZmluZSdzPyBXZSBoYXZlIEVFU0lQUiBiaXRzIGFsc28gZGVjbGFyZWQsDQo+
IHNlZSBlbnVtIERNQUNfSU1fQklULA0KDQoNCklzIHlvdXIgaWRlYSB0byBnZXQgcmlkIG9mIC5l
ZXNpcHJfdmFsdWUgZm9yIGRldmljZXMgdGhhdCBoYXZlIHZhbHVlcw0KdGhhdCBhcmUgdGhlIHNh
bWUgYXMgLmVlc3JfZXJyX2NoZWNrPw0KDQoNCkZvciBleGFtcGxlIGluIHNoX2V0aF9kZXZfaW5p
dCgpOg0KDQoJc2hfZXRoX21vZGlmeShuZGV2LCBFRVNSLCAwLCAwKTsNCgltZHAtPmlycV9lbmFi
bGVkID0gdHJ1ZTsNCi0Jc2hfZXRoX3dyaXRlKG5kZXYsIG1kcC0+Y2QtPmVlc2lwcl92YWx1ZSwg
RUVTSVBSKTsNCisJaWYgKG1kcC0+Y2QtPmVlc2lwcl92YWx1ZSkNCisJCXNoX2V0aF93cml0ZShu
ZGV2LCBtZHAtPmNkLT5lZXNpcHJfdmFsdWUsIEVFU0lQUik7DQorCWVsc2UNCisJCXNoX2V0aF93
cml0ZShuZGV2LCBtZHAtPmNkLT5lZXNyX2Vycl9jaGVjaywgRUVTSVBSKTsNCg0KDQpDaHJpcw0K
DQo=
