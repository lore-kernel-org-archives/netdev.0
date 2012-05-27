From: spiro@snacorp.net
Subject: Re: [PATCH 1/2] nfct-extensions/timeout: adjust for changed	nfct_timeout_snprintf API
Date: Sun, 27 May 2012 02:35:03 +0000
Message-ID: <1197458793-1338086100-cardhu_decombobulator_blackberry.rim.net-65961234-@b2.c20.bise6.blackberry>
References: <20120526180654.GB31938@1984>
 	<1338058955-5789-1-git-send-email-jengelh@inai.de>
 	<1338058955-5789-2-git-send-email-jengelh@inai.de>
  <20120526202105.GB452@1984>
Reply-To: spiro@snacorp.net
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	netfilter-announce@lists.netfilter.org
To: "Pablo Neira Ayuso" <pablo@netfilter.org>,
	netfilter-announce-bounces@lists.netfilter.org,
	"Jan Engelhardt" <jengelh@inai.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp07.bis6.us.blackberry.com ([74.82.85.7]:50632 "EHLO
	smtp07.bis6.us.blackberry.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752516Ab2E0Cos (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 May 2012 22:44:48 -0400
In-Reply-To: <20120526202105.GB452@1984>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cmVtb3ZlIG1lIGZyb20gdGhpcyBsaXN0IGFuZCB5b3VyIGxpc3RzDQpTZW50IHZpYSBCbGFja0Jl
cnJ5IGZyb20gVC1Nb2JpbGUNCg0KLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCkZyb206IFBh
YmxvIE5laXJhIEF5dXNvIDxwYWJsb0BuZXRmaWx0ZXIub3JnPg0KU2VuZGVyOiBuZXRmaWx0ZXIt
YW5ub3VuY2UtYm91bmNlc0BsaXN0cy5uZXRmaWx0ZXIub3JnDQpEYXRlOiBTYXQsIDI2IE1heSAy
MDEyIDIyOjIxOjA1IA0KVG86IEphbiBFbmdlbGhhcmR0PGplbmdlbGhAaW5haS5kZT4NCkNjOiA8
bmV0ZGV2QHZnZXIua2VybmVsLm9yZz47IDxuZXRmaWx0ZXJAdmdlci5rZXJuZWwub3JnPjsgPG5l
dGZpbHRlci1kZXZlbEB2Z2VyLmtlcm5lbC5vcmc+OyA8bmV0ZmlsdGVyLWFubm91bmNlQGxpc3Rz
Lm5ldGZpbHRlci5vcmc+DQpTdWJqZWN0OiBSZTogW1BBVENIIDEvMl0gbmZjdC1leHRlbnNpb25z
L3RpbWVvdXQ6IGFkanVzdCBmb3IgY2hhbmdlZA0KCW5mY3RfdGltZW91dF9zbnByaW50ZiBBUEkN
Cg0KT24gU2F0LCBNYXkgMjYsIDIwMTIgYXQgMDk6MDI6MzRQTSArMDIwMCwgSmFuIEVuZ2VsaGFy
ZHQgd3JvdGU6DQo+IERlc3BpdGUgcmVxdWlyaW5nIGxpYm5ldGZpbHRlcl9jdHRpbWVvdXQgPj0g
MS4wLjAsIGl0IGRpZCBub3QNCj4gdXNlIHRoZSBuZXcgQVBJLg0KPiANCj4gbmZjdC1leHRlbnNp
b25zL3RpbWVvdXQuYzogSW4gZnVuY3Rpb24gJ25mY3RfdGltZW91dF9jYic6DQo+IG5mY3QtZXh0
ZW5zaW9ucy90aW1lb3V0LmM6OTk6MjogZXJyb3I6IHRvbyBmZXcgYXJndW1lbnRzIHRvIGZ1bmN0
aW9uDQo+IAknbmZjdF90aW1lb3V0X3NucHJpbnRmJw0KPiBJbiBmaWxlIGluY2x1ZGVkIGZyb20g
bmZjdC1leHRlbnNpb25zL3RpbWVvdXQuYzoyNjowOg0KPiAvdXNyL2luY2x1ZGUvbGlibmV0Zmls
dGVyX2N0dGltZW91dC0xLjAuMC9saWJuZXRmaWx0ZXJfY3R0aW1lb3V0Lw0KPiAJbGlibmV0Zmls
dGVyX2N0dGltZW91dC5oOjExNDo1OiBub3RlOiBkZWNsYXJlZCBoZXJlDQo+IA0KPiAxMTQ6IGlu
dCBuZmN0X3RpbWVvdXRfc25wcmludGYoY2hhciAqYnVmLCBzaXplX3Qgc2l6ZSwNCj4gCWNvbnN0
IHN0cnVjdCBuZmN0X3RpbWVvdXQgKiwgdW5zaWduZWQgaW50IHR5cGUsIHVuc2lnbmVkIGludCBm
bGFncyk7DQoNCldlIG5vdGljZWQgYXQgdGhlIHNhbWUgdGltZS4NCg0KSXQncyBmaXhlZCBub3cs
IGFuZCBjb25udHJhY2stdG9vbHMgMS4yLjEgaXMgb3V0LiBUaGFua3MhDQoNCg==
