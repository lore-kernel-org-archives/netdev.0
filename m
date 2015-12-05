From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: keep existing flags when setting IFA_F_OPTIMISTIC
Date: Sat, 05 Dec 2015 18:10:35 -0500 (EST)
Message-ID: <20151205.181035.735727652195080561.davem@davemloft.net>
References: <1449234908-29623-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, ek@google.com, fgont@si6networks.com,
	lorenzo@google.com, hideaki.yoshifuji@miraclelinux.com,
	hannes@stressinduktion.org
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39655 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751676AbbLEXKi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Dec 2015 18:10:38 -0500
In-Reply-To: <1449234908-29623-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogQmrDuHJuIE1vcmsgPGJqb3JuQG1vcmsubm8+DQpEYXRlOiBGcmksICA0IERlYyAyMDE1
IDE0OjE1OjA4ICswMTAwDQoNCj4gQ29tbWl0IDY0MjM2ZjNmM2Q3NCAoImlwdjY6IGludHJvZHVj
ZSBJRkFfRl9TVEFCTEVfUFJJVkFDWSBmbGFnIikNCj4gZmFpbGVkIHRvIHVwZGF0ZSB0aGUgc2V0
dGluZyBvZiB0aGUgSUZBX0ZfT1BUSU1JU1RJQyBmbGFnLCBjYXVzaW5nDQo+IHRoZSBJRkFfRl9T
VEFCTEVfUFJJVkFDWSBmbGFnIHRvIGJlIGxvc3QgaWYgSUZBX0ZfT1BUSU1JU1RJQyBpcyBzZXQu
DQo+IA0KPiBDYzogRXJpayBLbGluZSA8ZWtAZ29vZ2xlLmNvbT4NCj4gQ2M6IEZlcm5hbmRvIEdv
bnQgPGZnb250QHNpNm5ldHdvcmtzLmNvbT4NCj4gQ2M6IExvcmVuem8gQ29saXR0aSA8bG9yZW56
b0Bnb29nbGUuY29tPg0KPiBDYzogWU9TSElGVUpJIEhpZGVha2kv5ZCJ6Jek6Iux5piOIDxoaWRl
YWtpLnlvc2hpZnVqaUBtaXJhY2xlbGludXguY29tPg0KPiBDYzogSGFubmVzIEZyZWRlcmljIFNv
d2EgPGhhbm5lc0BzdHJlc3NpbmR1a3Rpb24ub3JnPg0KPiBGaXhlczogNjQyMzZmM2YzZDc0ICgi
aXB2NjogaW50cm9kdWNlIElGQV9GX1NUQUJMRV9QUklWQUNZIGZsYWciKQ0KPiBTaWduZWQtb2Zm
LWJ5OiBCasO4cm4gTW9yayA8Ympvcm5AbW9yay5ubz4NCg0KQXBwbGllZCBhbmQgcXVldWVkIHVw
IGZvciAtc3RhYmxlLCB0aGFua3MhDQo=
