From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: fix compile error in skb_orphan_partial()
Date: Wed, 17 May 2017 15:11:20 -0400 (EDT)
Message-ID: <20170517.151120.2266257434113805990.davem@davemloft.net>
References: <f63533e7-edd3-4c0d-ddff-e3409d15abc6@infradead.org>
        <CAP=VYLoYkz1HE4yOHVGQvBanDtpkWhtHBMvbeuyd8PtNFCivRQ@mail.gmail.com>
        <1494966473.6465.13.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: paul.gortmaker@windriver.com, rdunlap@infradead.org,
        sfr@canb.auug.org.au, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35668 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751442AbdEQTLW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 15:11:22 -0400
In-Reply-To: <1494966473.6465.13.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0IDxlcmljLmR1bWF6ZXRAZ21haWwuY29tPg0KRGF0ZTogVHVlLCAx
NiBNYXkgMjAxNyAxMzoyNzo1MyAtMDcwMA0KDQo+IEZyb206IEVyaWMgRHVtYXpldCA8ZWR1bWF6
ZXRAZ29vZ2xlLmNvbT4NCj4gDQo+IElmIENPTkZJR19JTkVUIGlzIG5vdCBzZXQsIG5ldC9jb3Jl
L3NvY2suYyBjYW4gbm90IGNvbXBpbGUgOg0KPiANCj4gbmV0L2NvcmUvc29jay5jOiBJbiBmdW5j
dGlvbiChc2tiX29ycGhhbl9wYXJ0aWFsojoNCj4gbmV0L2NvcmUvc29jay5jOjE4MTA6MjogZXJy
b3I6IGltcGxpY2l0IGRlY2xhcmF0aW9uIG9mIGZ1bmN0aW9uDQo+IKFza2JfaXNfdGNwX3B1cmVf
YWNroiBbLVdlcnJvcj1pbXBsaWNpdC1mdW5jdGlvbi1kZWNsYXJhdGlvbl0NCj4gICBpZiAoc2ti
X2lzX3RjcF9wdXJlX2Fjayhza2IpKQ0KPiAgIF4NCj4gDQo+IEZpeCB0aGlzIGJ5IGFsd2F5cyBp
bmNsdWRpbmcgPG5ldC90Y3AuaD4NCj4gDQo+IEZpeGVzOiBmNmJhOGQzM2NmYmIgKCJuZXRlbTog
Zml4IHNrYl9vcnBoYW5fcGFydGlhbCgpIikNCj4gU2lnbmVkLW9mZi1ieTogRXJpYyBEdW1hemV0
IDxlZHVtYXpldEBnb29nbGUuY29tPg0KPiBSZXBvcnRlZC1ieTogUGF1bCBHb3J0bWFrZXIgPHBh
dWwuZ29ydG1ha2VyQHdpbmRyaXZlci5jb20+DQo+IFJlcG9ydGVkLWJ5OiBSYW5keSBEdW5sYXAg
PHJkdW5sYXBAaW5mcmFkZWFkLm9yZz4NCj4gUmVwb3J0ZWQtYnk6IFN0ZXBoZW4gUm90aHdlbGwg
PHNmckBjYW5iLmF1dWcub3JnLmF1Pg0KDQpBcHBsaWVkIGFuZCBxdWV1ZWQgdXAgZm9yIC1zdGFi
bGUsIHRoYW5rcyBFcmljLg0K
