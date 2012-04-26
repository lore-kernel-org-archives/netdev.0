From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mISDN: Ignore return value of driver_for_each_device
 in function hfcpci_softirq.
Date: Wed, 25 Apr 2012 20:42:31 -0400 (EDT)
Message-ID: <20120425.204231.1586199621022282253.davem@davemloft.net>
References: <1335309230-23428-1-git-send-email-krzysztof.wilczynski@linux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: isdn@linux-pingi.de, gregkh@linuxfoundation.org,
	horms@verge.net.au, trivial@kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: krzysztof.wilczynski@linux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55309 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932693Ab2DZAmo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 20:42:44 -0400
In-Reply-To: <1335309230-23428-1-git-send-email-krzysztof.wilczynski@linux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogS3J6eXN6dG9mIFdpbGN6eW5za2kgPGtyenlzenRvZi53aWxjenluc2tpQGxpbnV4LmNv
bT4NCkRhdGU6IFdlZCwgMjUgQXByIDIwMTIgMDA6MTM6NTAgKzAxMDANCg0KPiBGdW5jdGlvbiBo
ZmNwY2lfc29mdGlycSB1c2VzIGRyaXZlcl9mb3JfZWFjaF9kZXZpY2UgdG8gY2FsbCBfaGZjcGNp
X3NvZnRpcnEgZm9yDQo+IGVhY2ggZGV2aWNlLiBHaXZlbiB0aGF0IF9oZmNwY2lfc29mdGlycSBh
bHdheXMgcmV0dXJucyAwLCB3ZSBjb2xsZWN0IHRoaXMgcmV0dXJuDQo+IHZhbHVlIGFuZCBzaW1w
bHkgZG8gbm90aGluZyB3aXRoIGl0LiAgVGhpcyBpcyBwdXJlbHkgdG8gYWRkcmVzcyB0aGUgZm9s
bG93aW5nDQo+IHdhcm5pbmcgZHVyaW5nIGNvbXBpbGF0aW9uIHRpbWU6DQo+IA0KPiAgIGRyaXZl
cnMvaXNkbi9oYXJkd2FyZS9tSVNETi9oZmNwY2kuYzogSW4gZnVuY3Rpb24goWhmY3BjaV9zb2Z0
aXJxojoNCj4gICBkcml2ZXJzL2lzZG4vaGFyZHdhcmUvbUlTRE4vaGZjcGNpLmM6MjMxOTogd2Fy
bmluZzogaWdub3JpbmcgcmV0dXJuIHZhbHVlIG9mDQo+ICAgICChZHJpdmVyX2Zvcl9lYWNoX2Rl
dmljZaIsIGRlY2xhcmVkIHdpdGggYXR0cmlidXRlIHdhcm5fdW51c2VkX3Jlc3VsdA0KPiANCj4g
U2ltaWxhciBhcHByb2FjaCB3YXMgdXNlZCBpbiBmdW5jdGlvbiBjeDE4X2Fsc2FfZXhpdCBmcm9t
ICJjeDE4LWFsc2EtbWFpbi5jIi4NCj4gDQo+IFNpZ25lZC1vZmYtYnk6IEtyenlzenRvZiBXaWxj
enluc2tpIDxrcnp5c3p0b2Yud2lsY3p5bnNraUBsaW51eC5jb20+DQoNClRoZXJlIGlzIG5vIHZh
bHVlIGluIHRoZSB3YXJuaW5nIGlmIHdlIHNpbXBseSBjb252ZXJ0IGVhY2ggc3VjaCBjYXNlDQp0
byBpZ25vcmUgdGhlIHJldHVybiB2YWx1ZS4NCg0KSSdtIG5vdCBhcHBseWluZyB0aGlzLCBhdCBs
ZWFzdCBub3Qgd2l0aCBhIG1vcmUgaW50ZWxsaWdlbnQgYW5hbHlzaXMNCm9mIHdoeSBhbnkgZXJy
b3Igb3Igb3RoZXIgbm9uLXplcm8gdmFsdWUgc2lnbmFsbGVkIGJ5DQpkcml2ZXJfZm9yX2VhY2hf
ZGV2aWNlIHNob3VsZCBiZSBjb21wbGV0ZWx5IGlnbm9yZWQsIGFuZCBubyBlcnJvcg0KaGFuZGxp
bmcgc2hvdWxkIGJlIHBlcmZvcm1lZC4NCg==
