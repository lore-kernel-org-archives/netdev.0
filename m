From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: TCP performance regression
Date: Mon, 11 Nov 2013 16:35:30 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B73FD@saturn3.aculab.com>
References: <21120.27501.32323.332316@gargle.gargle.HOWL> <1384149326.16391.10.camel@edumazet-glaptop2.roam.corp.google.com> <21120.29720.673157.151074@gargle.gargle.HOWL> <1384152853.16391.19.camel@edumazet-glaptop2.roam.corp.google.com> <21120.37647.979237.40802@gargle.gargle.HOWL> <1384180069.16391.32.camel@edumazet-glaptop2.roam.corp.google.com> <AE90C24D6B3A694183C094C60CF0A2F6026B73F9@saturn3.aculab.com> <1384183799.16391.39.camel@edumazet-glaptop2.roam.corp.google.com> <AE90C24D6B3A694183C094C60CF0A2F6026B73FB@saturn3.aculab.com> <1384186622.16391.44.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "Sujith Manoharan" <sujith@msujith.org>, <netdev@vger.kernel.org>,
	"Dave Taht" <dave.taht@gmail.com>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:34069 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754148Ab3KKQiE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Nov 2013 11:38:04 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 10886-01 for <netdev@vger.kernel.org>;
 Mon, 11 Nov 2013 16:38:00 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1384186622.16391.44.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiA+IEl0IHNob3VsZCBiZSBvayBpZiB0aGUgbWFjIGRyaXZlciBvbmx5IGdpdmVzIHRoZSBoYXJk
d2FyZSBhIHNtYWxsDQo+ID4gbnVtYmVyIG9mIGJ5dGVzL3BhY2tldHMgLSBvciBvbmUgYXBwcm9w
cmlhdGUgZm9yIHRoZSBsaW5rIHNwZWVkLg0KPiANCj4gVGhlcmUgaXMgc29tZSBjb25mdXNpb24g
aGVyZS4NCj4gDQo+IG12bmV0YSBoYXMgYSBUWCByaW5nIGJ1ZmZlciwgd2hpY2ggY2FuIGhvbGQg
dXAgdG8gNTMyIFRYIGRlc2NyaXB0b3JzLg0KPiANCj4gSWYgdGhpcyBkcml2ZXIgdXNlZCBza2Jf
b3JwaGFuKCksIGEgc2luZ2xlIFRDUCBmbG93IGNvdWxkIHVzZSB0aGUgd2hvbGUNCj4gVFggcmlu
Zy4NCj4gDQo+IFRDUCBTbWFsbCBRdWV1ZSB3b3VsZCBvbmx5IGxpbWl0IHRoZSBudW1iZXIgb2Yg
c2ticyBvbiBRZGlzYy4NCj4gDQo+IFRyeSB0aGVuIHRvIHNlbmQgYSBwaW5nIG1lc3NhZ2UsIGl0
IHdpbGwgaGF2ZSB0byB3YWl0IGEgbG90Lg0KDQo1MzIgaXMgYSByaWRpY3Vsb3VzbHkgbGFyZ2Ug
bnVtYmVyIGVzcGVjaWFsbHkgZm9yIGEgc2xvdyBpbnRlcmZhY2UuDQpBdCBhIGd1ZXNzIHlvdSBk
b24ndCB3YW50IG1vcmUgdGhhbiAxMC0yMG1zIG9mIGRhdGEgaW4gdGhlIHR4IHJpbmcuDQpZb3Ug
bWlnaHQgbmVlZCBleHRyYSBkZXNjcmlwdG9ycyBmb3IgYmFkbHkgZnJhZ21lbnRlZCBwYWNrZXRz
Lg0KDQoJRGF2aWQNCg0K
