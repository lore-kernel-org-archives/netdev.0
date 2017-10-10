From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH v2 net-next 1/2] net: dsa: lan9303: Move tag setup to
 new lan9303_setup_tagging
Date: Tue, 10 Oct 2017 15:51:14 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40B48CC6@CHN-SV-EXMX02.mchp-main.com>
References: <20171010124953.386-1-privat@egil-hjelmeland.no>
 <20171010124953.386-2-privat@egil-hjelmeland.no>
 <9235D6609DB808459E95D78E17F2E43D40B48C3D@CHN-SV-EXMX02.mchp-main.com>
 <2d03fb99-fd1c-9a0b-3274-eda605c3eb2d@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
To: <privat@egil-hjelmeland.no>, <andrew@lunn.ch>,
        <vivien.didelot@savoirfairelinux.com>, <f.fainelli@gmail.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2d03fb99-fd1c-9a0b-3274-eda605c3eb2d@egil-hjelmeland.no>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PiA+IFNwZWNpZmljIHJlYXNvbiB0byB1c2UgdmFsIHRoZW4gdXNpbmcNCj4gTEFOOTMwM19CTV9F
R1JTU19QT1JUX1RZUEVfU1BFQ0lBTF9UQUdfUE9SVDANCj4gPiBsaWtlIHByZXZpb3VzIGxpbmU/
DQo+ID4NCj4gU3BlY2lmaWMgcmVhc29uIHdhcyB0byBwbGVhc2UgYSByZXZpZXdlciB0aGF0IGRp
ZCBub3QgbGlrZSBteQ0KPiBpbmRlbnRpbmcgaW4gZmlyc3QgdmVyc2lvbi4gSSBkaWQgbm90IGFn
cmVlIHdpdGggaGltLCBidXQgc2luY2UNCj4gbm9ib2R5IGVsc2Ugc3Bva2UgdXAsIEkgY2hhbmdl
ZCB0aGUgY29kZS4NCkdvdCBpdC4gTWlzc2VkIHByZXZpb3VzIHBhdGNoL2NvbW1lbnQuDQoNCj4g
Pj4gQEAgLTY0NCw2ICs2NDgsMTAgQEAgc3RhdGljIGludCBsYW45MzAzX3NldHVwKHN0cnVjdCBk
c2Ffc3dpdGNoICpkcykNCj4gPj4gICAJCXJldHVybiAtRUlOVkFMOw0KPiA+PiAgIAl9DQo+ID4+
DQo+ID4+ICsJcmV0ID0gbGFuOTMwM19zZXR1cF90YWdnaW5nKGNoaXApOw0KPiA+PiArCWlmIChy
ZXQpDQo+ID4+ICsJCWRldl9lcnIoY2hpcC0+ZGV2LCAiZmFpbGVkIHRvIHNldHVwIHBvcnQgdGFn
Z2luZyAlZFxuIiwgcmV0KTsNCj4gPj4gKw0KPiA+IFN0aWxsIG1vdmUgb24gd2hlbiBlcnJvciBo
YXBwZW5zPw0KPiA+DQo+IEdvb2QgcXVlc3Rpb24uIEkganVzdCBmb2xsb3dlZCB0aGUgcGF0dGVy
biBmcm9tIHRoZSBvcmlnaW5hbCBmdW5jdGlvbiwNCj4gd2hpY2ggd2FzIG5vdCBtYWRlIGJ5IG1l
LiBBY3R1YWxseSBJIGRpZCBvbmNlIHJlZmxlY3Qgb24gd2hldGhlciB0aGlzDQo+IHdhcyB0aGUg
Y29ycmVjdCB3YXkuIFBlcmhhcHMgaXQgY291bGQgYmUgYXJndWVkIHRoYXQgaXQgaXMgYmV0dGVy
IHRvDQo+IGFsbG93IHRoZSBkZXZpY2UgdG8gY29tZSB1cCwgc28gdGhlIHByb2JsZW0gY2FuIGJl
IGludmVzdGlnYXRlZD8NCk1heWJlIGRlcGVuZHMgb24gc2V2ZXJpdHkgb2Ygc2V0dGluZz8NCkJU
VywgbGFuOTMwM19zZXR1cCgpIHN0aWxsIHJldHVybnMgWkVSTyBhdCB0aGUgZW5kPw0KDQpUaGFu
a3MuDQpXb29qdW5nDQo=
