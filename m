From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers: net: xgene: Pre-initialize ret in
 xgene_enet_get_resources()
Date: Sun, 28 Jun 2015 16:54:48 -0700 (PDT)
Message-ID: <20150628.165448.1251421470587728980.davem@davemloft.net>
References: <1435238009-29037-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: stripathi@apm.com, isubramanian@apm.com, kchudgar@apm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: geert@linux-m68k.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1435238009-29037-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogR2VlcnQgVXl0dGVyaG9ldmVuIDxnZWVydEBsaW51eC1tNjhrLm9yZz4NCkRhdGU6IFRo
dSwgMjUgSnVuIDIwMTUgMTU6MTM6MjkgKzAyMDANCg0KPiBJZiBDT05GSUdfQUNQST1uOg0KPiAN
Cj4gICAgIGRyaXZlcnMvbmV0L2V0aGVybmV0L2FwbS94Z2VuZS94Z2VuZV9lbmV0X21haW4uYzog
SW4gZnVuY3Rpb24goXhnZW5lX2VuZXRfZ2V0X3Jlc291cmNlc6I6DQo+ICAgICBkcml2ZXJzL25l
dC9ldGhlcm5ldC9hcG0veGdlbmUveGdlbmVfZW5ldF9tYWluLmM6OTUxOiB3YXJuaW5nOiChcmV0
oiBtYXkgYmUgdXNlZCB1bmluaXRpYWxpemVkIGluIHRoaXMgZnVuY3Rpb24NCj4gDQo+IElmIHRo
ZSBkcml2ZXIgaXMgYm91bmQgdG8gYSBsZWdhY3kgcGxhdGZvcm0gZGV2aWNlLCByZXQgd2lsbCBj
b250YWluDQo+IGFyYml0cmFyeSBkYXRhLiBJZiBpdCBpcyBub24temVybywgaXQgd2lsbCBiZSBy
ZXR1cm5lZCB0byB0aGUgY2FsbGVyIGFzDQo+IGFuIGVycm9yIGNvZGUuDQo+IA0KPiBTaWduZWQt
b2ZmLWJ5OiBHZWVydCBVeXR0ZXJob2V2ZW4gPGdlZXJ0QGxpbnV4LW02OGsub3JnPg0KDQpBcHBs
aWVkLg0K
