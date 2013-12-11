From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 4/4] asix: C1 DUB-E100 double rx_urb_size to 4096
Date: Wed, 11 Dec 2013 16:28:50 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7481@saturn3.aculab.com>
References: <1386759028-3534-1-git-send-email-Dean_Jenkins@mentor.com> <1386759028-3534-5-git-send-email-Dean_Jenkins@mentor.com> <AE90C24D6B3A694183C094C60CF0A2F6026B747E@saturn3.aculab.com> <1386774802.30495.369.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: base64
Cc: "Dean Jenkins" <Dean_Jenkins@mentor.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:49308 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750904Ab3LKQeD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Dec 2013 11:34:03 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 17381-09 for <netdev@vger.kernel.org>;
 Wed, 11 Dec 2013 16:34:00 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1386774802.30495.369.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBGcm9tOiBFcmljIER1bWF6ZXQNCi4uLg0KPiBJIGZlYXIgdGhhdCBkb3VibGluZyByeF91cmJf
c2l6ZSBpcyBhcnRpZmljaWFsbHkgZG91YmxpbmcgdGhlIHNrYg0KPiB0cnVlc2l6ZSAob3Igbm90
LCBhbmQgdGhpcyB3b3VsZCBiZSBhIGJ1ZyksIGFuZCB0aGlzIGhhcw0KPiBhbiBpbXBhY3Qgb24g
Z2VuZXJhbCBwZXJmb3JtYW5jZSBvZiBUQ1Agc3RhY2suDQoNCldoaWNoIG1lYW5zIHRoYXQgdGhl
IGNvZGUgaW4gdGhlIGF4MTc5XzE3OGEgZHJpdmVyIGlzIHJlYWxseSBob3JyaWQuDQpJdCBjYXVz
ZXMgMjBrQiBVUkIgdG8gYmUgcGFzc2VkIHRvIHRoZSB4aGNpIGRyaXZlci4NCg0KSSBrbm93IHRo
YXQgaGFyZHdhcmUgc3VwcG9ydHMgdGNwIHRyYW5zbWl0IHNlZ21lbnRhdGlvbiBvZmZsb2FkLg0K
SSBkb24ndCBrbm93IGl0IGlmIHN1cHBvcnRzIHJlY2VpdmUgb2ZmbG9hZC4NCkJlc3Qgd2F5IHRv
IHRlc3QgaXMgcHJvYmFibHkgcnVubmluZyBhdCBHZSBzcGVlZHMgYXQgdXNiMiBzcGVlZHMNCi0g
Y29ubmVjdCB0byBhbiB4aGNpIHBvcnQgd2l0aCBhIFVTQjIgZXh0ZW5zaW9uIGNhYmxlLg0KDQpJ
J20gd2FpdGluZyBmb3IgbXkgZXhpc3RpbmcgeGhjaSBwYXRjaGVzIHRvIGdldCBwcm9jZXNzZWQg
YmVmb3JlDQpJIHdyaXRlIGFueSBtb3JlLg0KDQoJRGF2aWQNCg0K
