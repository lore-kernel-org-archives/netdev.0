From: Matt Bennett <Matt.Bennett@alliedtelesis.co.nz>
Subject: Re: Increasing skb->mark size
Date: Tue, 24 Nov 2015 20:56:54 +0000
Message-ID: <1448398614.14854.39.camel@mattb-dl>
References: <1448397144.14854.27.camel@mattb-dl>
	 <20151124203602.GB23215@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Luuk Paulussen <Luuk.Paulussen@alliedtelesis.co.nz>,
	Kyeong Yoo <Kyeong.Yoo@alliedtelesis.co.nz>
To: "fw@strlen.de" <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.alliedtelesis.co.nz ([202.36.163.20]:46807 "EHLO
	gate2.alliedtelesis.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753501AbbKXU5I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 15:57:08 -0500
In-Reply-To: <20151124203602.GB23215@breakpoint.cc>
Content-Language: en-US
Content-ID: <FB2DF0E0569FA04C9363AF09C032E391@atlnz.lc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gVHVlLCAyMDE1LTExLTI0IGF0IDIxOjM2ICswMTAwLCBGbG9yaWFuIFdlc3RwaGFsIHdyb3Rl
Og0KPiBNYXR0IEJlbm5ldHQgPE1hdHQuQmVubmV0dEBhbGxpZWR0ZWxlc2lzLmNvLm56PiB3cm90
ZToNCj4gPiBJJ20gZW1haWxpbmcgdGhpcyBsaXN0IGZvciBmZWVkYmFjayBvbiB0aGUgZmVhc2li
aWxpdHkgb2YgaW5jcmVhc2luZw0KPiA+IHNrYi0+bWFyayBvciBhZGRpbmcgYSBuZXcgZmllbGQg
Zm9yIG1hcmtpbmcuIFBlcmhhcHMgdGhpcyBleHRlbnNpb24NCj4gPiBjb3VsZCBiZSBkb25lIHVu
ZGVyIGEgbmV3IENPTkZJRyBvcHRpb24uIFBlcmhhcHMgdGhlcmUgYXJlIG90aGVyIHdheXMgd2UN
Cj4gPiBjb3VsZCBhY2hpZXZlIHRoZSBkZXNpcmVkIGJlaGF2aW91cj8NCj4gDQo+IFdlbGwgSSBw
b2ludGVkIHlvdSB0b3dhcmRzIGNvbm5sYWJlbHMgd2hpY2ggcHJvdmlkZSAxMjggYml0IG9mIHNw
YWNlDQo+IGluIHRoZSBjb25udHJhY2sgZXh0ZW5zaW9uIGFyZWEgYnV0IHlvdSBkaWQgbm90IHRl
bGwgbWUgd2h5IHlvdSBjYW5ub3QNCj4gdXNlIGl0Lg0KU29ycnksIEkgbW92ZWQgdGhlIGRpc2N1
c3Npb24gdG8gdGhpcyBsaXN0IHRvIGhvcGVmdWxseSBnYXRoZXIgc29tZSBuZXcNCmlkZWFzL29w
aW5pb25zLg0KDQpXaGlsZSBjb25ubGFiZWxzIHByb3ZpZGUgMTI4Yml0cyBvZiBzcGFjZSBza2It
Pm1hcmsgaXMgc3RpbGwgb25seSAzMg0KYml0cy4gU2luY2Ugd2UgYXJlIHVzaW5nIGNvbm5lY3Rp
b24gdHJhY2tpbmcgdG8gc2ltcGx5IHJlc3RvcmUgc2tiLT5tYXJrDQp0aGUgdXNlIG9mIGNvbm5s
YWJlbHMgYnkgaXRzZWxmIGRvZXNuJ3Qgc29sdmUgdGhlIHByb2JsZW0gSSBvdXRsaW5lZA0KYWJv
dmUuIHNrYi0+bWFyayB3b3VsZCBzdGlsbCBuZWVkcyB0byBiZSBpbmNyZWFzZWQgaW4gc2l6ZS4N
Cj4gLS0NCj4gVG8gdW5zdWJzY3JpYmUgZnJvbSB0aGlzIGxpc3Q6IHNlbmQgdGhlIGxpbmUgInVu
c3Vic2NyaWJlIG5ldGRldiIgaW4NCj4gdGhlIGJvZHkgb2YgYSBtZXNzYWdlIHRvIG1ham9yZG9t
b0B2Z2VyLmtlcm5lbC5vcmcNCj4gTW9yZSBtYWpvcmRvbW8gaW5mbyBhdCAgaHR0cDovL3ZnZXIu
a2VybmVsLm9yZy9tYWpvcmRvbW8taW5mby5odG1sDQoNCg==
