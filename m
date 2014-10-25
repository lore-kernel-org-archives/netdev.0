From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] drivers: net: xgene: Rewrite buggy loop in
 xgene_enet_ecc_init()
Date: Sat, 25 Oct 2014 17:05:51 -0400 (EDT)
Message-ID: <20141025.170551.1379400739319408704.davem@davemloft.net>
References: <1414052753-10183-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: isubramanian@apm.com, kchudgar@apm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: geert@linux-m68k.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1414052753-10183-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogR2VlcnQgVXl0dGVyaG9ldmVuIDxnZWVydEBsaW51eC1tNjhrLm9yZz4NCkRhdGU6IFRo
dSwgMjMgT2N0IDIwMTQgMTA6MjU6NTMgKzAyMDANCg0KPiBkcml2ZXJzL25ldC9ldGhlcm5ldC9h
cG0veGdlbmUveGdlbmVfZW5ldF9zZ21hYy5jOiBJbiBmdW5jdGlvbiCheGdlbmVfZW5ldF9lY2Nf
aW5pdKI6DQo+IGRyaXZlcnMvbmV0L2V0aGVybmV0L2FwbS94Z2VuZS94Z2VuZV9lbmV0X3NnbWFj
LmM6MTI2OiB3YXJuaW5nOiChZGF0YaIgbWF5IGJlIHVzZWQgdW5pbml0aWFsaXplZCBpbiB0aGlz
IGZ1bmN0aW9uDQo+IA0KPiBEZXBlbmRpbmcgb24gdGhlIGFyYml0cmFyeSB2YWx1ZSBvbiB0aGUg
c3RhY2ssIHRoZSBsb29wIG1heSB0ZXJtaW5hdGUNCj4gdG9vIGVhcmx5LCBhbmQgY2F1c2UgYSBi
b2d1cyAtRU5PREVWIGZhaWx1cmUuDQo+IA0KPiBTaWduZWQtb2ZmLWJ5OiBHZWVydCBVeXR0ZXJo
b2V2ZW4gPGdlZXJ0QGxpbnV4LW02OGsub3JnPg0KPiAtLS0NCj4gdjM6DQo+ICAgLSBVc2UgImRv
IHsgLi4uIH0gd2hpbGUgKC4uLik7IiBpbnN0ZWFkIG9mICJmb3IgKC4uLikgeyAuLi4gfSIsDQo+
IHYyOg0KPiAgIC0gUmV3cml0ZSB0aGUgbG9vcCBpbnN0ZWFkIG9mIHByZS1pbml0aWFsaXppbmcg
ZGF0YS4NCg0KQXBwbGllZCwgdGhhbmsgeW91Lg0K
