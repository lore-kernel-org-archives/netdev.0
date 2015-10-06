From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: Fix unused variable compile warning
Date: Mon, 05 Oct 2015 23:35:37 -0700 (PDT)
Message-ID: <20151005.233537.1854084467334631982.davem@davemloft.net>
References: <1443714544-21595-1-git-send-email-dsa@cumulusnetworks.com>
	<CAHA+R7PTyS=wtowhKZ4osDs_VF=UJvfhw_xkWO3PQZuiFdnTsw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: dsa@cumulusnetworks.com, netdev@vger.kernel.org, dsahern@gmail.com
To: cwang@twopensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44725 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750998AbbJFGT4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 02:19:56 -0400
In-Reply-To: <CAHA+R7PTyS=wtowhKZ4osDs_VF=UJvfhw_xkWO3PQZuiFdnTsw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogQ29uZyBXYW5nIDxjd2FuZ0B0d29wZW5zb3VyY2UuY29tPg0KRGF0ZTogTW9uLCA1IE9j
dCAyMDE1IDEwOjUzOjU3IC0wNzAwDQoNCj4gT24gVGh1LCBPY3QgMSwgMjAxNSBhdCA4OjQ5IEFN
LCBEYXZpZCBBaGVybiA8ZHNhQGN1bXVsdXNuZXR3b3Jrcy5jb20+IHdyb3RlOg0KPj4gRXJpYydz
IG5ldCBuYW1lc3BhY2UgY2hhbmdlcyBpbiAxYjc1MDk3ZGQ3YTI2IGxlYXZlcyBuZXQgdW5yZWZl
cmVuY2VkIGlmDQo+PiBDT05GSUdfSVBfVlNfSVBWNiBpcyBub3QgZW5hYmxlZDoNCj4+DQo+PiAu
Li9uZXQvbmV0ZmlsdGVyL2lwdnMvaXBfdnNfY29yZS5jOiBJbiBmdW5jdGlvbiChaXBfdnNfb3V0
ojoNCj4+IC4uL25ldC9uZXRmaWx0ZXIvaXB2cy9pcF92c19jb3JlLmM6MTE3NzoxNDogd2Fybmlu
ZzogdW51c2VkIHZhcmlhYmxlIKFuZXSiIFstV3VudXNlZC12YXJpYWJsZV0NCj4+DQo+PiBBZnRl
ciB0aGUgbmV0IHJlZmFjdG9yaW5nIHRoZXJlIGlzIG9ubHkgMSB1c2VyOyBwdXNoIHRoZSByZWZl
cmVuY2UgdG8gdGhlDQo+PiAxIHVzZXIuIFdoaWxlIHRoZSBsaW5lIGxlbmd0aCBzbGlnaHRseSBl
eGNlZWRzIDgwIGl0IHNlZW1zIHRvIGJlIHRoZQ0KPj4gYmVzdCBjaGFuZ2UuDQo+Pg0KPj4gRml4
ZXM6IDFiNzUwOTdkZDdhMjYoImlwdnM6IFBhc3MgaXB2cyBpbnRvIGlwX3ZzX291dCIpDQo+PiBT
aWduZWQtb2ZmLWJ5OiBEYXZpZCBBaGVybiA8ZHNhQGN1bXVsdXNuZXR3b3Jrcy5jb20+DQo+IA0K
PiBJIHNhdyB0aGUgc2FtZSBidWlsZCB3YXJuaW5nLCBhbmQgdGhpcyBmaXggbG9va3MgZ29vZCB0
byBtZS4NCj4gDQo+IERhdmVNLCBjYW4geW91IHRha2UgdGhpcz8NCg0KSXQgc2hvdWxkIGJlIHN1
Ym1pdHRlZCB0byBuZXRmaWx0ZXItZGV2ZWwgYW5kIFBhYmxvIHNob3VsZCB0YWtlIGl0Lg0K
