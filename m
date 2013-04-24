From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [net-next PATCH 0/4] net: frag patchset for fixing LRU scalabilityissue
Date: Wed, 24 Apr 2013 17:21:31 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B71F9@saturn3.aculab.com>
References: <20130424154624.16883.40974.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Cc: <netdev@vger.kernel.org>, "Eric Dumazet" <eric.dumazet@gmail.com>
To: "Jesper Dangaard Brouer" <brouer@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Hannes Frederic Sowa" <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:40793 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1755689Ab3DXQWh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Apr 2013 12:22:37 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 01337-03 for <netdev@vger.kernel.org>;
 Wed, 24 Apr 2013 17:22:33 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <20130424154624.16883.40974.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBJIGhhdmUgZHJvcHBlZCB0aGUgaWRlYSBvZiBkb2luZyAiZGlyZWN0IGhhc2ggY2xlYW5pbmci
LiAgSW5zdGVhZCBJDQo+IGhhdmUgc2ltcGx5IGNob29zZW4gdG8gc29sdmUgdGhlIGdsb2JhbCBM
UlUgbGlzdCBwcm9ibGVtLCBieSBtYWtpbmcNCj4gdGhlIExSVSBsaXN0IGJlIHBlciBDUFUuDQoN
CkhvdyBjYW4gYSBwZXItY3B1IExSVSBsaXN0IHdvcms/DQpJIHNlZSB0d28gaW1tZWRpYXRlIHBy
b2JsZW1zOg0KLSBFbnN1cmluZyB0aGUgbm9ybWFsICdhbGxvY2F0ZScgYW5kICdmcmVlJyBhcmUg
YWx3YXlzIGRvbmUNCiAgb24gdGhlIHNhbWUgY3B1IChmcmVlIHdpbGwgbmVlZCB0byByZW1vdmUg
aXRlbXMgZnJvbSBhbnkNCiAgTFJVIGxpc3QpLg0KLSBFbnN1cmluZyB0aGF0IHRoZXJlIGFsbCB0
aGUgaXRlbXMgYXJlbid0IG9uIHRoZSBMUlUgbGlzdHMNCiAgb2Ygb3RoZXIgY3B1cyAtIG1lYW5p
bmcgb25lIGNhbid0IGJlIGFsbG9jYXRlZC4NCg0KVGhlIG9ubHkgd2F5IHRoaXMgY291bGQgd29y
ayBpcyBpZiB0aGUgYWxsb2NhdGlvbiBsaW1pdA0KaXMgYWxzbyBwZXItY3B1IGFuZCB5b3UgY2Fu
IGd1YXJhbnRlZSB0aGF0IHRoZSBhbGxvYyBhbmQNCmZyZWUgZm9yIGFueSBnaXZlbiBpdGVtIHdp
bGwgYWx3YXlzIGhhcHBlbiBvbiB0aGUgc2FtZSBjcHUuDQoNCihhbGxvYyBhcyBpbiAnYWRkIHRv
IExSVSBsaXN0LCBmcmVlIGFzIGluICdyZW1vdmUgZnJvbSBMUlUgbGlzdCkuDQoNCglEYXZpZA0K
