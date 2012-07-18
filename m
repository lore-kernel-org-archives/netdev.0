From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next] ipv6: add ipv6_addr_hash() helper
Date: Wed, 18 Jul 2012 13:28:13 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6F93@saturn3.aculab.com>
References: <1342613334.2626.2504.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev" <netdev@vger.kernel.org>,
	"Andrew McGregor" <andrewmcgr@gmail.com>,
	"Dave Taht" <dave.taht@gmail.com>,
	"Tom Herbert" <therbert@google.com>
To: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:46657 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752654Ab2GRM26 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jul 2012 08:28:58 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 11713-04 for <netdev@vger.kernel.org>;
 Wed, 18 Jul 2012 13:28:53 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1342613334.2626.2504.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAgI2RlZmluZSBIQVNIX1NJWkUgIDMyDQo+IA0KPiAtI2RlZmluZSBIQVNIKGFkZHIpICgoX19m
b3JjZSB1MzIpKChhZGRyKS0+czZfYWRkcjMyWzBdIF4gKGFkZHIpLT5zNl9hZGRyMzJbMV0gXiBc
DQo+IC0JCSAgICAgKGFkZHIpLT5zNl9hZGRyMzJbMl0gXiAoYWRkciktPnM2X2FkZHIzMlszXSkg
JiBcDQo+IC0JCSAgICAoSEFTSF9TSVpFIC0gMSkpDQo+ICsjZGVmaW5lIEhBU0goYWRkcikgKGlw
djZfYWRkcl9oYXNoKGFkZHIpICYgKEhBU0hfU0laRSAtIDEpKQ0KDQpUaGF0IGhhc2ggZG9lc24n
dCBzZWVtIHRvIGluY2x1ZGUgbWFueSB2YXJpYWJsZSBiaXRzIGF0IGFsbCENCkVzcGVjaWFsbHkg
b24gTEUgc3lzdGVtcyB3aGVyZSBpdCBkb2Vzbid0IGNvbnRhaW4gYW55IG9mDQp0aGUgbG93IGJp
dHMgb2YgYSBtYWMgYWRkcmVzcyBiYXNlZCBJUHY2IGFkZHJlc3MuDQoNCglEYXZpZA0KDQo=
