From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next] mlx5: Add MLX5_SET64_VCHK to fix BUILD_BUG_ON
Date: Tue, 11 Oct 2016 10:50:07 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB01E62DC@AcuExch.aculab.com>
References: <20161011042222.2366145-1-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "kernel-team@fb.com" <kernel-team@fb.com>
To: 'Tom Herbert' <tom@herbertland.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "saeedm@mellanox.com" <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.182]:58216 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751203AbcJKLVD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2016 07:21:03 -0400
In-Reply-To: <20161011042222.2366145-1-tom@herbertland.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogVG9tIEhlcmJlcnQNCj4gU2VudDogMTEgT2N0b2JlciAyMDE2IDA1OjIyDQouLi4NCj4g
Rml4IGlzIHRvIGNyZWF0ZSBNTFg1X1NFVDY0X1ZDSEsgdGhhdCB0YWtlcyBhbiBhZGRpdGlvbmFs
IGFyZ3VtZW50DQo+IHRoYXQgaXMgYSBjb25zdGFudC4gVGhlcmUgYXJlIHR3byBjYWxsZXJzIG9m
IE1MWDVfU0VUNjQgdGhhdCBhcmUNCj4gdHJ5aW5nIHRvIGdldCBhIHZhcmlhYmxlIG9mZnNldCwg
Y2hhbmdlIHRob3NlIHRvIGNhbGwgTUxYNV9TRVQ2NF9WQ0hLDQo+IHBhc3NpbmcgcGFzWzBdIGFz
IHRoZSBhcmd1bWVudCB0byB1c2UgaW4gdGhlIG9mZnNldCBjaGVjay4NCg0KSSB0aGluayBJJ2Qg
c2VwYXJhdGUgdGhlIGFycmF5IGluZGV4IGluc3RlYWQuDQpTb21ldGhpbmcgbGlrZToNCg0KI2Rl
ZmluZSBNTFg1X1NFVDY0X0lOREVYRUQodHlwLCBwLCBmbGQsIG5keCwgdikgZG8geyBcDQoJQlVJ
TERfQlVHX09OKF9fbWx4NV9iaXRfb2ZmKHR5cCwgZmxkKSAlIDY0KTsgXA0KCV9fTUxYNV9TRVQ2
NCh0eXAsIHAsIGZsZFtuZHhdLCB2KTsgXA0KfSB3aGlsZSAoMCkNCg0KCURhdmlkDQo=
