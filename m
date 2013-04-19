From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [net-next PATCH 2/3] net: fix enforcing of fragment queue hash list depth
Date: Fri, 19 Apr 2013 11:41:19 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B71EB@saturn3.aculab.com>
References: <20130418213637.14296.43143.stgit@dragon> <20130418213732.14296.36026.stgit@dragon> <1366366287.3205.98.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "David S. Miller" <davem@davemloft.net>,
	"Hannes Frederic Sowa" <hannes@stressinduktion.org>,
	<netdev@vger.kernel.org>
To: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"Jesper Dangaard Brouer" <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:56269 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1757078Ab3DSKrk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Apr 2013 06:47:40 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 29314-01 for <netdev@vger.kernel.org>;
 Fri, 19 Apr 2013 11:47:37 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1366366287.3205.98.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBUaGUgNjQgc2xvdHMgaGFzaCB0YWJsZSB3YXMgY2hvc2VuIHllYXJzIGFnbywgd2hlbiBtYWNo
aW5lcyBoYWQgMyBvcmRlcg0KPiBvZiBtYWduaXR1ZGUgbGVzcyByYW0gdGhhbiB0b2RheS4NCj4g
DQo+IEJlZm9yZSBoYXNoIHJlc2l6aW5nLCBJIHdvdWxkIGp1c3QgYnVtcCBoYXNoIHNpemUgdG8g
c29tZXRoaW5nIG1vcmUNCj4gcmVhc29uYWJsZSBsaWtlIDEwMjQuDQoNCldoaWxlIHRoYXQgaXMg
dHJ1ZSBvZiBtYW55IHN5c3RlbXMsIHRoZXJlIGFyZSBlbWJlZGRlZCBzeXN0ZW1zDQp3aXRoIG11
Y2ggbGVzcyByYW0gdGhhbiB0aGUgdHlwaWNhbCB4ODYgZGVza3RvcCBvciBzZXJ2ZXIuDQoNClRo
ZXJlIHNlZW0gdG8gYmUgcXVpdGUgYSBsb3Qgb2YgbGFyZ2UgaGFzaCB0YWJsZXMgYXBwZWFyaW5n
DQp0aGF0IG9uIG1hbnkgc21hbGwgc3lzdGVtcyB3aWxsIG5ldmVyIGNvbnRhaW4gYSBzaWduaWZp
Y2FudA0KbnVtYmVyIG9mIGVudHJpZXMgYW5kIGp1c3Qgd2FzdGUgcHJlY2lvdXMgbWVtb3J5Lg0K
DQoJRGF2aWQNCg0K
