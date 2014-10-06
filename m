From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next] net: introduce netdevice gso_min_segs attribute
Date: Mon, 6 Oct 2014 10:20:08 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D174AC1A3@AcuExch.aculab.com>
References: <1412501722-25092-1-git-send-email-amirv@mellanox.com>
	 <54312F50.2060608@mellanox.com>
	 <1412524252.11091.3.camel@edumazet-glaptop2.roam.corp.google.com>
 <1412529087.11091.14.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Eric Dumazet <edumazet@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	"Or Gerlitz" <ogerlitz@mellanox.com>,
	Ido Shamay <idos@mellanox.com>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>,
	Amir Vadai <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:52044 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751316AbaJFKVe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Oct 2014 06:21:34 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 26388-09 for <netdev@vger.kernel.org>;
 Mon,  6 Oct 2014 11:21:26 +0100 (BST)
In-Reply-To: <1412529087.11091.14.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0IDxlZHVtYXpldEBnb29nbGUuY29tPg0KPiBTb21lIFRTTyBlbmdp
bmVzIG1pZ2h0IGhhdmUgYSB0b28gaGVhdnkgc2V0dXAgY29zdCwgdGhhdCBpbXBhY3RzDQo+IHBl
cmZvcm1hbmNlIG9uIGhvc3RzIHNlbmRpbmcgc21hbGwgYnVyc3RzICgyIE1TUyBwZXIgcGFja2V0
KS4NCj4gDQo+IFRoaXMgcGF0Y2ggYWRkcyBhIGRldmljZSBnc29fbWluX3NlZ3MsIGFsbG93aW5n
IGRyaXZlcnMgdG8gc2V0DQo+IGEgbWluaW11bSBzZWdtZW50IHNpemUgZm9yIFRTTyBwYWNrZXRz
LCBhY2NvcmRpbmcgdG8gdGhlIE5JQw0KPiBwZXJmb3JtYW5jZS4NCj4gDQo+IFRlc3RlZCBvbiBh
IG1seDQgTklDLCB0aGlzIGFsbG93cyB0byBnZXQgYSB+MTEwJSBpbmNyZWFzZSBvZg0KPiB0aHJv
dWdocHV0IHdoZW4gc2VuZGluZyAyIE1TUyBwZXIgcGFja2V0Lg0KDQpEb2Vzbid0IHRoaXMgYWxs
IGRlcGVuZCBvbiB3aGF0IHlvdSBuZWVkIHRvIG9wdGltaXNlIGZvci4NCkkgY2FuIHRoaW5rIG9m
IHRocmVlXldzZXZlcmFsIG1haW4gY2FzZXM6DQoxKSBtaW5pbWlzaW5nIGNwdSB1c2Ugd2hpbGUg
c2F0dXJhdGluZyB0aGUgbG9jYWwgbmV0d29yay4NCjIpIG1pbmltaXNpbmcgbGF0ZW5jeSBmb3Ig
c2luZ2xlIHBhY2tldHMuDQozKSBtYXhpbWlzaW5nIHRocm91Z2hwdXQgZm9yIGEgc2luZ2xlIGNv
bm5lY3Rpb24uDQo0KSBtaW5pbWlzaW5nIGNwdSB1c2Ugd2hlbiBoYW5kbGluZyBhIGxhcmdlIG51
bWJlciBvZiBjb25uZWN0aW9ucy4NCnBsdXMgYWxsIHRoZSB2YXJpYXRpb25zIGluIHBhY2tldCBz
aXplLg0KDQpJJ20gbm90IHN1cmUgd2hhdCB5b3UgYXJlIHRyYWRpbmcgZm9yIHdoYXQgaGVyZS4N
Cg0KTWF5YmUgZ3NvID0gdHhfYnVyc3RpbmcgaXMgYWxtb3N0IGFsd2F5cyBmYXN0ZXIgb24gc29t
ZSBoYXJkd2FyZT8NCihFc3BlY2lhbGx5IGlmIGFuIGlkbGUgbWFjIGVuZ2luZSBpcyAna2lja2Vk
JyBmb3IgdGhlIGZpcnN0IHBhY2tldA0Kb2YgYSBidXJzdC4pDQoNCglEYXZpZA0KDQo=
