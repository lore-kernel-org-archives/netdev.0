From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [patch net-next] ipv6: allow userspace to create address with IFLA_F_TEMPORARY flag
Date: Tue, 5 Nov 2013 17:12:46 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B73E2@saturn3.aculab.com>
References: <20131028.204306.2213130677400093266.davem@davemloft.net> <AE90C24D6B3A694183C094C60CF0A2F6026B73BB@saturn3.aculab.com> <20131029124010.GA15762@order.stressinduktion.org> <52792499.3030201@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
To: <nicolas.dichtel@6wind.com>, "David Miller" <davem@davemloft.net>,
	<jiri@resnulli.us>, <vyasevich@gmail.com>,
	<netdev@vger.kernel.org>, <kuznet@ms2.inr.ac.ru>,
	<jmorris@namei.org>, <yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	<thaller@redhat.com>, <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:40970 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753955Ab3KERTu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Nov 2013 12:19:50 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 28225-08 for <netdev@vger.kernel.org>;
 Tue,  5 Nov 2013 17:19:47 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <52792499.3030201@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBGcm9tOiBOaWNvbGFzIERpY2h0ZWwgW21haWx0bzpuaWNvbGFzLmRpY2h0ZWxANndpbmQuY29t
XQ0KLi4uDQo+IElmIEkgcmVtZW1iZXIgd2VsbCwgYW5vdGhlciBwcm9ibGVtIGlzIHRvIGJlIGFi
bGUgdG8gc2VuZCB0aGVzZSBwYWNrZXRzIHdpdGgNCj4gMC4wLjAuMCB3aGVuIGFub3RoZXIgSVAg
YWRkcmVzcyBpcyBhdmFpbGFibGUgb24gdGhlIHN5c3RlbToNCj4gDQo+IFJGQzIxMzENCj4gNC4x
IENvbnN0cnVjdGluZyBhbmQgc2VuZGluZyBESENQIG1lc3NhZ2VzDQo+IC4uLg0KPiAgICAgREhD
UCBtZXNzYWdlcyBicm9hZGNhc3QgYnkgYSBjbGllbnQgcHJpb3IgdG8gdGhhdCBjbGllbnQgb2J0
YWluaW5nDQo+ICAgICBpdHMgSVAgYWRkcmVzcyBtdXN0IGhhdmUgdGhlIHNvdXJjZSBhZGRyZXNz
IGZpZWxkIGluIHRoZSBJUCBoZWFkZXINCj4gICAgIHNldCB0byAwLg0KPiANCj4gV2UgbWFkZSBh
IHBhdGNoIChuZXZlciBwcm9wb3NlZCB1cHN0cmVhbSkgdG8gYWRkIGEgc29ja2V0IG9wdGlvbiB0
byBrZWVwDQo+IHRoaXMgMC4wLjAuMCBhZGRyZXNzLg0KPiBJZiBwZW9wbGUgYXJlIGludGVyZXN0
ZWQsIEkgY2FuIHRyeSB0byBwb3J0IGl0IG9uIG5ldC1uZXh0Lg0KDQpSZWFsbHksIHdoYXQgZGhj
cCBkb2VzIGJlZm9yZSB0aGUgaW50ZXJmYWNlIGhhcyBhbiBhZGRyZXNzIGRvZXNuJ3QNCnJlYWxs
eSBtYXR0ZXIgLSB1c2luZyBicGYgaXNuJ3QgYSBwcm9ibGVtLg0KDQpXaGF0IGl0IG5lZWRzIHRv
IGRvIGlzIHN3aXRjaCB0byB1c2luZyBhIG5vcm1hbCBzb2NrZXQgZm9yIHRoZSByZW5ld2Fscy4N
Cg0KTWF5YmUgSSdsbCB0cnkgYXNraW5nIFJveSBhYm91dCBpdCBvbiB0aGUgTmV0QlNEIGxpc3Rz
Lg0KDQoJRGF2aWQNCg0K
