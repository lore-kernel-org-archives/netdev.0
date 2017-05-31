From: YUAN Linyu <Linyu.Yuan@alcatel-sbell.com.cn>
Subject: RE: [PATCH net-next] net: ndisc.c: reduce size of
 __ndisc_fill_addr_option()
Date: Wed, 31 May 2017 00:07:05 +0000
Message-ID: <8729016553E3654398EA69218DA29EEF15BB2935@cnshjmbx02>
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
Received: from cnshjsmin03.alcatel-sbell.com.cn ([116.246.26.71]:61142 "EHLO
        cnshjsmin03.alcatel-sbell.com.cn" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751076AbdEaAWU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 20:22:20 -0400
In-Reply-To: <d774d7d7-5eb2-f107-b939-fbd3a8ac97a7@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogRGF2aWQgQWhlcm4gW21h
aWx0bzpkc2FoZXJuQGdtYWlsLmNvbV0NCj4gU2VudDogVHVlc2RheSwgTWF5IDMwLCAyMDE3IDEx
OjQyIEFNDQo+IFRvOiBKb2UgUGVyY2hlczsgRGF2aWQgTWlsbGVyOyBjdWd5bHlAMTYzLmNvbQ0K
PiBDYzogbmV0ZGV2QHZnZXIua2VybmVsLm9yZzsgWVVBTiBMaW55dQ0KPiBTdWJqZWN0OiBSZTog
W1BBVENIIG5ldC1uZXh0XSBuZXQ6IG5kaXNjLmM6IHJlZHVjZSBzaXplIG9mDQo+IF9fbmRpc2Nf
ZmlsbF9hZGRyX29wdGlvbigpDQo+IA0KPiBPbiA1LzI5LzE3IDk6NDEgUE0sIEpvZSBQZXJjaGVz
IHdyb3RlOg0KPiA+IE9uIE1vbiwgMjAxNy0wNS0yOSBhdCAyMzozMCAtMDQwMCwgRGF2aWQgTWls
bGVyIHdyb3RlOg0KPiA+PiBGcm9tOiB5dWFuIGxpbnl1IDxjdWd5bHlAMTYzLmNvbT4NCj4gPj4g
RGF0ZTogU2F0LCAyNyBNYXkgMjAxNyAwNjowMDo1MiArMDgwMA0KPiA+Pg0KPiA+Pj4gRnJvbTog
eXVhbiBsaW55dSA8TGlueXUuWXVhbkBhbGNhdGVsLXNiZWxsLmNvbS5jbj4NCj4gPj4+DQo+ID4+
PiBTaWduZWQtb2ZmLWJ5OiB5dWFuIGxpbnl1IDxMaW55dS5ZdWFuQGFsY2F0ZWwtc2JlbGwuY29t
LmNuPg0KPiA+PiBBcHBsaWVkLCB0aGFua3MuDQo+ID4gT0ssIGJ1dCBpcyBpdCByZWFsbHkgc2Fm
ZSB0aG91Z2g/DQo+ID4NCj4gPiBDb3VsZCAic3BhY2UiIChhbiBpbnQpIGV2ZXIgYmUgbmVnYXRp
dmUgYWZ0ZXINCj4gPiBzdWJ0cmFjdGluZyAicGFkIiBhbmQgImRhdGFfbGVuIj8NCj4gPg0KPiAN
Cj4gdGhhdCBmdW5jdGlvbiBzaG91bGQgYmUgY29udmVydGVkIHRvIHNrYl9wdXRfemVybyBvbmNl
IGl0IGhpdHMgbmV0LW5leHQuDQpJIHdpbGwgY2hlY2sgaXQNCg==
