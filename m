From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [net-next PATCH 1/4] Revert "inet: limit length of fragment queue hash table bucket lists"
Date: Thu, 25 Apr 2013 14:58:54 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7202@saturn3.aculab.com>
References: <20130424154624.16883.40974.stgit@dragon> <20130424154800.16883.4797.stgit@dragon> <1366848030.8964.98.camel@edumazet-glaptop> <1366895438.26911.572.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "David S. Miller" <davem@davemloft.net>,
	"Hannes Frederic Sowa" <hannes@stressinduktion.org>,
	<netdev@vger.kernel.org>
To: "Jesper Dangaard Brouer" <brouer@redhat.com>,
	"Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:38975 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1758691Ab3DYOA3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Apr 2013 10:00:29 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 24269-06 for <netdev@vger.kernel.org>;
 Thu, 25 Apr 2013 15:00:26 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1366895438.26911.572.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBUaGUgcmVhc29uIHRoaXMgaXMgaW5ldml0YWJsZSwgaXMgdGhlIGF0dGFja2VycyBpbnZhbGlk
IGZyYWdtZW50cyB3aWxsDQo+IG5ldmVyIGZpbmlzaCAodGltZW91dCAzMCBzZWMpLCB3aGlsZSB2
YWxpZCBmcmFnbWVudHMgd2lsbCBjb21wbGV0ZSBhbmQNCj4gImV4aXQiIHRoZSBxdWV1ZSwgdGh1
cyB0aGUgZW5kIHJlc3VsdCBpcyBoYXNoIGJ1Y2tldCBpcyBmaWxsZWQgd2l0aA0KPiBhdHRhY2tl
cnMgaW52YWxpZC9pbmNvbXBsZXRlIGZyYWdtZW50cy4gIElNSE8gdGhpcyBpcyBhIHZlcnkgZGFu
Z2Vyb3VzDQo+ICJmZWF0dXJlIiB0byBzdXBwb3J0Lg0KDQpJZiB5b3UgYXJlIGJlaW5nIGF0dGFj
a2VkLCB0aGUgaGFzaCBidWNrZXRzIHdpbGwgaW1tZWRpYXRlbHkNCmJlIGZpbGxlZCB3aXRoIGlu
dmFsaWQgcGFja2V0cywgbm8gdmFsaWQgcGFja2V0cyB3aWxsIGVudGVyLg0KSWYgeW91IGRlbGV0
ZSBvbGQgZW50cmllcyB0byBhZGQgbmV3IG9uZXMgdGhlbiBhbnkgdmFsaWQNCnBhY2tldCB3aWxs
IHNvb24gYmUgZmx1c2hlZCBvdXQgYnkgaW52YWxpZCBvbmVzLg0KVGhlIG9ubHkgdGltZSB5b3Un
bGwgbWFuYWdlIHRvIGFzc2VtYmxlIGFueXRoaW5nIGlzIGlmDQp0aGUgdmFsaWQgZnJhZ21lbnRz
IGFycml2ZSAnYmFjayB0byBiYWNrJy4NCg0KVGhlIG9ubHkgaG9wZSBpcyB0byBwYXJ0LWRlY29k
ZSBpbml0aWFsIGZyYWdtZW50cyBhbmQgZGVjaWRlDQp3aGV0aGVyIHRoZXkgYXJlIHZhbGlkLg0K
DQoJRGF2aWQNCg0KDQo=
