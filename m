From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: RE: [PATCH 6/7] mlx4_en: Adding rxhash support
Date: Tue, 18 Oct 2011 08:59:44 +0000
Message-ID: <953B660C027164448AE903364AC447D2235EEC80@MTLDAG01.mtl.com>
References: <4E9C8D8B.90606@mellanox.co.il>
	 <1318902525.2571.24.camel@edumazet-laptop>
	 <953B660C027164448AE903364AC447D2235EEB65@MTLDAG01.mtl.com>
 <1318926870.2657.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:55104 "HELO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757109Ab1JRJIm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 05:08:42 -0400
In-Reply-To: <1318926870.2657.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiANCj4gV2hhdCBpcyB0aGUgZ2FpbiB1c2luZyByYW5kb20gdmFsdWVzID8NCj4gDQo+IFVzdWFs
bHksIHdlIHRlbmQgdG8gaGF2ZSBzYW1lIGhhcmR3YXJlIGluIGEgc2luZ2xlIG1hY2hpbmUsIG9y
IHdlIHVzZQ0KPiBhY3RpdmUtYmFja3VwIGJvbmRpbmcgbW9kZSwgYW5kIGFuIGFjdGl2ZSBzbGF2
ZSBmbGlwIGNhbiBjaGFuZ2UgcnhoYXNoDQo+IHZhbHVlcyB3aXRoIGxpdGxlIGVmZmVjdCwgc2lu
Y2UgdGhpcyBoYXBwZW5zIG5vdCBvZnRlbi4NCj4gDQo+IEkgcmVhbGx5IHByZWZlciBub3QgcmFu
ZG9tIHZhbHVlcywgYmVjYXVzZSBpdCBhbGxvd3MgdG8gaGF2ZSByZXBsYXlhYmxlDQo+IGNvbmZp
Z3VyYXRpb25zIDogRm9yIGEgZ2l2ZW4gdGNwIGZsb3csIHRoZSBzYW1lIHJ4aGFzaCB2YWx1ZSBp
cyBnaXZlbg0KPiBhbmQgc2FtZSBjcHUgdGFyZ2V0IGluIFJQUy4gSXRzIHdheSBlYXNpZXIgdG8g
dHVuZSB5b3VyIG1hY2hpbmUgZm9yIHNvbWUgd29ya2xvYWRzLg0KPiANCg0KVGhlcmUgaXMgbm8g
Z2FpbiBpbiByYW5kb20gdmFsdWVzLCANCkknbGwgbWFrZSB0aGUgY2hhbmdlIHRvIGhhdmUgc3Rh
dGljIHZhbHVlIGZvciBSU1MgZnVuY3Rpb24uDQoNCldlIG1pZ2h0IGNvbnNpZGVyIGhvdyB0byBl
bnN1cmUgY29uc2lzdGVuY3kgYWNyb3NzIHRoZSBkaWZmZXJlbnQgZHJpdmVycyBpbiB0aGlzIGFz
cGVjdC4NCg0K
