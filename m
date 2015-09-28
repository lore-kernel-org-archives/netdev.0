From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2] net: sctp: Don't use 64 kilobyte lookup table for
 four elements
Date: Mon, 28 Sep 2015 15:32:44 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CBA431C@AcuExch.aculab.com>
References: <1443443644-12825-1-git-send-email-dvlasenk@redhat.com>
	 <20150928135127.GB5248@hmsreliant.think-freely.org>
	 <063D6719AE5E284EB5DD2968C1650D6D1CBA41B0@AcuExch.aculab.com>
 <1443450427.2531.2.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: 'Neil Horman' <nhorman@tuxdriver.com>,
	Denys Vlasenko <dvlasenk@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443450427.2531.2.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogRXJpYyBEdW1hemV0DQo+IFNlbnQ6IDI4IFNlcHRlbWJlciAyMDE1IDE1OjI3DQo+IE9u
IE1vbiwgMjAxNS0wOS0yOCBhdCAxNDoxMiArMDAwMCwgRGF2aWQgTGFpZ2h0IHdyb3RlOg0KPiA+
IEZyb206IE5laWwgSG9ybWFuDQo+ID4gPiBTZW50OiAyOCBTZXB0ZW1iZXIgMjAxNSAxNDo1MQ0K
PiA+ID4gT24gTW9uLCBTZXAgMjgsIDIwMTUgYXQgMDI6MzQ6MDRQTSArMDIwMCwgRGVueXMgVmxh
c2Vua28gd3JvdGU6DQo+ID4gPiA+IFNlZW1pbmdseSBpbm5vY3VvdXMgc2N0cF90cmFuc19zdGF0
ZV90b19wcmlvX21hcFtdIGFycmF5DQo+ID4gPiA+IGlzIHdheSBiaWdnZXIgdGhhbiBpdCBsb29r
cywgc2luY2UNCj4gPiA+ID4gIltTQ1RQX1VOS05PV05dID0gMiIgZXhwYW5kcyBpbnRvICJbMHhm
ZmZmXSA9IDIiICENCj4gPiA+ID4NCj4gPiA+ID4gVGhpcyBwYXRjaCByZXBsYWNlcyBpdCB3aXRo
IHN3aXRjaCgpIHN0YXRlbWVudC4NCj4gPg0KPiA+IFdoYXQgYWJvdXQganVzdCBhZGRpbmcgMSAo
YW5kIG1hc2tpbmcpIGJlZm9yZSBpbmRleGluZyB0aGUgYXJyYXk/DQo+ID4gVGhhdCBtaWdodCBy
ZXF1aXJlIGEgc3RhdGljIGlubGluZSBmdW5jdGlvbiB3aXRoIGEgbG9jYWwgc3RhdGljIGFycmF5
Lg0KPiA+DQo+ID4gT3IgZGVmaW5lIHRoZSBhcnJheSBhcyAoc2F5KSBbMTZdIGFuZCBqdXN0IG1h
c2sgdGhlIHN0YXRlIGJlZm9yZSB1c2luZw0KPiA+IGl0IGFzIGFuIGluZGV4Pw0KPiANCj4gSnVz
dCBsZXQgdGhlIGNvbXBpbGVyIGRvIGl0cyBqb2IsIGluc3RlYWQgb2Ygb2JmdXNjYXRpbmcgc291
cmNlLg0KPiANCj4gQ29tcGlsZXJzIGNhbiB0cmFuc2Zvcm0gYSBzd2l0Y2ggaW50byBhbiAob3B0
aW1hbCkgdGFibGUgaWYgaXQgaXMgcmVhbGx5DQo+IGEgZ2Fpbi4NCg0KVGhlIGNvbXBpbGVyIGNh
biBjaG9vc2UgYmV0d2VlbiBhIGp1bXAgdGFibGUgYW5kIG5lc3RlZCBpZnMgZm9yIGEgc3dpdGNo
DQpzdGF0ZW1lbnQuIEkndmUgbmV2ZXIgc2VlbiBpdCBjb252ZXJ0IG9uZSBpbnRvIGEgZGF0YSBh
cnJheSBpbmRleC4NCg0KCURhdmlkDQoNCg==
