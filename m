From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] drivers: net: xgene: Rewrite loop in
 xgene_enet_ecc_init()
Date: Wed, 22 Oct 2014 15:34:36 -0400 (EDT)
Message-ID: <20141022.153436.93475594748933547.davem@davemloft.net>
References: <1413963581-24019-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: isubramanian@apm.com, kchudgar@apm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: geert@linux-m68k.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1413963581-24019-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogR2VlcnQgVXl0dGVyaG9ldmVuIDxnZWVydEBsaW51eC1tNjhrLm9yZz4NCkRhdGU6IFdl
ZCwgMjIgT2N0IDIwMTQgMDk6Mzk6NDEgKzAyMDANCg0KPiBkcml2ZXJzL25ldC9ldGhlcm5ldC9h
cG0veGdlbmUveGdlbmVfZW5ldF9zZ21hYy5jOiBJbiBmdW5jdGlvbiCheGdlbmVfZW5ldF9lY2Nf
aW5pdKI6DQo+IGRyaXZlcnMvbmV0L2V0aGVybmV0L2FwbS94Z2VuZS94Z2VuZV9lbmV0X3NnbWFj
LmM6MTI2OiB3YXJuaW5nOiChZGF0YaIgbWF5IGJlIHVzZWQgdW5pbml0aWFsaXplZCBpbiB0aGlz
IGZ1bmN0aW9uDQo+IA0KPiBEZXBlbmRpbmcgb24gdGhlIGFyYml0cmFyeSB2YWx1ZSBvbiB0aGUg
c3RhY2ssIHRoZSBsb29wIG1heSB0ZXJtaW5hdGUNCj4gdG9vIGVhcmx5LCBhbmQgY2F1c2UgYSBi
b2d1cyAtRU5PREVWIGZhaWx1cmUuDQo+IA0KPiBTaWduZWQtb2ZmLWJ5OiBHZWVydCBVeXR0ZXJo
b2V2ZW4gPGdlZXJ0QGxpbnV4LW02OGsub3JnPg0KPiAtLS0NCj4gdjI6IFJld3JpdGUgdGhlIGxv
b3AgaW5zdGVhZCBvZiBwcmUtaW5pdGlhbGl6aW5nIGRhdGEuDQoNCkkgaGF0ZSB0byBiZSBhIHBl
c3QsIGJ1dCBsaWtlIHRoZSBvdGhlciBwYXRjaCBvZiB5b3VyJ3MgSSB0aGluaw0KYSBkbyB7IH0g
d2hpbGUoKSB3b3JrcyBiZXN0IGhlcmUgYmVjYXVzZSB0aGUgaW50ZW50IGlzIGNsZWFybHkNCnRv
IHJ1biB0aGUgbG9vcCBhdCBsZWFzdCBvbmNlLCByaWdodD8NCg==
