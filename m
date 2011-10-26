From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: use IS_ENABLED() macro to cleanup code
Date: Wed, 26 Oct 2011 15:56:20 -0400 (EDT)
Message-ID: <20111026.155620.2146384686184694859.davem@davemloft.net>
References: <1319526752.3834.12.camel@edumazet-laptop>
	<20111025.193037.1312584002692004360.davem@davemloft.net>
	<1319610874.18883.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35659 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752100Ab1JZT40 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2011 15:56:26 -0400
In-Reply-To: <1319610874.18883.8.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0IDxlcmljLmR1bWF6ZXRAZ21haWwuY29tPg0KRGF0ZTogV2VkLCAy
NiBPY3QgMjAxMSAwODozNDozNCArMDIwMA0KDQo+IExlIG1hcmRpIDI1IG9jdG9icmUgMjAxMSDD
oCAxOTozMCAtMDQwMCwgRGF2aWQgTWlsbGVyIGEgw6ljcml0IDoNCj4gDQo+PiBuZXQvaXB2NC9p
cF9zb2NrZ2x1ZS5jOiBJbiBmdW5jdGlvbiDigJhkb19pcF9zZXRzb2Nrb3B04oCZOg0KPj4gbmV0
L2lwdjQvaXBfc29ja2dsdWUuYzo1MjM6Mjk6IGVycm9yOiDigJhMT09QQkFDSzRfSVBWNuKAmSB1
bmRlY2xhcmVkIChmaXJzdCB1c2UgaW4gdGhpcyBmdW5jdGlvbikNCj4+IG5ldC9pcHY0L2lwX3Nv
Y2tnbHVlLmM6NTIzOjI5OiBub3RlOiBlYWNoIHVuZGVjbGFyZWQgaWRlbnRpZmllciBpcyByZXBv
cnRlZCBvbmx5IG9uY2UgZm9yIGVhY2ggZnVuY3Rpb24gaXQgYXBwZWFycyBpbg0KPj4gDQo+PiBU
aGlzIGZhaWxzIGJlY2F1c2UgaXBfc29ja2dsdWUuYyBndWFyZHMgdGhlIG5ldC90cmFuc3BfdjYu
aCBoZWFkZXINCj4+IGluY2x1c2lvbiB3aXRoIGEgcmVhbCBDUFAgZ3VhcmQuDQo+IA0KPiBZZXAs
IGl0IHNlZW1zIGNvbXBpbGVyIHdhcyBub3QgYWJsZSB0byBwZXJmb3JtIG9wdGltaXNhdGlvbiBv
ZiBkZWFkDQo+IGNvZGUuDQoNCkl0J3Mgbm90IHRoZSBpc3N1ZSBvZiBvcHRpbWl6aW5nIHRoZSBj
b2RlIG91dCwgaW4gdGhlIGVuZCB0aGUgY29tcGlsZXINCndpbGwgb3B0aW1pemUgdGhpcyBzdHVm
ZiBvdXQuDQoNClJhdGhlciwgdGhlIGlzc3VlIGlzIHRoYXQgdGhlIGNvZGUgc2VlbiBieSB0aGUg
Y29tcGlsZXIgbXVzdCBiZSBwYXJzYWJsZS4NCg==
