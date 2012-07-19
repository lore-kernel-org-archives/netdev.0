From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: tcp: remove per net tcp_sock
Date: Thu, 19 Jul 2012 08:45:03 -0700 (PDT)
Message-ID: <20120719.084503.136853790544876708.davem@davemloft.net>
References: <1342688332.2626.4001.camel@edumazet-glaptop>
	<20120719.083544.1223522161508413373.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, therbert@google.com, wsommerfeld@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45511 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750901Ab2GSPpJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 11:45:09 -0400
In-Reply-To: <20120719.083544.1223522161508413373.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRGF2aWQgTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0Pg0KRGF0ZTogVGh1LCAxOSBK
dWwgMjAxMiAwODozNTo0NCAtMDcwMCAoUERUKQ0KDQo+IExvb2tzIGdyZWF0LCBhcHBsaWVkLCB0
aGFua3MgRXJpYy4NCg0KSSB0YWtlIHRoYXQgYmFjaywgaXQgZG9lc24ndCBidWlsZDoNCg0KbmV0
L2lwdjQvaXBfb3V0cHV0LmM6IEluIGZ1bmN0aW9uIKFpcF9zZW5kX3VuaWNhc3RfcmVwbHmiOg0K
bmV0L2lwdjQvaXBfb3V0cHV0LmM6MTQ4MToxOiBlcnJvcjogc2VjdGlvbiBhdHRyaWJ1dGUgY2Fu
bm90IGJlIHNwZWNpZmllZCBmb3IgbG9jYWwgdmFyaWFibGVzDQpuZXQvaXB2NC9pcF9vdXRwdXQu
YzoxNDgxOjE6IGVycm9yOiBzZWN0aW9uIGF0dHJpYnV0ZSBjYW5ub3QgYmUgc3BlY2lmaWVkIGZv
ciBsb2NhbCB2YXJpYWJsZXMNCm5ldC9pcHY0L2lwX291dHB1dC5jOjE0ODE6MTogZXJyb3I6IGRl
Y2xhcmF0aW9uIG9mIKFfX3BjcHVfdW5pcXVlX3VuaWNhc3Rfc29ja6Igd2l0aCBubyBsaW5rYWdl
IGZvbGxvd3MgZXh0ZXJuIGRlY2xhcmF0aW9uDQpuZXQvaXB2NC9pcF9vdXRwdXQuYzoxNDgxOjE6
IG5vdGU6IHByZXZpb3VzIGRlY2xhcmF0aW9uIG9mIKFfX3BjcHVfdW5pcXVlX3VuaWNhc3Rfc29j
a6Igd2FzIGhlcmUNCm5ldC9pcHY0L2lwX291dHB1dC5jOjE0ODE6OTogZXJyb3I6IHNlY3Rpb24g
YXR0cmlidXRlIGNhbm5vdCBiZSBzcGVjaWZpZWQgZm9yIGxvY2FsIHZhcmlhYmxlcw0KbmV0L2lw
djQvaXBfb3V0cHV0LmM6MTQ4MTo5OiBlcnJvcjogd2VhayBkZWNsYXJhdGlvbiBvZiChdW5pY2Fz
dF9zb2NroiBtdXN0IGJlIHB1YmxpYw0K
