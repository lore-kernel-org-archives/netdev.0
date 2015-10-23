From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 3/3] switchdev: split switchdev_attr into
 individual structs
Date: Fri, 23 Oct 2015 06:53:50 -0700 (PDT)
Message-ID: <20151023.065350.237651970219689445.davem@davemloft.net>
References: <1445570717-40780-1-git-send-email-sfeldma@gmail.com>
	<1445570717-40780-3-git-send-email-sfeldma@gmail.com>
	<20151023.063244.1017914313842957944.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	vivien.didelot@savoirfairelinux.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35245 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750958AbbJWNhU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 09:37:20 -0400
In-Reply-To: <20151023.063244.1017914313842957944.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRGF2aWQgTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0Pg0KRGF0ZTogRnJpLCAyMyBP
Y3QgMjAxNSAwNjozMjo0NCAtMDcwMCAoUERUKQ0KDQo+IEZyb206IHNmZWxkbWFAZ21haWwuY29t
DQo+IERhdGU6IFRodSwgMjIgT2N0IDIwMTUgMjA6MjU6MTcgLTA3MDANCj4gDQo+PiBGcm9tOiBT
Y290dCBGZWxkbWFuIDxzZmVsZG1hQGdtYWlsLmNvbT4NCj4+IA0KPj4gVGhpcyB3YXMgYWxyZWFk
eSBkb25lIGZvciBzd2l0Y2hkZXZfb2Jqcy4gICBDaGFuZ2luZyBzd2l0Y2hkZXZfYXR0cnMgdG8g
bmV3DQo+PiBzdHlsZSBtYWtlcyBzd2l0Y2hkZXYgQVBJIGNvbnNpc3RlbnQgZm9yIGJvdGggYXR0
cnMgYW5kIG9ianMuDQo+PiANCj4+IE5vIGZ1bmN0aW9uYWwgY2hhbmdlcyBoZXJlLg0KPj4gDQo+
PiBTaWduZWQtb2ZmLWJ5OiBTY290dCBGZWxkbWFuIDxzZmVsZG1hQGdtYWlsLmNvbT4NCj4+IEFj
a2VkLWJ5OiBKaXJpIFBpcmtvIDxqaXJpQG1lbGxhbm94LmNvbT4NCj4gDQo+IEFwcGxpZWQuDQoN
ClRoaXMgYnJlYWtzIHRoZSBidWlsZCwgSSdtIHJldmVydGluZyB0aGlzIHBhdGNoIHNlcmllczoN
Cg0KbmV0L2JyaWRnZS9icl9zdHBfaWYuYzogSW4gZnVuY3Rpb24goWJyX2luaXRfcG9ydKI6DQpu
ZXQvYnJpZGdlL2JyX3N0cF9pZi5jOjQyOjM6IGVycm9yOiB1bmtub3duIGZpZWxkIKF1oiBzcGVj
aWZpZWQgaW4gaW5pdGlhbGl6ZXINCm5ldC9icmlkZ2UvYnJfc3RwX2lmLmM6NDI6Mzogd2Fybmlu
ZzogZXhjZXNzIGVsZW1lbnRzIGluIHN0cnVjdCBpbml0aWFsaXplciBbZW5hYmxlZCBieSBkZWZh
dWx0XQ0KbmV0L2JyaWRnZS9icl9zdHBfaWYuYzo0MjozOiB3YXJuaW5nOiAobmVhciBpbml0aWFs
aXphdGlvbiBmb3IgoWF0dHKiKSBbZW5hYmxlZCBieSBkZWZhdWx0XQ0K
