From: YUAN Linyu <Linyu.Yuan@alcatel-sbell.com.cn>
Subject: RE: [PATCH net-next] net: ndisc.c: reduce size of
 __ndisc_fill_addr_option()
Date: Wed, 31 May 2017 00:29:05 +0000
Message-ID: <8729016553E3654398EA69218DA29EEF15BB29A7@cnshjmbx02>
References: <1495836052-8377-1-git-send-email-cugyly@163.com>
 <20170529.233009.1607319852930338432.davem@davemloft.net>
 <1496115666.2618.9.camel@perches.com>
 <d774d7d7-5eb2-f107-b939-fbd3a8ac97a7@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Ahern <dsahern@gmail.com>, Joe Perches <joe@perches.com>,
        "David Miller" <davem@davemloft.net>,
        "cugyly@163.com" <cugyly@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cnshjsmin03.alcatel-sbell.com.cn ([116.246.26.71]:54251 "EHLO
        cnshjsmin03.alcatel-sbell.com.cn" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750985AbdEaA3H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 20:29:07 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiA+IC0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+ID4gRnJvbTogRGF2aWQgQWhlcm4gW21h
aWx0bzpkc2FoZXJuQGdtYWlsLmNvbV0NCj4gPiBTZW50OiBUdWVzZGF5LCBNYXkgMzAsIDIwMTcg
MTE6NDIgQU0NCj4gPiBUbzogSm9lIFBlcmNoZXM7IERhdmlkIE1pbGxlcjsgY3VneWx5QDE2My5j
b20NCj4gPiBDYzogbmV0ZGV2QHZnZXIua2VybmVsLm9yZzsgWVVBTiBMaW55dQ0KPiA+IFN1Ympl
Y3Q6IFJlOiBbUEFUQ0ggbmV0LW5leHRdIG5ldDogbmRpc2MuYzogcmVkdWNlIHNpemUgb2YNCj4g
PiBfX25kaXNjX2ZpbGxfYWRkcl9vcHRpb24oKQ0KPiA+DQo+ID4gT24gNS8yOS8xNyA5OjQxIFBN
LCBKb2UgUGVyY2hlcyB3cm90ZToNCj4gPiA+IE9uIE1vbiwgMjAxNy0wNS0yOSBhdCAyMzozMCAt
MDQwMCwgRGF2aWQgTWlsbGVyIHdyb3RlOg0KPiA+ID4+IEZyb206IHl1YW4gbGlueXUgPGN1Z3ls
eUAxNjMuY29tPg0KPiA+ID4+IERhdGU6IFNhdCwgMjcgTWF5IDIwMTcgMDY6MDA6NTIgKzA4MDAN
Cj4gPiA+Pg0KPiA+ID4+PiBGcm9tOiB5dWFuIGxpbnl1IDxMaW55dS5ZdWFuQGFsY2F0ZWwtc2Jl
bGwuY29tLmNuPg0KPiA+ID4+Pg0KPiA+ID4+PiBTaWduZWQtb2ZmLWJ5OiB5dWFuIGxpbnl1IDxM
aW55dS5ZdWFuQGFsY2F0ZWwtc2JlbGwuY29tLmNuPg0KPiA+ID4+IEFwcGxpZWQsIHRoYW5rcy4N
Cj4gPiA+IE9LLCBidXQgaXMgaXQgcmVhbGx5IHNhZmUgdGhvdWdoPw0KPiA+ID4NCj4gPiA+IENv
dWxkICJzcGFjZSIgKGFuIGludCkgZXZlciBiZSBuZWdhdGl2ZSBhZnRlcg0KPiA+ID4gc3VidHJh
Y3RpbmcgInBhZCIgYW5kICJkYXRhX2xlbiI/DQo+ID4gPg0KPiA+DQo+ID4gdGhhdCBmdW5jdGlv
biBzaG91bGQgYmUgY29udmVydGVkIHRvIHNrYl9wdXRfemVybyBvbmNlIGl0IGhpdHMgbmV0LW5l
eHQuDQo+IEkgd2lsbCBjaGVjayBpdA0KSSBjYW4ndCBmaW5kIHNrYl9wdXRfemVybw0K
