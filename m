From: "Zhu, Yi" <yi.zhu@intel.com>
Subject: RE: [PATCH V2 2/7] tcp: use limited socket backlog
Date: Wed, 3 Mar 2010 22:12:15 +0800
Message-ID: <DA586906BA1FFC4384FCFD6429ECE860A45A6999@shzsmsx502.ccr.corp.intel.com>
References: <1267605389-7369-1-git-send-email-yi.zhu@intel.com>
	 <1267605389-7369-2-git-send-email-yi.zhu@intel.com>
	 <1267606433.2997.4.camel@edumazet-laptop>
	 <1267607162.2370.169.camel@debian> <1267610843.2997.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:45796 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754165Ab0CCONt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Mar 2010 09:13:49 -0500
In-Reply-To: <1267610843.2997.7.camel@edumazet-laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RXJpYyBEdW1hemV0IFttYWlsdG86ZXJpYy5kdW1hemV0QGdtYWlsLmNvbV0gd3JvdGU6DQo+IExl
IG1lcmNyZWRpIDAzIG1hcnMgMjAxMCDDoCAxNzowNiArMDgwMCwgWmh1IFlpIGEgw6ljcml0IDoN
Cg0KPj4gSSBzaW1wbHkgZm9sbG93IGhvdyB0aGUgY29kZSBpcyBvcmlnaW5hbGx5IHdyaXR0ZW4u
IEFzIHlvdSBjYW4gc2VlLA0KPj4gdGNwX3Y0X2RvX3JjdigpIGRvZXNuJ3QgYWx3YXlzIGRvIHNv
LiBBbmQgaW4gdGhlIGJhY2tsb2cgcXVldWluZyBwbGFjZSwNCj4+IHdlIGRvbid0IGV2ZW4gYm90
aGVyIHRvIGNoZWNrLg0KDQo+IFlvdSBhZGQgYSBuZXcgcG9pbnQgd2hlcmUgYSBwYWNrZXQgY2Fu
IGJlIGRyb3BwZWQsIHRoaXMgc2hvdWxkIGJlDQo+IGFjY291bnRlZCBmb3IsIHNvIHRoYXQgYWRt
aW5zIGNhbiBoYXZlIGEgY2x1ZSB3aGF0cyBnb2luZyBvbi4NCg0KPiBQcmV2aW91c2x5LCBwYWNr
ZXQgd2FzIGFsd2F5cyBxdWV1ZWQsIGFuZCBkcm9wcGVkIGxhdGVyIChhbmQgYWNjb3VudGVkKQ0K
DQpJbiBjYXNlIG9mIHRoZSBza2IgZG9lc24ndCBoYXZlIGEgTUQ1IG9wdGlvbiB3aGlsZSB3ZSBh
cmUgZXhwZWN0aW5nIG9uZSwgb3Igd2UNCmZhaWxlZCB0byBmaW5kIHRoZSBzayBmb3IgdGhlIHNr
YiBjb25uZWN0aW9uIHJlcXVlc3QsIGV0YywgdGhlIHNrYiBpcyBkcm9wcGVkIHNpbGVudGx5IGlu
DQp0Y3BfdjRfZG9fcmN2KCkuIE5vPw0KDQo+IE5vdCBldmVyeWJvZHkgcnVucyBkcm9wIG1vbml0
b3IgOikNCg0KVGhhbmtzLA0KLXlpDQo=
