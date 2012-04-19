From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix compile error of leaking kmemleak.h header
Date: Thu, 19 Apr 2012 00:13:27 -0400 (EDT)
Message-ID: <20120419.001327.244606232903128879.davem@davemloft.net>
References: <4F8F8F1A.6020000@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: majianpeng@gmail.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, davidshan@tencent.com
To: shanwei88@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44066 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1749667Ab2DSEOO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 00:14:14 -0400
In-Reply-To: <4F8F8F1A.6020000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogU2hhbiBXZWkgPHNoYW53ZWk4OEBnbWFpbC5jb20+DQpEYXRlOiBUaHUsIDE5IEFwciAy
MDEyIDEyOjA1OjQ2ICswODAwDQoNCj4gRnJvbTogU2hhbiBXZWkgPGRhdmlkc2hhbkB0ZW5jZW50
LmNvbT4NCj4gDQo+IG5ldC9jb3JlL3N5c2N0bF9uZXRfY29yZS5jOiBJbiBmdW5jdGlvbiChc3lz
Y3RsX2NvcmVfaW5pdKI6DQo+IG5ldC9jb3JlL3N5c2N0bF9uZXRfY29yZS5jOjI1OTogZXJyb3I6
IGltcGxpY2l0IGRlY2xhcmF0aW9uIG9mIGZ1bmN0aW9uIKFrbWVtbGVha19ub3RfbGVha6INCj4g
DQo+IHdpdGggc2FtZSBlcnJvciBpbiBuZXQvaXB2NC9yb3V0ZS5jDQo+IA0KPiBTaWduZWQtb2Zm
LWJ5OiBTaGFuIFdlaSA8ZGF2aWRzaGFuQHRlbmNlbnQuY29tPg0KDQpBcHBsaWVkLCB0aGFua3Mu
DQo=
