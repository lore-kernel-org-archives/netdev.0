From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [RFC] csum experts, csum_replace2() is too expensive
Date: Fri, 21 Mar 2014 14:14:23 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6E557E@AcuExch.aculab.com>
References: <1395341341.9114.93.camel@edumazet-glaptop2.roam.corp.google.com>
	 <87a9cknwk4.fsf@tassilo.jf.intel.com>
 <1395406250.9114.142.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Patrick McHardy <kaber@trash.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"H.K. Jerry Chu" <hkchu@google.com>,
	"Michael Dalton" <mwdalton@google.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>,
	Andi Kleen <andi@firstfloor.org>,
	"H. Peter Anvin" <hpa@zytor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1395406250.9114.142.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogRXJpYyBEdW1hemV0DQo+IE9uIFRodSwgMjAxNC0wMy0yMCBhdCAxODo1NiAtMDcwMCwg
QW5kaSBLbGVlbiB3cm90ZToNCj4gPiBFcmljIER1bWF6ZXQgPGVyaWMuZHVtYXpldEBnbWFpbC5j
b20+IHdyaXRlczoNCj4gPiA+DQo+ID4gPiBJIHNhdyBjc3VtX3BhcnRpYWwoKSBjb25zdW1pbmcg
MSUgb2YgY3B1IGN5Y2xlcyBpbiBhIEdSTyB3b3JrbG9hZCwgdGhhdA0KPiA+ID4gaXMgaW5zYW5l
Li4uDQo+ID4NCj4gPg0KPiA+IENvdWxkbid0IGl0IGp1c3QgYmUgdGhlIGNhY2hlIG1pc3M/DQo+
IA0KPiBPciB0aGUgZmFjdCB0aGF0IHdlIG1peCAxNiBiaXQgc3RvcmVzIGFuZCAzMmJpdCBsb2Fk
cyA/DQo+IA0KPiBCVFcsIGFueSBpZGVhIHdoeSBpcF9mYXN0X2NzdW0oKSBvbiB4ODYgY29udGFp
bnMgYSAibWVtb3J5IiBjb25zdHJhaW50ID8NCg0KVGhlIGNvcnJlY3QgY29uc3RyYWludCB3b3Vs
ZCBiZSBvbmUgdGhhdCB0b2xkIGdjYyB0aGF0IGl0DQphY2Nlc3NlcyB0aGUgMjAgYnl0ZXMgZnJv
bSB0aGUgc291cmNlIHBvaW50ZXIuDQoNCldpdGhvdXQgaXQgZ2NjIHdvbid0IG5lY2Vzc2FyaWx5
IHdyaXRlIG91dCB0aGUgdmFsdWVzIGJlZm9yZQ0KdGhlIGFzbSBpbnN0cnVjdGlvbnMgZXhlY3V0
ZS4NCg0KCURhdmlkDQoNCg==
