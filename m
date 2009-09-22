From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH] pcmcia: pcnet_cs.c removing useless condition
Date: Tue, 22 Sep 2009 14:17:16 -0700 (PDT)
Message-ID: <20090922.141716.236597540.davem@davemloft.net>
References: <1252782529.3687.26.camel@ht.satnam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: base64
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-pcmcia@lists.infradead.org, linux@dominikbrodowski.net
To: jaswinder@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52072
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751594AbZIVVQ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2009 17:16:57 -0400
In-Reply-To: <1252782529.3687.26.camel@ht.satnam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogSmFzd2luZGVyIFNpbmdoIFJhanB1dCA8amFzd2luZGVyQGtlcm5lbC5vcmc+DQpEYXRl
OiBTdW4sIDEzIFNlcCAyMDA5IDAwOjM4OjQ5ICswNTMwDQoNCj4gW1RoaXMgaXMgdW50ZXN0ZWRd
DQo+IA0KPiAnaWYgKGkgPCBOUl9JTkZPKScgd2lsbCBvbmx5IHRydWUgaWYgd2UgYnJlYWtzIGZy
b20gJ2ZvciAoaSA9IDA7IGkgPCBOUl9JTkZPOyBpKyspJw0KPiBTbyByZW1vdmluZyB1c2VsZXNz
ICdpZiAoaSA8IE5SX0lORk8pJw0KPiANCj4gVGhpcyBhbHNvIGZpeGVkIGZvbGxvd2luZyBjb21w
aWxhdGlvbiB3YXJuaW5nIDoNCj4gDQo+ICAgQ0MgW01dICBkcml2ZXJzL25ldC9wY21jaWEvcGNu
ZXRfY3Mubw0KPiBkcml2ZXJzL25ldC9wY21jaWEvcGNuZXRfY3MuYzogSW4gZnVuY3Rpb24g4oCY
Z2V0X2h3aW5mb+KAmToNCj4gZHJpdmVycy9uZXQvcGNtY2lhL3BjbmV0X2NzLmM6MzIxOiB3YXJu
aW5nOiDigJhiYXNl4oCZIG1heSBiZSB1c2VkIHVuaW5pdGlhbGl6ZWQgaW4gdGhpcyBmdW5jdGlv
bg0KPiANCj4gU2lnbmVkLW9mZi1ieTogSmFzd2luZGVyIFNpbmdoIFJhanB1dCA8amFzd2luZGVy
cmFqcHV0QGdtYWlsLmNvbT4NCg0KTG9va3MgZ29vZCB0byBtZSwgYXBwbGllZC4NCg==
