From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] bnx2: avoid compiler warnings
Date: Wed, 04 Nov 2009 05:08:13 -0800 (PST)
Message-ID: <20091104.050813.07932152.davem@davemloft.net>
References: <4AEFF536.1020402@gmail.com>
	<1257271294.8625.9.camel@HP1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: base64
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57208
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756025AbZKDNHs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 08:07:48 -0500
In-Reply-To: <1257271294.8625.9.camel@HP1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogIk1pY2hhZWwgQ2hhbiIgPG1jaGFuQGJyb2FkY29tLmNvbT4NCkRhdGU6IFR1ZSwgMyBO
b3YgMjAwOSAxMDowMTozNCAtMDgwMA0KDQo+IA0KPiBPbiBUdWUsIDIwMDktMTEtMDMgYXQgMDE6
MTcgLTA4MDAsIEVyaWMgRHVtYXpldCB3cm90ZToNCj4+IGRyaXZlcnMvbmV0L2JueDIuYzogSW4g
ZnVuY3Rpb24g4oCYYm54Ml9lbmFibGVfZm9yY2VkXzJnNeKAmToNCj4+IGRyaXZlcnMvbmV0L2Ju
eDIuYzoxNDQ3OiB3YXJuaW5nOiDigJhibWNy4oCZIG1heSBiZSB1c2VkIHVuaW5pdGlhbGl6ZWQg
aW4gdGhpcyBmdW5jdGlvbg0KPj4gZHJpdmVycy9uZXQvYm54Mi5jOiBJbiBmdW5jdGlvbiDigJhi
bngyX2Rpc2FibGVfZm9yY2VkXzJnNeKAmToNCj4+IGRyaXZlcnMvbmV0L2JueDIuYzoxNDgyOiB3
YXJuaW5nOiDigJhibWNy4oCZIG1heSBiZSB1c2VkIHVuaW5pdGlhbGl6ZWQgaW4gdGhpcyBmdW5j
dGlvbg0KPj4gDQo+PiBPbmUgZml4IHdvdWxkIGJlIHRvIGhhdmUgYW4gaW5pdGlhbCB2YWx1ZSwg
YnV0IGEgcGxhaW4gcmV0dXJuIG1pZ2h0IGJlIGJldHRlci4NCj4gDQo+IEkgYWdyZWUgdGhhdCBw
bGFpbiByZXR1cm4gaXMgYmV0dGVyLiAgVGhhbmtzLg0KPiANCj4gQWNrZWQtYnk6IE1pY2hhZWwg
Q2hhbiA8bWNoYW5AYnJvYWRjb20uY29tPg0KDQpBcHBsaWVkLCB0aGFua3MuDQo=
