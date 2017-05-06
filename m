From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH net-next 1/5] dsa: add support for Microchip KSZ tail
 tagging
Date: Sat, 6 May 2017 00:35:04 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40A5C086@CHN-SV-EXMX02.mchp-main.com>
References: <9235D6609DB808459E95D78E17F2E43D40A5BFEC@CHN-SV-EXMX02.mchp-main.com>
 <e2858cf1-45ed-f661-6699-cb0c4d439a93@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
        <UNGLinuxDriver@microchip.com>
To: <f.fainelli@gmail.com>, <andrew@lunn.ch>,
        <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa1.microchip.iphmx.com ([68.232.147.91]:12680 "EHLO
        esa1.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751751AbdEFAfG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 5 May 2017 20:35:06 -0400
In-Reply-To: <e2858cf1-45ed-f661-6699-cb0c4d439a93@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiA+ICsJcGFkbGVuID0gMDsNCj4gPiArCWlmIChza2ItPmxlbiA8IDYwKQ0KPiA+ICsJCXBhZGxl
biA9IDYwIC0gc2tiLT5sZW47DQo+IA0KPiBDYW4geW91IHVzZSBFVEhfWkxFTiBpbnN0ZWFkIG9m
IDYwIHN1Y2ggdGhhdCBpdCBpcyBjbGVhciB0aGlzIGlzIHBhZGRpbmcNCj4gdG8gYSBtaW5pbXVt
IHBhY2tldCBzaXplIChtaW51cyBGQ1MpPw0KPiANCj4gPiArDQo+ID4gKwluc2tiID0gYWxsb2Nf
c2tiKE5FVF9JUF9BTElHTiArIHNrYi0+bGVuICsgcGFkbGVuICsgMiwNCj4gR0ZQX0FUT01JQyk7
DQo+IA0KPiBDYW4geW91IGFsc28gZGVmaW5lIHRoZSAiMiIgYXQgdGhlIGJlZ2lubmluZyBvZiB0
aGUgZmlsZSBhcyBiZWluZyBlLmc6DQo+IFRBR19LU1pfTEVOPw0KR290IGl0LiBXaWxsIHVwZGF0
ZS4NCg0KPiA+ICsJZHMgPSBkc3QtPmNwdV9zd2l0Y2g7DQo+ID4gKw0KPiA+ICsJaWYgKHNrYl9s
aW5lYXJpemUoc2tiKSkNCj4gPiArCQlyZXR1cm4gTlVMTDsNCj4gDQo+IElzIHRoYXQgcmVhbGx5
IG5lY2Vzc2FyeT8NCkkgZG9uJ3QgdGhpbmsgc28uIFdpbGwgY2hlY2sgaXQuDQoNCj4gPiArDQo+
ID4gKwl0YWcgPSBza2JfdGFpbF9wb2ludGVyKHNrYikgLSAxOw0KPiA+ICsNCj4gPiArCXNvdXJj
ZV9wb3J0ID0gdGFnWzBdICYgNzsNCj4gPiArCWlmIChzb3VyY2VfcG9ydCA+PSBkcy0+bnVtX3Bv
cnRzIHx8ICFkcy0NCj4gPnBvcnRzW3NvdXJjZV9wb3J0XS5uZXRkZXYpDQo+ID4gKwkJcmV0dXJu
IE5VTEw7DQo+ID4gKw0KPiA+ICsJcHNrYl90cmltX3Jjc3VtKHNrYiwgc2tiLT5sZW4gLSAxKTsN
Cj4gDQo+IEh1bW0sIHNvIHdlIGFyZSBzdGlsbCBrZWVwaW5nIHRhZ1sxXSBhdCB0aGUgZW5kIG9m
IHRoZSBmcmFtZT8NCkl0IHRhZ3MgMiBieXRlcyBmb3IgaW5ncmVzcyAoa3N6X3htaXQpIGFuZCAx
IGJ5dGUgZm9yIGVncmVzcyAoa3N6X3JjdikuDQpQdXQgY29tbWVudCBhdCB0aGUgYmVnaW4gb2Yg
bmV0L2RzYS90YWdfa3N6LmMuDQoNClRoYW5rcy4NCldvb2p1bmcNCg==
