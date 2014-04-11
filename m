From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] ipv6: Limit mtu to 65572 bytes
Date: Fri, 11 Apr 2014 08:40:42 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6F5DBD@AcuExch.aculab.com>
References: <5345A2B3.7040602@gmail.com>
	 <1397079665.16584.17.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140409223546.GH27255@order.stressinduktion.org>
	 <1397090170.16584.21.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140410235459.GK27255@order.stressinduktion.org>
	 <1397176824.16584.52.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1397180530.16584.69.camel@edumazet-glaptop2.roam.corp.google.com>
	 <534753D4.6070600@linux-ipv6.org>
	 <20140411025707.GM27255@order.stressinduktion.org>
 <1397186090.16584.82.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	David Miller <davem@davemloft.net>,
	Francois WELLENREITER <f.wellenreiter@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:55501 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754654AbaDKImb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Apr 2014 04:42:31 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 22680-01 for <netdev@vger.kernel.org>;
 Fri, 11 Apr 2014 09:42:21 +0100 (BST)
In-Reply-To: <1397186090.16584.82.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0DQo+IFllcywgcmVjZW50IEludGVsIGNwdXMgaGF2ZSByZWFsbHkg
ZmFzdCBtZW0gY29weSwgZXZlbiB3aXRoIGRpZmZlcmVudA0KPiBhbGlnbm1lbnRzIGZvciBzb3Vy
Y2UvZGVzdC4NCg0KWWVzLCB0aGV5J3ZlIGZpbmFsbHkgdGhyb3duIGEgc21hbGwgYW1vdW50IG9m
IGxvZ2ljIGF0IGl0Lg0KUHJvYmFibHkgYSBjYWNoZSBsaW5lIHNpemVkIGJhcnJlbCBzaGlmdGVy
Lg0KJ3JlcCBtb3ZzYicgaGFzIGFsc28gYmVlbiBvcHRpbWlzZWQgZm9yIHNob3J0IHRyYW5zZmVy
cyAoYnV0IGlzDQpzbG93ZXIgZm9yIGxvbmdlciBvbmVzKS4NCg0KQXQgbGVhc3QgdGhlIHplcm8g
bGVuZ3RoICdyZXAgbW92c2InIGF0IHRoZSBlbmQgb2YgdGhlIGlubGluZWQNCm1lbWNweSB3aWxs
IG5vdCB0YWtlIDQwKyBjbG9ja3Mgb24gdGhvc2UgY3B1cy4NCg0KCURhdmlkDQoNCg==
