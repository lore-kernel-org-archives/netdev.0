From: YUAN Linyu <Linyu.Yuan@alcatel-sbell.com.cn>
Subject: RE: [PATCH net-next] net: ndisc.c: reduce size of
 __ndisc_fill_addr_option()
Date: Wed, 31 May 2017 01:00:44 +0000
Message-ID: <8729016553E3654398EA69218DA29EEF15BB2A4C@cnshjmbx02>
References: <1495836052-8377-1-git-send-email-cugyly@163.com>
 <20170529.233009.1607319852930338432.davem@davemloft.net>
 <1496115666.2618.9.camel@perches.com>
 <d774d7d7-5eb2-f107-b939-fbd3a8ac97a7@gmail.com>
 <8729016553E3654398EA69218DA29EEF15BB29A7@cnshjmbx02>
 <fe3573ad-90d1-6673-1e09-f6f1b47527bb@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Ahern <dsahern@gmail.com>, Joe Perches <joe@perches.com>,
        "David Miller" <davem@davemloft.net>,
        "cugyly@163.com" <cugyly@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cnshjsmin03.alcatel-sbell.com.cn ([116.246.26.71]:59587 "EHLO
        cnshjsmin03.alcatel-sbell.com.cn" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750902AbdEaBAs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 21:00:48 -0400
In-Reply-To: <fe3573ad-90d1-6673-1e09-f6f1b47527bb@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T2ssIEkgd2lsbCBzZW5kIHYyIGxhdGVyDQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0N
Cj4gRnJvbTogRGF2aWQgQWhlcm4gW21haWx0bzpkc2FoZXJuQGdtYWlsLmNvbV0NCj4gU2VudDog
V2VkbmVzZGF5LCBNYXkgMzEsIDIwMTcgODo0MCBBTQ0KPiBUbzogWVVBTiBMaW55dTsgRGF2aWQg
QWhlcm47IEpvZSBQZXJjaGVzOyBEYXZpZCBNaWxsZXI7IGN1Z3lseUAxNjMuY29tDQo+IENjOiBu
ZXRkZXZAdmdlci5rZXJuZWwub3JnDQo+IFN1YmplY3Q6IFJlOiBbUEFUQ0ggbmV0LW5leHRdIG5l
dDogbmRpc2MuYzogcmVkdWNlIHNpemUgb2YNCj4gX19uZGlzY19maWxsX2FkZHJfb3B0aW9uKCkN
Cj4gDQo+IE9uIDUvMzAvMTcgNjoyOSBQTSwgWVVBTiBMaW55dSB3cm90ZToNCj4gPj4+IHRoYXQg
ZnVuY3Rpb24gc2hvdWxkIGJlIGNvbnZlcnRlZCB0byBza2JfcHV0X3plcm8gb25jZSBpdCBoaXRz
IG5ldC1uZXh0Lg0KPiA+PiBJIHdpbGwgY2hlY2sgaXQNCj4gPiBJIGNhbid0IGZpbmQgc2tiX3B1
dF96ZXJvDQo+IA0KPiBJIGJlbGlldmUgdGhlIGRlY2lzaW9uIHdhcyB0byBwdXQgaXQgaW4gSm9o
YW5uZXMnIHRyZWUgYW5kIGl0IHdpbGwgbWFrZQ0KPiBpdHMgd2F5IHRvIERhdmVNJ3MgdHJlZS4g
R2l2ZSBzb21lIHRpbWUuDQo=
