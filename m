From: Matt Bennett <Matt.Bennett@alliedtelesis.co.nz>
Subject: Re: [PATCH net] ppp: don't override sk->sk_state in
 pppoe_flush_dev()
Date: Mon, 5 Oct 2015 04:08:51 +0000
Message-ID: <1444018131.14634.6.camel@mattb-dl>
References: <b7fbf103cd589741e3938550e7cf0f3684d8951c.1443605079.git.g.nault@alphalink.fr>
	 <7045c1dad4647944f61c958511d45fcd@visp.net.lb>
	 <20151002175426.GE2911@alphalink.fr>
	 <356ca8b8094bb2460c0182c00e120378@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "core@irc.lg.ua" <core@irc.lg.ua>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"paulus@samba.org" <paulus@samba.org>,
	"g.nault@alphalink.fr" <g.nault@alphalink.fr>
To: "nuclearcat@nuclearcat.com" <nuclearcat@nuclearcat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.alliedtelesis.co.nz ([202.36.163.20]:33934 "EHLO
	gate2.alliedtelesis.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751175AbbJEEJD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 00:09:03 -0400
In-Reply-To: <356ca8b8094bb2460c0182c00e120378@visp.net.lb>
Content-Language: en-US
Content-ID: <049BE73898791443860AAB3DB03782D3@atlnz.lc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SGksIEkgYW0gc2VlaW5nIHRoaXMgcGFuaWMgb2NjdXIgb2NjYXNpb25hbGx5IGhvd2V2ZXIgSSBh
bSB1bnN1cmUgaG93IHRvDQpnbyBhYm91dCByZXByb2R1Y2luZyBpdC4gSXMgaXQgZW5vdWdoIHRv
IHNpbXBseSBrZWVwIGNyZWF0aW5nIGFuZA0KdGVhcmluZyBkb3duIHRoZSBQUFAgaW50ZXJmYWNl
PyBJIGNhbiBhbHNvIHRlc3QgYW5kL29yIGludmVzdGlnYXRlIHRoaXMNCmlzc3VlIGlmIGEgc3Vp
dGFibGUgcmVwcm9kdWN0aW9uIG1ldGhvZCBpcyBhdmFpbGFibGUuDQoNCk9uIFN1biwgMjAxNS0x
MC0wNCBhdCAxOTowOCArMDMwMCwgRGVueXMgRmVkb3J5c2hjaGVua28gd3JvdGU6DQo+IE9uIDIw
MTUtMTAtMDIgMjA6NTQsIEd1aWxsYXVtZSBOYXVsdCB3cm90ZToNCg0K
