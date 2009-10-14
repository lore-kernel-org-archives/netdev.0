From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Add sk_mark route lookup support for IPv4 listening
 sockets, and for IPv4 multicast forwarding
Date: Wed, 14 Oct 2009 02:15:05 -0700 (PDT)
Message-ID: <20091014.021505.181431380.davem@davemloft.net>
References: <20091007.223928.34412707.davem@davemloft.net>
	<55a4f86e0910140051v69441b09gd364b32f8e2d0c68@mail.gmail.com>
	<20091014072319.GA12095@fogou.chygwyn.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: base64
Cc: zenczykowski@gmail.com, atis@mikrotik.com, netdev@vger.kernel.org,
	panther@balabit.hu, eric.dumazet@gmail.com, brian.haley@hp.com
To: steve@chygwyn.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47015
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757941AbZJNJPJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2009 05:15:09 -0400
In-Reply-To: <20091014072319.GA12095@fogou.chygwyn.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogc3RldmVAY2h5Z3d5bi5jb20NCkRhdGU6IFdlZCwgMTQgT2N0IDIwMDkgMDg6MjM6MTkg
KzAxMDANCg0KPiBPbiBXZWQsIE9jdCAxNCwgMjAwOSBhdCAxMjo1MTo1NkFNIC0wNzAwLCBNYWNp
ZWogxbtlbmN6eWtvd3NraSB3cm90ZToNCj4+IEknbSB0aGlua2luZyB0aGF0IHRoZSBtYXJrIHNo
b3VsZCBiZSBhIHR1bm5lbCBwYXJhbWV0ZXIgd2l0aCB2YWx1ZXMgb2YNCj4+IGluaGVyaXQgb3Ig
YSBjb25zdGFudC4NCj4+DQo+IFdoeSBub3QgZG8gdGhpcyBvbiBhIHBlci1yb3V0ZSBiYXNpcyAo
aS5lLiBsZXRzIHN1cHBvc2Ugd2UgYWRkIGENCj4gInNldG1hcmsiIHBhcmFtZXRlciB0byBlYWNo
IHJvdXRlKSBhbmQgdGhpcyB3b3VsZCBhbGxvdyBjaGFuZ2luZw0KPiBhIG1hcmsgd2hlbiBhIHBh
Y2tldCBtYXRjaGVzIHRoZSByb3V0ZS4gVGhpcyBub3Qgb25seSBzb2x2ZXMgdGhlDQo+IHR1bm5l
bCBjYXNlLCBidXQgd291bGQgYmUgZ2VuZXJpY2FsbHkgdXNlZnVsIGFzIHdlbGwuDQo+IA0KPiBT
aW5jZSB3ZSBoYXZlIHRvIGxvb2sgdXAgcm91dGVzIGFueXdheSwgaXQgc2hvdWxkbid0IGFkZCBh
bnkNCj4gcmVhbCBvdmVyaGVhZCB0byB0aGUgcm91dGluZyBwcm9jZXNzIGFuZCB3ZSBjYW4gYmVu
ZWZpdCBmcm9tDQo+IGFsbCB0aGUgZXhpc3RpbmcgaW5mcmFzdHJ1Y3R1cmUgKHJvdXRlIGNhY2hl
LCBldGMpLg0KDQpUaGlzIGlkZWEsIEkgbGlrZSA6LSkNCg==
