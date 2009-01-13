From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Remove redundant NAPI functions
Date: Mon, 12 Jan 2009 16:30:21 -0800 (PST)
Message-ID: <20090112.163021.132623782.davem@davemloft.net>
References: <1231769390.3075.2.camel@achroite>
	<1231771577.3075.5.camel@achroite>
	<m34p04bfd2.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: base64
Cc: bhutchings@solarflare.com, jarkao2@gmail.com,
	nhorman@tuxdriver.com, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: khc@pm.waw.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36712
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751189AbZAMAaU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 19:30:20 -0500
In-Reply-To: <m34p04bfd2.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogS3J6eXN6dG9mIEhhbGFzYSA8a2hjQHBtLndhdy5wbD4NCkRhdGU6IE1vbiwgMTIgSmFu
IDIwMDkgMTg6MzE6MzcgKzAxMDANCg0KPiBCZW4gSHV0Y2hpbmdzIDxiaHV0Y2hpbmdzQHNvbGFy
ZmxhcmUuY29tPiB3cml0ZXM6DQo+IA0KPiA+PiA+ID4gLS0tIGEvZHJpdmVycy9uZXQvd2FuL2l4
cDR4eF9oc3MuYw0KPiA+PiA+ID4gKysrIGIvZHJpdmVycy9uZXQvd2FuL2l4cDR4eF9oc3MuYw0K
PiA+PiBbLi4uXQ0KPiA+PiDvu78NCj4gPj4gV2hhdCdzIHRoZSBpc3N1ZSAtIGRvZXMgaXQgY29u
ZmxpY3Qgd2l0aCBhbm90aGVyIGNoYW5nZSB0byB0aGlzIGZpbGU/DQo+ID4NCj4gPiBPaCwgbm93
IEkgc2VlIGl0IC0gdGhlIGRldmljZSBhcmd1bWVudHMgaGFkbid0IGFscmVhZHkgYmVlbiByZW1v
dmVkLg0KPiA+IFllcywgSSdtIGFmcmFpZCBJIGZhaWxlZCB0byBzZWxlY3QgdGhpcyBkcml2ZXIu
DQo+IA0KPiBJdCdzIG9ubHkgcG9zc2libGUgb24gcGxhdGZvcm1zIGJhc2VkIG9uIElYUDR4eCAo
SW50ZWwncyBuZXR3b3JraW5nDQo+IEFSTSBDUFUpLg0KDQpTbywgYXMgaXQgdHVybnMgb3V0IEkg
dGhpbmsgSSBuZWVkIHRvIGhhbmRsZSB0aGlzIGluIGEgZmV3IHN0YWdlczoNCg0KMSkgSXQgZG9l
c24ndCBidWlsZCB1cHN0cmVhbSBpbiBMaW51cydzIHRyZWUgYmVjYXVzZSBvZiB0aGUNCiAgIGRl
diBhcmcsIHNvIEknbGwgZml4IHRoYXQgdXBzdHJlYW0gaW4gbmV0LTIuNg0KDQoyKSBUaGVuIEkn
bGwgcmV3b3JrIEJlbidzIG5hcGlfKigpIHBhdGNoIHRvIGFwcGx5IG9uIHRvcCBvZiB0aGF0Lg0K
DQpJIGNhbiBkbyB0aGlzIGJlY2F1c2UgSSBoYXZlbid0IHB1Ymxpc2hlZCBteSBuZXQtbmV4dC0y
LjYgdHJlZQ0KeWV0IGFueXdoZXJlLCBzbyBJIGNhbiBqdXN0IHJlYmFzZSB0byBmaXggYWxsIG9m
IHRoaXMgdXAuDQoNClRoYW5rcy4NCg==
