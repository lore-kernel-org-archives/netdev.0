From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next] tcp: shrink tcp6_timewait_sock by one cache line
Date: Wed, 2 Oct 2013 13:08:20 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B736F@saturn3.aculab.com>
References: <1380711604.19002.78.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev" <netdev@vger.kernel.org>
To: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:47887 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753525Ab3JBMJY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Oct 2013 08:09:24 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 15804-02 for <netdev@vger.kernel.org>;
 Wed,  2 Oct 2013 13:09:21 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1380711604.19002.78.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtCXRtbyA9IHR3LT50d190dGQgLSBqaWZmaWVzOw0KPiArCXRtbyA9IHR3LT50d190dGQgLSAo
dTMyKWppZmZpZXM7DQoNCkRvIHlvdSBuZWVkIGFueSBvZiB0aGVzZSAodTMyKSBjYXN0cz8NClRo
ZSBjb21waWxlciB3aWxsIGFsbW9zdCBjZXJ0YWlubHkgdXNlIDMyYml0IGFyaXRobWV0aWMgKG9u
IDMyYml0IHN5c3RlbXMgYXQgbGVhc3QpDQpiZWNhdXNlIHRoZSAnYXMgaWYnIHJ1bGUgbGV0cyBp
ZiB1c2UgdGhlIHNtYWxsZXIgdHlwZS4NCg0KPiArCQl0dy0+dHdfdHRkID0gKHUzMikoamlmZmll
cyArIChzbG90IDw8IElORVRfVFdEUl9SRUNZQ0xFX1RJQ0spKTsNCg0KSWYgdGhhdCAodTMyKSBj
YXN0IGlzIG5lZWRlZCBpbiBvcmRlciB0byBhdm9pZCA2NGJpdCBtYXRocywgaXQgaXMgaW4gdGhl
IHdyb25nIHBsYWNlLg0KDQoJRGF2aWQNCg0K
