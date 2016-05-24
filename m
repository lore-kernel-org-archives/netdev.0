From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ip_tunnel: enclose a code block in macro
 IS_ENABLED(CONFIG_IPV6)
Date: Mon, 23 May 2016 21:09:11 -0700 (PDT)
Message-ID: <20160523.210911.2013008845670427252.davem@davemloft.net>
References: <1464057597-3648-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
	<1464059658.5939.40.camel@edumazet-glaptop3.roam.corp.google.com>
	<4A265D43-913E-449E-8BA0-80A2B6930AD6@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: base64
Cc: eric.dumazet@gmail.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: yanhaishuang@cmss.chinamobile.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4A265D43-913E-449E-8BA0-80A2B6930AD6@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTog5Lil5rW35Y+MIDx5YW5oYWlzaHVhbmdAY21zcy5jaGluYW1vYmlsZS5jb20+DQpEYXRl
OiBUdWUsIDI0IE1heSAyMDE2IDExOjU1OjMxICswODAwDQoNCj4gDQo+PiBPbiBNYXkgMjQsIDIw
MTYsIGF0IDExOjE0IEFNLCBFcmljIER1bWF6ZXQgPGVyaWMuZHVtYXpldEBnbWFpbC5jb20+IHdy
b3RlOg0KPj4gDQo+PiBPbiBUdWUsIDIwMTYtMDUtMjQgYXQgMTA6MzkgKzA4MDAsIEhhaXNodWFu
ZyBZYW4gd3JvdGU6DQo+Pj4gRm9yIGlwdjYgY2FzZSwgZW5jbG9zZSB0aGUgY29kZSBibG9jayBp
biBtYWNybyBJU19FTkFCTEVEKENPTkZJR19JUFY2KS4NCj4+PiANCj4+PiAtLS0NCj4+PiBDaGFu
Z2VzIGluIHYyOg0KPj4+ICAtIFBsYWNlIHRoZSAiI2lmIElTX0VOQUJMRUQiIGJsb2NrIGJlZm9y
ZSB0aGUgIn0gZWxzZSBpZg0KPj4+ICguLikgeyIgcGllY2UgYW5kIHRoZSAiI2VuZGlmIiBiZWZv
cmUgdGhlIGNsb3NpbmcgYnJhY2UgYW5kIHRoaXMNCj4+PiBiZWNvbWVzIG11Y2ggZWFzaWVyIHRv
IGxvb2sgYXQuDQo+PiANCj4+IF9XaHlfIGlzIHRoaXMgcGF0Y2ggbmVlZGVkID8NCj4+IA0KPj4g
UGxlYXNlIGRlc2NyaWJlIGluIHRoZSBjaGFuZ2Vsb2cgd2hhdCBfYWN0dWFsXyBwcm9ibGVtIHlv
dSBhcmUgdHJ5aW5nIHRvDQo+PiBhZGRyZXNzLg0KPj4gDQo+PiBXZSBoYXZlIG1hbnkgcG9pbnRz
IGluIHRoZSBrZXJuZWwgdXNpbmcgaXB2Nl9nZXRfZHNmaWVsZCgpIGV2ZW4gaWYNCj4+IENPTkZJ
R19JUFY2PW4sIGFuZCBpdCBzZWVtcyBmaW5lIHRvIG1lIGF0IGxlYXN0Lg0KPj4gDQo+PiBUaGFu
a3MuDQo+PiANCj4+IA0KPj4gDQo+IA0KPiBZZXMsIHlvdeKAmXJlIHJpZ2h0LCBidXQgSSB0aGlu
ayBhZGQgdGhpcyBwYXRjaCBzZWVtcyBtb3JlIHJlYXNvbmFibGUgaW4gY29kaW5nLg0KDQpObywg
aXQgaXNuJ3QgbW9yZSByZWFzb25hYmxlIGF0IGFsbC4NCg0KV2UgaGF2ZSB0aGUgYmFja3VwIGlt
cGxlbWVudGF0aW9ucyB3aGVuIENPTkZJR19JUFY2IGlzIGRpc2FibGVkDQpfRVhBQ1RMWV8gdG8g
YXZvaWQgaWZkZWYgY3JhcCBsaWtlIHRoaXMgaW4gQyBmaWxlcy4NCg==
