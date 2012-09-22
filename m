From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1] net: use a per task frag allocator
Date: Sat, 22 Sep 2012 15:52:55 -0400 (EDT)
Message-ID: <20120922.155255.396667016733201083.davem@davemloft.net>
References: <1348239433.2669.522.camel@edumazet-glaptop>
	<CAGK4HS98RG78Auvaai3Ny6zz5c_hccO-ShD3GuT=moRRm4+RUA@mail.gmail.com>
	<1348261871.2669.962.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: subramanian.vijay@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, bhutchings@solarflare.com,
	alexander.h.duyck@intel.com
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1348261871.2669.962.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogRXJpYyBEdW1hemV0IDxlcmljLmR1bWF6ZXRAZ21haWwuY29tPg0KRGF0ZTogRnJpLCAy
MSBTZXAgMjAxMiAyMzoxMToxMSArMDIwMA0KDQo+IE9uIEZyaSwgMjAxMi0wOS0yMSBhdCAxMzoy
NyAtMDcwMCwgVmlqYXkgU3VicmFtYW5pYW4gd3JvdGU6DQo+PiBJIGdldCB0aGUgZm9sbG93aW5n
IGNvbXBpbGUgZXJyb3Igd2l0aCB0aGUgbmV3ZXIgdmVyc2lvbiBvZiB0aGUgcGF0Y2gNCj4+IA0K
Pj4gbmV0L3NjaGVkL2VtX21ldGEuYzogSW4gZnVuY3Rpb24goW1ldGFfaW50X3NrX3NlbmRtc2df
b2ZmojoNCj4+IG5ldC9zY2hlZC9lbV9tZXRhLmM6NDY0OiBlcnJvcjogoXN0cnVjdCBzb2NroiBo
YXMgbm8gbWVtYmVyIG5hbWVkDQo+PiChc2tfc25kbXNnX29mZqINCj4+IG1ha2VbMV06ICoqKiBb
bmV0L3NjaGVkL2VtX21ldGEub10gRXJyb3IgMQ0KPj4gbWFrZTogKioqIFtuZXQvc2NoZWQvZW1f
bWV0YS5vXSBFcnJvciAyDQo+PiANCj4+IA0KPj4gDQo+PiBWaWpheQ0KPiANCj4gT2ggd2VsbCwg
SSB3b25kZXIgd2hhdCdzIHRoZSBleHBlY3RlZCB1c2Ugb2YgdGhpcyBjcmFwLi4uDQo+IA0KPiBU
aGFua3MsIEknbGwgZml4IHRoaXMgb24gdjMgIQ0KDQpTbyBtYW55IGFzcGVjdHMgb2YgdGhlIG1l
dGEgbWF0Y2ggYXJlIGFuIGV4dHJlbWUgYnVyZG9uIG9uIGRldmVsb3BtZW50DQpiZWNhdXNlIHRo
ZSBrZXlzIGl0IGFsbG93cyB1bm5lY2Vzc2FyaWx5IGV4cG9zZXMgaW50ZXJuYWxzIG9mIG91cg0K
aW1wbGVtZW50YXRpb24uDQoNCldobyByZWFsbHkgdXNlcyBpdD8gIE1heWJlIHdlIGNhbiBzY2hl
ZHVsZSBpdCBmb3IgcmVtb3ZhbC4NCg==
