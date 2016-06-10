From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next] nfnetlink_queue: enable PID info retrieval
Date: Fri, 10 Jun 2016 14:29:47 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D5F4D4981@AcuExch.aculab.com>
References: <1465505409-1232-1-git-send-email-saeedm@mellanox.com>
 <1465507031.7945.44.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Andre Melkoumian <andre@mellanox.com>,
	Matthew Finlay <matt@mellanox.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>,
	Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.183]:64793 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161191AbcFJObP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 10:31:15 -0400
In-Reply-To: <1465507031.7945.44.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0DQo+IFNlbnQ6IDA5IEp1bmUgMjAxNiAyMjoxNw0KPiBPbiBUaHUs
IDIwMTYtMDYtMDkgYXQgMjM6NTAgKzAzMDAsIFNhZWVkIE1haGFtZWVkIHdyb3RlOg0KPiA+IEZy
b206IE1hdHRoZXcgRmlubGF5IDxtYXR0QG1lbGxhbm94LmNvbT4NCj4gDQo+IA0KPiA+IGRpZmYg
LS1naXQgYS9uZXQvc29ja2V0LmMgYi9uZXQvc29ja2V0LmMNCj4gPiBpbmRleCBhMWJkMTYxLi42
N2RlMjAwIDEwMDY0NA0KPiA+IC0tLSBhL25ldC9zb2NrZXQuYw0KPiA+ICsrKyBiL25ldC9zb2Nr
ZXQuYw0KPiA+IEBAIC0zODIsNiArMzgyLDcgQEAgc3RydWN0IGZpbGUgKnNvY2tfYWxsb2NfZmls
ZShzdHJ1Y3Qgc29ja2V0ICpzb2NrLCBpbnQgZmxhZ3MsIGNvbnN0IGNoYXIgKmRuYW1lKQ0KPiA+
ICAJfQ0KPiA+DQo+ID4gIAlzb2NrLT5maWxlID0gZmlsZTsNCj4gPiArCWZpbGUtPmZfb3duZXIu
c29ja19waWQgID0gZmluZF9nZXRfcGlkKHRhc2tfcGlkX25yKGN1cnJlbnQpKTsNCj4gPiAgCWZp
bGUtPmZfZmxhZ3MgPSBPX1JEV1IgfCAoZmxhZ3MgJiBPX05PTkJMT0NLKTsNCj4gPiAgCWZpbGUt
PnByaXZhdGVfZGF0YSA9IHNvY2s7DQo+ID4gIAlyZXR1cm4gZmlsZTsNCj4gDQo+IFdvdywgdGhh
dCBpcyBhIHNlcmlvdXMgbWVtb3J5IGxlYWsgd2VhcG9uIChvZiBzdHJ1Y3QgcGlkKQ0KPiANCj4g
V2h5IGRvbid0IHlvdSBzdG9yZSB0aGUgcGlkIHZhbHVlLCBpbnN0ZWFkIG9mIGEgcG9pbnRlciA/
DQoNClNpbmNlIHRoZSBudW1lcmljICdwaWQnIHZhbHVlcyBjYW4gYmUgcmV1c2VkICh3aXRoIG5v
IGdyYWNlIHRpbWUpIHlvdSdkDQpuZWVkIHRvIGhvbGQgYSByZWZlcmVuY2UgdG8gdGhlIHBpZCBz
dHJ1Y3R1cmUgKGFkZGVkIGluIGFib3V0IDIuNi4yNykgaW5zdGVhZC4NCldoaWNoIGlzIGp1c3Qg
YSBzbWFsbGVyIG1lbW9yeSBsZWFrIQ0KKGFuZCBhbm5veWluZ2x5IGEgbm9uLWdwbCBkcml2ZXIg
Y2FuJ3QgZHJvcCBhIHJlZmVyZW5jZSB0byBpdCkuDQoNCglEYXZpZA0KDQo=
