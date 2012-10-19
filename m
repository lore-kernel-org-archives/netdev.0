From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: sock_getsockopt() not exported
Date: Fri, 19 Oct 2012 10:26:52 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7056@saturn3.aculab.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B7052@saturn3.aculab.com> <1350552612.26103.1281.camel@edumazet-glaptop> <AE90C24D6B3A694183C094C60CF0A2F6026B7053@saturn3.aculab.com> <1350563275.26103.1465.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Cc: <netdev@vger.kernel.org>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:36991 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753802Ab2JSJht (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2012 05:37:49 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 15370-10 for <netdev@vger.kernel.org>;
 Fri, 19 Oct 2012 10:37:47 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1350563275.26103.1465.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiA+IFRoZSBwcm9ibGVtIGlzIHRoYXQgaXQgbWlnaHQgYmUgbmVlZGVkIGJ5IGFuICdvdXQgb2Yg
dHJlZScgZHJpdmVyLg0KPiA+IFdlIGFscmVhZHkgaGF2ZSB0aGUgZnVuY3Rpb246DQo+IA0KPiBX
ZSBkb250IGNhcmUgb2Ygb3V0IG9mIHRyZWUgZHJpdmVycy4NCj4gDQo+IFRoYXRzIHJlYWxseSBz
aW1wbGUuDQo+IA0KPiBTdWJtaXQgdGhpcyBkcml2ZXIsIGFuZCBhZGQgdGhlIEVYUE9SVF9TWU1C
T0woKSB5b3UgbmVlZCBhdCB0aGF0IHRpbWUuDQoNCkV2ZW4gaWYgbWFuYWdlbWVudCB3b3VsZCBy
ZWxlYXNlIHRoZSBzb3VyY2UsIHlvdSB3b3VsZG4ndA0Kd2FudCA0TUIgb2Ygc291cmNlIGZvciBh
biBzczcgcHJvdG9jb2wgc3RhY2sgZm9yIGEgY2FyZA0KdGhhdCBpc24ndCBnZW5lcmFsbHkgYXZh
aWxhYmxlLCBhbmQgdGhhdCBuZWVkcyBhbm90aGVyDQpzaW1pbGFyIHNpemVkIGRyaXZlciAoYW5k
IGxpYnJhcmllcyBldGMpIHRvIGJlIHVzZWZ1bC4NCg0KVGhlIExpbnV4IGludGVyZmFjZSBpcyBh
bGwgZG9uZSB3aXRoIHdyYXBwZXIgZnVuY3Rpb25zDQp0aGF0IGdldCBjb21waWxlZCBvbiB0aGUg
dGFyZ2V0IHN5c3RlbSBzbyB3ZSBjYW4gc2hpcA0KYSBiaWcgYmluYXJ5ICdibG9iJy4NCg0KCURh
dmlkDQoNCg==
