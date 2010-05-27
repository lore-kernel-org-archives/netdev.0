From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: niu: fix uninitialized variable warning
Date: Thu, 27 May 2010 16:23:42 -0700 (PDT)
Message-ID: <20100527.162342.183041034.davem@davemloft.net>
References: <20100527183100.24251.12228.sendpatchset@prarit.bos.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org
To: prarit@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41355
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932218Ab0E0XXd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 May 2010 19:23:33 -0400
In-Reply-To: <20100527183100.24251.12228.sendpatchset@prarit.bos.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogUHJhcml0IEJoYXJnYXZhIDxwcmFyaXRAcmVkaGF0LmNvbT4NCkRhdGU6IFRodSwgMjcg
TWF5IDIwMTAgMTQ6MzU6MDMgLTA0MDANCg0KPiBGaXhlcyB3YXJuaW5nOg0KPiANCj4gZHJpdmVy
cy9uZXQvbml1LmM6IEluIGZ1bmN0aW9uIKFuaXVfcHJvY2Vzc19yeF9wa3SiOg0KPiBkcml2ZXJz
L25ldC9uaXUuYzozNDU3OiBlcnJvcjogoWxpbmuiIG1heSBiZSB1c2VkIHVuaW5pdGlhbGl6ZWQg
aW4gdGhpcyBmdW5jdGlvbg0KPiANCj4gU2lnbmVkLW9mZi1ieTogUHJhcml0IEJoYXJnYXZhIDxw
cmFyaXRAcmVkaGF0LmNvbT4NCg0KVGhlc2UgYmxpbmQgdW5pbml0aWFsaXplZF92YXIoKSBhbm5v
dGF0aW9ucyBhcmUgYWxtb3N0IGFsd2F5cyB0aGUgd3JvbmcNCnRoaW5nIHRvIGRvLiAgQW5kIHRo
YXQgaXMgdGhlIGNhc2UgaGVyZS4NCg0KVGhlIGNvZGUgdGhhdCBsb29rcyB1cCB0aGUgcGFnZSBo
ZXJlIGNhbiByZXR1cm4gTlVMTCBpZiB0aGVyZSBpcyBzb21lDQplcnJvciBhbmQgdGhlIHBhZ2Ug
aGFzaGVzIGFyZW4ndCBzZXR1cCBwcm9wZXJseSwgYW5kIHRoZW4gdGhlIGNhbGxlcnMNCmdvIGFu
ZCBibGluZGx5IGFzc3VtZSB0aGF0ICdwYWdlJyBpcyBub24tTlVMTCB3aXRob3V0IGFueSBlcnJv
cg0KY2hlY2tpbmcuDQoNCkFwcGx5aW5nIHRoaXMgcGF0Y2ggZG9lcyBtb3JlIGhhcm0gdGhhbiBn
b29kIGJlY2F1c2UgaXQgaGlkZXMgdGhpcw0KaXNzdWUuICBTbyBJJ20gZGVmaW5pdGVseSBub3Qg
YXBwbHlpbmcgdGhpcyBwYXRjaC4NCg0K
