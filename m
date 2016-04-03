From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/8] add TX timestamping via cmsg
Date: Sat, 02 Apr 2016 21:27:29 -0400 (EDT)
Message-ID: <20160402.212729.2129485115379390591.davem@davemloft.net>
References: <1459523080-29329-1-git-send-email-soheil.kdev@gmail.com>
	<20160402.211942.598210499165268433.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, willemb@google.com, edumazet@google.com,
	ycheng@google.com, ncardwell@google.com, kafai@fb.com,
	soheil@google.com
To: soheil.kdev@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53591 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750941AbcDCB1d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Apr 2016 21:27:33 -0400
In-Reply-To: <20160402.211942.598210499165268433.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRGF2aWQgTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0Pg0KRGF0ZTogU2F0LCAwMiBB
cHIgMjAxNiAyMToxOTo0MiAtMDQwMCAoRURUKQ0KDQo+IFNlcmllcyBhcHBsaWVkLCB0aGFua3Mu
DQoNCkkgaGFkIHRvIHJldmVydCwgdGhpcyBicmVha3MgdGhlIGJ1aWxkOg0KDQpuZXQvbDJ0cC9s
MnRwX2lwNi5jOiBJbiBmdW5jdGlvbiChbDJ0cF9pcDZfc2VuZG1zZ6I6DQpuZXQvbDJ0cC9sMnRw
X2lwNi5jOjU2NTo5OiBlcnJvcjogdG9vIGZldyBhcmd1bWVudHMgdG8gZnVuY3Rpb24goWlwNl9k
YXRhZ3JhbV9zZW5kX2N0bKINCiAgIGVyciA9IGlwNl9kYXRhZ3JhbV9zZW5kX2N0bChzb2NrX25l
dChzayksIHNrLCBtc2csICZmbDYsIG9wdCwNCiAgICAgICAgIF4NCkluIGZpbGUgaW5jbHVkZWQg
ZnJvbSBuZXQvbDJ0cC9sMnRwX2lwNi5jOjMzOjA6DQppbmNsdWRlL25ldC90cmFuc3BfdjYuaDo0
Mzo1OiBub3RlOiBkZWNsYXJlZCBoZXJlDQogaW50IGlwNl9kYXRhZ3JhbV9zZW5kX2N0bChzdHJ1
Y3QgbmV0ICpuZXQsIHN0cnVjdCBzb2NrICpzaywgc3RydWN0IG1zZ2hkciAqbXNnLA0KICAgICBe
DQpuZXQvbDJ0cC9sMnRwX2lwNi5jOjYyNTo4OiBlcnJvcjogdG9vIGZldyBhcmd1bWVudHMgdG8g
ZnVuY3Rpb24goWlwNl9hcHBlbmRfZGF0YaINCiAgZXJyID0gaXA2X2FwcGVuZF9kYXRhKHNrLCBp
cF9nZW5lcmljX2dldGZyYWcsIG1zZywNCiAgICAgICAgXg0KSW4gZmlsZSBpbmNsdWRlZCBmcm9t
IGluY2x1ZGUvbmV0L2luZXRwZWVyLmg6MTU6MCwNCiAgICAgICAgICAgICAgICAgZnJvbSBpbmNs
dWRlL25ldC9yb3V0ZS5oOjI4LA0KICAgICAgICAgICAgICAgICBmcm9tIGluY2x1ZGUvbmV0L2lw
Lmg6MzEsDQogICAgICAgICAgICAgICAgIGZyb20gbmV0L2wydHAvbDJ0cF9pcDYuYzoyMzoNCmlu
Y2x1ZGUvbmV0L2lwdjYuaDo4NjU6NTogbm90ZTogZGVjbGFyZWQgaGVyZQ0KIGludCBpcDZfYXBw
ZW5kX2RhdGEoc3RydWN0IHNvY2sgKnNrLA0KICAgICBeDQo=
