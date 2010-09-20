From: Amit Salecha <amit.salecha@qlogic.com>
Subject: RE: [PATCH] qlcnic: dont assume NET_IP_ALIGN is 2
Date: Mon, 20 Sep 2010 06:16:31 -0500
Message-ID: <99737F4847ED0A48AECC9F4A1974A4B80F86F8018D@MNEXMB2.qlogic.org>
References: <1284700483-16397-1-git-send-email-amit.salecha@qlogic.com>
	 <1284700483-16397-2-git-send-email-amit.salecha@qlogic.com>
 <1284717448.3391.75.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexcashub1.qlogic.com ([198.70.193.61]:27404 "EHLO
	avexcashub1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756169Ab0ITLQg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Sep 2010 07:16:36 -0400
In-Reply-To: <1284717448.3391.75.camel@edumazet-laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogRXJpYyBEdW1hemV0IFtt
YWlsdG86ZXJpYy5kdW1hemV0QGdtYWlsLmNvbV0NCj4gU2VudDogRnJpZGF5LCBTZXB0ZW1iZXIg
MTcsIDIwMTAgMzoyNyBQTQ0KPiBUbzogQW1pdCBTYWxlY2hhDQo+IENjOiBuZXRkZXZAdmdlci5r
ZXJuZWwub3JnOyBBbWVlbiBSYWhtYW47IEFuaXJiYW4gQ2hha3JhYm9ydHk7IERhdmlkDQo+IE1p
bGxlcg0KPiBTdWJqZWN0OiBbUEFUQ0hdIHFsY25pYzogZG9udCBhc3N1bWUgTkVUX0lQX0FMSUdO
IGlzIDINCj4gDQo+IEFtaXQsIEkgbm90aWNlZCBmb2xsb3dpbmcgYnVnIGluIHFsbmljIGRyaXZl
ci4NCj4gDQo+IEFsc28sIHNrYi0+dHJ1ZXNpemUgc2hvdWxkIG5vdCBiZSBjaGFuZ2VkIGJ5IGRy
aXZlcnMsIHVubGVzcyBkZWFsaW5nDQo+IHdpdGggZnJhZ21lbnRzLg0KPiANCj4gV2hlbiB5b3Ug
aGF2ZSA6DQo+IAlza2ItPnRydWVzaXplID0gc2tiLT5sZW4gKyBzaXplb2Yoc3RydWN0IHNrX2J1
ZmYpOw0KPiANCj4geW91IGFyZSBseWluZyB0byBzdGFjayB0aGF0IGNhbiBxdWV1ZSBtYW55ICJz
bWFsbCIgVURQIHBhY2tldHMsDQo+IGFjY291dGluZyBmb3Igc21hbGwgcGFja2V0cyBpbiBzb2Nr
ZXQgcmN2YnVmLCB3aGlsZSB0aGUgdHJ1ZXNpemUgd2FzDQo+IHJlYWxseSAxNTMyICsgc2l6ZW9m
KHN0cnVjdCBza19idWZmKQ0KPiANCj4gQ291bGQgeW91IHRha2UgYSBsb29rID8NCj4gDQo+IA0K
VGhpcyBjYW4gYmUgY2xlYW5lZCB1cC4gDQpUaG91Z2ggSSBoYXZlIG9uZSBkb3VidC4gV2UgYXJl
IGFsbG9jYXRpbmcgbGFyZ2VyIHBhY2tldHMgdGhhbiB0aGUgYWN0dWFsIGRhdGEgdXNlZC4NCkRv
ZXNuJ3QgaXQgd2lsbCBicmVhayBhY2NvdW50aW5nID8NCg0KLUFtaXQNCg0K
