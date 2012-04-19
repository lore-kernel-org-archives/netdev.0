From: "Dave, Tushar N" <tushar.n.dave@intel.com>
Subject: RE: rx_dropped packets stop with tcpdump running
Date: Thu, 19 Apr 2012 17:57:24 +0000
Message-ID: <061C8A8601E8EE4CA8D8FD6990CEA8910FF2D23F@ORSMSX102.amr.corp.intel.com>
References: <DUB108-W3E0658169335663BE7574B23D0@phx.gbl>
	 <1334841865.2395.177.camel@edumazet-glaptop>
 <1334842088.2395.178.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Marco Berizzi <pupilla@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:48423 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753010Ab2DSR52 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Apr 2012 13:57:28 -0400
In-Reply-To: <1334842088.2395.178.camel@edumazet-glaptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TWFyY28sDQoNCkRvIHlvdSBzZWUgYW55IHBhY2tldCBkcm9wIGF0IEhXIGxldmVsPw0KSG93IGFy
ZSB5b3UgbWVhc3VyaW5nIGRyb3AgcGFja2V0PyBldGh0b29sIC1TIGV0aHggc2hvd3MgeW91IGFu
eSBwYWNrZXQgZHJvcD8NCkFsc28gY2FuIHlvdSBwbGVhc2Ugc2VuZCBtZSB0aGUgZWVwcm9tIGR1
bXAgb2YgeW91IGNhcmQvTE9NLiBldGh0b29sIC1lIGV0aHgNCg0KDQotVHVzaGFyDQoNCj4tLS0t
LU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPkZyb206IG5ldGRldi1vd25lckB2Z2VyLmtlcm5lbC5v
cmcgW21haWx0bzpuZXRkZXYtb3duZXJAdmdlci5rZXJuZWwub3JnXQ0KPk9uIEJlaGFsZiBPZiBF
cmljIER1bWF6ZXQNCj5TZW50OiBUaHVyc2RheSwgQXByaWwgMTksIDIwMTIgNjoyOCBBTQ0KPlRv
OiBNYXJjbyBCZXJpenppDQo+Q2M6IG5ldGRldkB2Z2VyLmtlcm5lbC5vcmcNCj5TdWJqZWN0OiBS
ZTogcnhfZHJvcHBlZCBwYWNrZXRzIHN0b3Agd2l0aCB0Y3BkdW1wIHJ1bm5pbmcNCj4NCj5PbiBU
aHUsIDIwMTItMDQtMTkgYXQgMTU6MjQgKzAyMDAsIEVyaWMgRHVtYXpldCB3cm90ZToNCj4NCj4+
IFdoZW4gbGludXggcmVjZWl2ZXMgYSBwYWNrZXQgd2l0aCBubyBwcm90b2NvbCBoYW5kbGVyLCB3
ZSBpbmNyZW1lbnQNCj4+IHRoZSByeF9kcm9wcGVkIGNvdW50ZXIuDQo+Pg0KPj4gV2hlbiB5b3Ug
c3RhcnQgYSB0Y3BkdW1wLCBhbGwgcGFja2V0cyBhcmUgaGFuZGxlZCwgc28gd2UgZG9udA0KPj4g
aW5jcmVtZW50IHJ4X2Ryb3BwZWQgZm9yIHRoaXMgcmVhc29uIGFueW1vcmUuDQo+Pg0KPj4NCj4N
Cj5JdHMgZG9uZSBzaW5jZSAyLjYuMzcgKGNvbW1pdCBjYWY1ODZlNSkNCj4NCj4NCj4NCj4NCj4t
LQ0KPlRvIHVuc3Vic2NyaWJlIGZyb20gdGhpcyBsaXN0OiBzZW5kIHRoZSBsaW5lICJ1bnN1YnNj
cmliZSBuZXRkZXYiIGluIHRoZQ0KPmJvZHkgb2YgYSBtZXNzYWdlIHRvIG1ham9yZG9tb0B2Z2Vy
Lmtlcm5lbC5vcmcgTW9yZSBtYWpvcmRvbW8gaW5mbyBhdA0KPmh0dHA6Ly92Z2VyLmtlcm5lbC5v
cmcvbWFqb3Jkb21vLWluZm8uaHRtbA0K
