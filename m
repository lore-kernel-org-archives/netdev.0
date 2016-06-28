From: "Seymour, Shane M" <shane.seymour@hpe.com>
Subject: RE: [PATCH net-next] tcp: increase size at which
 tcp_bound_to_half_wnd bounds to > TCP_MSS_DEFAULT
Date: Tue, 28 Jun 2016 21:54:46 +0000
Message-ID: <CS1PR84MB02950F38FF1801E89612B9E4FD220@CS1PR84MB0295.NAMPRD84.PROD.OUTLOOK.COM>
References: <CS1PR84MB0295E420892A535E40FE338EFD220@CS1PR84MB0295.NAMPRD84.PROD.OUTLOOK.COM>
 <1467115090.6850.202.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0112.outbound.protection.outlook.com ([157.56.111.112]:25664
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752395AbcF1WJs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2016 18:09:48 -0400
In-Reply-To: <1467115090.6850.202.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBGcm9tOiBFcmljIER1bWF6ZXQgW21haWx0bzplcmljLmR1bWF6ZXRAZ21haWwuY29tXQ0KPiBU
cnlpbmcgdG8gY29wZSB3aXRoIHJpZGljdWxvdXMgd2luZG93cyB0aGVzZSBkYXlzIGlzIHJlYWxs
eSBhIHdhc3RlIG9mDQo+IHRpbWUsIGFzIHdlIHBlcmZvcm0gdGhpcyBjaGVjayBmb3IgYWxsIHRj
cCBzZW5kbXNnKCkgY2FsbHMgOigNCg0KSSBkb24ndCBkaXNhZ3JlZSB3aXRoIHlvdSBidXQgdW5m
b3J0dW5hdGVseSB0aGVyZSBhcmUgc3RpbGwgZGV2aWNlcw0Kb3V0IHRoZXJlIGxpa2UgdGhpcyBh
bmQgcHJvYmFibHkgd2lsbCBiZSBmb3IgYSBsb25nIHRpbWUuDQoNCj4gQW55d2F5LCB5b3VyIHBh
dGNoIGlzIHJldmVyc2VkLg0KDQpJJ20gbm90IHN1cmUgd2hhdCB5b3UgbWVhbiBieSByZXZlcnNl
ZCwgSSBkaWRuJ3QgY2hhbmdlIHRoZSBkaXJlY3Rpb24NCm9mIHRoZSB0ZXN0IGluIHRoZSBjb2Rl
IGp1c3Qgd2hhdCBpdCdzIGJlaW5nIGNvbXBhcmVkIGFnYWluc3QgYW5kIHNvDQppdCdzIGdyZWF0
ZXIgdGhhbiBub3QgZ3JlYXRlciB0aGFuIG9yIGVxdWFsIHRvLg0KDQpVbmxlc3MgYXV0by1jb3Jy
ZWN0aW9uIGNoYW5nZWQgcmV2aWV3ZWQgdG8gcmV2ZXJzZWQ/DQo=
