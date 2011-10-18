From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: RE: [PATCH 3/7] mlx4_en: Incoming traffic alignment optimizations
Date: Tue, 18 Oct 2011 08:52:03 +0000
Message-ID: <953B660C027164448AE903364AC447D2235EEC59@MTLDAG01.mtl.com>
References: <4E9C8D53.5040006@mellanox.co.il>
	 <1318902799.2571.26.camel@edumazet-laptop>
	 <953B660C027164448AE903364AC447D2235EEB7E@MTLDAG01.mtl.com>
 <1318927207.2657.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog120.obsmtp.com ([207.126.144.149]:39185 "HELO
	eu1sys200aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754549Ab1JRIy6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 04:54:58 -0400
In-Reply-To: <1318927207.2657.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiANCj4gT2ggbXkuLi4NCj4gDQo+IE9mIGNvdXJzZSB5b3UgYXJlIGF3YXJlIHRoYXQgdGhlICd0
cnVlc2l6ZScgc3R1ZmYgYXJvdW5kIG1lYW5zIHRoYXQgdXNpbmcgYmlnIGZyYWcgc2l6ZSB3aWxs
IHByb2JhYmx5IGxvd2VyIHlvdXIgcGVyZm9ybWFuY2UgbnVtYmVyLCB1bmxlc3MgeW91IGFsbG93
IHByb3RvY29sIHN0YWNrcyB0byB1c2UgbW9yZSByYW0gPw0KPiANCj4gT25seSBwb3NzaWJsZSBk
cmF3YmFjayB1c2luZyA1MTIgYnl0ZXMgaW5zdGVhZCBvZiAyMDQ4IGlzIHRoZSBjYWNoZS1saW5l
IGJvdW5jZSBvbiB0aGUgcGFnZS0+X2NvdW50IGZpZWxkLiBTbyBJIHdvdWxkIHNheSB5b3VyIGNo
YW5nZSBoaWRlcyBhIHBlcmZvcm1hbmNlIGlzc3VlIG9mIHlvdXIgZHJpdmVyLg0KPiANCj4gTWF5
YmUgeW91IHNob3VsZCBtYWtlIHN1cmUgeW91IGRvbnQgdG91Y2ggaXQgdG9vIG9mdGVuIFsgWW91
IHNob3VsZCB1c2UgYSBzaW5nbGUgYWRkIHBlciBhbGxvY2F0ZWQgUEFHRSwgbm90IDIgKGZvciAy
MDQ4LWJ5dGVzIGZyYWdzKSBvciA4IChmb3IgNTEyLWJ5dGVzIGZyYWdzKSBdDQo+IA0KPiANClRo
YW5rcyBFcmljLA0KSSdsbCBjaGVjayB0aGlzLg0KSW4gdGhlIG1lYW53aGlsZSB3aWxsIHJlc3Vi
bWl0IHRoZSBzZXJpZXMgd2l0aG91dCB0aGlzIGNoYW5nZS4NCg==
