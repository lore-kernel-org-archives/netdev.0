From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net:set valid name before calling ndo_init()
Date: Thu, 12 May 2011 17:37:20 -0400 (EDT)
Message-ID: <20110512.173720.2197201133223265905.davem@davemloft.net>
References: <1305207541-13311-1-git-send-email-panweiping3@gmail.com>
	<1305214382.3795.28.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: base64
Cc: panweiping3@gmail.com, therbert@google.com,
	mirq-linux@rere.qmqm.pl, bhutchings@solarflare.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1305214382.3795.28.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogRXJpYyBEdW1hemV0IDxlcmljLmR1bWF6ZXRAZ21haWwuY29tPg0KRGF0ZTogVGh1LCAx
MiBNYXkgMjAxMSAxNzozMzowMiArMDIwMA0KDQo+IExlIGpldWRpIDEyIG1haSAyMDExIMOgIDIx
OjM5ICswODAwLCBXZWlwaW5nIFBhbijmvZjljavlubMpIGEgw6ljcml0IDoNCj4+IEZyb206IFBh
biBXZWlwaW5nIDxwYW53ZWlwaW5nM0BnbWFpbC5jb20+DQo+PiANCj4+IEEgYnVnIG9mIGJvbmRp
bmcgd2FzIGludmxvdmVkIGJ5IGU4MTVkMTlmZmUwMmJkZmRhMTI2MDk0OWVmMmIxODA2MTcxLA0K
Pj4gc2VlIGV4YW1wbGUgMSBhbmQgMi4NCj4+IA0KPiANCj4gSSBjYW50IGZpbmQgZTgxNWQxOWZm
ZTAyYmRmZGExMjYwOTQ5ZWYyYjE4MDYxNzEgaW4gbmV0LW5leHQtMi42DQo+IA0KPiBidXQgSSBk
byBmaW5kIDFjNWNhZTgxNWQxOWZmZTAyYmRmZGExMjYwOTQ5ZWYyYjE4MDYxNzENCj4gDQo+IFBs
ZWFzZSBhbHdheXMgdXNlIGZvbGxvd2luZyB3aGVuIHJlZmVycmluZyB0byBhIGNvbW1pdCA6DQo+
IA0KPiAuLi4gaW4gY29tbWl0IDFjNWNhZTgxNWQxOSAobmV0OiBjYWxsIGRldl9hbGxvY19uYW1l
IGZyb20NCj4gcmVnaXN0ZXJfbmV0ZGV2aWNlKSAuLi4NCj4gDQo+IC0ganVzdCBsaW1pdCB0byBf
Zmlyc3RfIDEyIGNoYXJzLCBubyBuZWVkIHRvIGhhdmUgZnVsbCBsZW5ndGgNCj4gLSBnaXZlIHRo
ZSBjb21taXQgdGl0bGUNCg0KUGFuLCBwbGVhc2UgZml4IHRoaXMgY29tbWl0IHJlZmVyZW5jZSB1
cCBhbmQgcmVzdWJtaXQgeW91ciBwYXRjaC4NCg==
