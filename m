From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: vxge: Fix checkstack warning in vxge_probe()
Date: Wed, 02 Jun 2010 05:51:31 -0700 (PDT)
Message-ID: <20100602.055131.135985480.davem@davemloft.net>
References: <20100528175735.30903.21134.sendpatchset@prarit.bos.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, mschmidt@redhat.com
To: prarit@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53680
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758064Ab0FBMvV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 08:51:21 -0400
In-Reply-To: <20100528175735.30903.21134.sendpatchset@prarit.bos.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogUHJhcml0IEJoYXJnYXZhIDxwcmFyaXRAcmVkaGF0LmNvbT4NCkRhdGU6IEZyaSwgMjgg
TWF5IDIwMTAgMTQ6MDE6NDkgLTA0MDANCg0KPiBMaW51eCAyLjYuMzMgcmVwb3J0cyB0aGlzIGNo
ZWNrc3RhY2sgd2FybmluZzoNCj4gDQo+IGRyaXZlcnMvbmV0L3Z4Z2UvdnhnZS1tYWluLmM6IElu
IGZ1bmN0aW9uICd2eGdlX3Byb2JlJzoNCj4gZHJpdmVycy9uZXQvdnhnZS92eGdlLW1haW4uYzo0
NDA5OiB3YXJuaW5nOiB0aGUgZnJhbWUgc2l6ZSBvZiAxMDI4IGJ5dGVzIGlzIGxhcmdlciB0aGFu
IDEwMjQgYnl0ZXMNCj4gDQo+IFRoaXMgd2FybmluZyBkb2VzIG5vdCBvY2N1ciBpbiB0aGUgbGF0
ZXN0IGxpbnV4LTIuNiBvciBsaW51eC1uZXh0LCBob3dldmVyLA0KPiB3aGVuIEkgZG8gYSAnbWFr
ZSAtajMyIENPTkZJR19GUkFNRV9XQVJOPTUxMicgaW5zdGVhZCBvZiAxMDI0IEkgc2VlDQo+IA0K
PiBkcml2ZXJzL25ldC92eGdlL3Z4Z2UtbWFpbi5jOiBJbiBmdW5jdGlvbiChdnhnZV9wcm9iZaI6
DQo+IGRyaXZlcnMvbmV0L3Z4Z2UvdnhnZS1tYWluLmM6NDQyMzogd2FybmluZzogdGhlIGZyYW1l
IHNpemUgb2YgMTAyNCBieXRlcyBpcyBsYXJnZXIgdGhhbiA1MTIgYnl0ZXMNCj4gDQo+IFRoaXMg
cGF0Y2ggbW92ZXMgdGhlIGxhcmdlIHZ4Z2VfY29uZmlnIHN0cnVjdCBvZmYgdGhlIHN0YWNrLg0K
PiANCj4gU2lnbmVkLW9mZi1ieTogUHJhcml0IEJoYXJnYXZhIDxwcmFyaXRAcmVkaGF0LmNvbT4N
Cg0KQXBwbGllZCB0byBuZXQtbmV4dC0yLjYsIHRoYW5rcy4NCg==
