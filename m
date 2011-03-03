From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] eql: Convert printks to pr_<level> and
 netdev_<level>
Date: Thu, 03 Mar 2011 12:59:51 -0800 (PST)
Message-ID: <20110303.125951.200370524.davem@davemloft.net>
References: <7f33dcacd277e127208211d8c3ef11c992408628.1299086044.git.joe@perches.com>
	<90c4322fefc5e2d4778862abd051e6eb12c0284b.1299086044.git.joe@perches.com>
	<20110303.122153.70207563.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50799
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932375Ab1CCU7O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 15:59:14 -0500
In-Reply-To: <20110303.122153.70207563.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRGF2aWQgTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0Pg0KRGF0ZTogVGh1LCAwMyBN
YXIgMjAxMSAxMjoyMTo1MyAtMDgwMCAoUFNUKQ0KDQo+IEZyb206IEpvZSBQZXJjaGVzIDxqb2VA
cGVyY2hlcy5jb20+DQo+IERhdGU6IFdlZCwgIDIgTWFyIDIwMTEgMDk6MTg6MTIgLTA4MDANCj4g
DQo+PiBBZGQgcHJfZm10DQo+PiANCj4+IFNpZ25lZC1vZmYtYnk6IEpvZSBQZXJjaGVzIDxqb2VA
cGVyY2hlcy5jb20+DQo+IA0KPiBBcHBsaWVkLg0KDQpTb21ldGhpbmcgaXMgYnVzdGVkIHdpdGgg
dGhpcyBjaGFuZ2UsIGFsdGhvdWdoIEkgY2FuJ3QgcXVpdGUgZmlndXJlIGl0DQpvdXQgbXlzZWxm
Og0KDQpkcml2ZXJzL25ldC9lcWwuYzogSW4gZnVuY3Rpb24goWVxbF9pbml0X21vZHVsZaI6DQpk
cml2ZXJzL25ldC9lcWwuYzo1OTY6MjogZXJyb3I6IGV4cGVjdGVkIKEpoiBiZWZvcmUgoXZlcnNp
b26iDQo=
