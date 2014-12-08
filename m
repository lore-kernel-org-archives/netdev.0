From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net] net/mlx4_en: correct the endianness of doorbell_qpn
 on big endian platform
Date: Mon, 8 Dec 2014 10:00:19 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CA04A51@AcuExch.aculab.com>
References: <1417315431-16761-1-git-send-email-weiyang@linux.vnet.ibm.com>
	 <20141205.213112.1199355931404701216.davem@davemloft.net>
 <1417844801.15618.30.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "weiyang@linux.vnet.ibm.com" <weiyang@linux.vnet.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gideonn@mellanox.com" <gideonn@mellanox.com>,
	"edumazet@google.com" <edumazet@google.com>,
	"amirv@mellanox.com" <amirv@mellanox.com>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:34957 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754614AbaLHKBO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Dec 2014 05:01:14 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 13108-10 for <netdev@vger.kernel.org>;
 Mon,  8 Dec 2014 10:01:03 +0000 (GMT)
In-Reply-To: <1417844801.15618.30.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0DQo+IE9uIEZyaSwgMjAxNC0xMi0wNSBhdCAyMTozMSAtMDgwMCwg
RGF2aWQgTWlsbGVyIHdyb3RlOg0KPiANCj4gPiBHdXlzLCBsZXQncyBmaWd1cmUgb3V0IHdoYXQg
d2UgYXJlIGRvaW5nIHdpdGggdGhpcyBwYXRjaC4NCj4gPiAtLQ0KPiANCj4gT2ggd2VsbCwgcGF0
Y2ggaXMgZmluZSwgcGxlYXNlIGFwcGx5IGl0LCB0aGFua3MgIQ0KDQpJJ20gbm90IHRvIHN1cmUg
dGhhdCB0aGUgcGF0Y2ggZG9lc24ndCBnZW5lcmF0ZSBhIHNvZnR3YXJlIGJ5dGVzd2FwDQpmb2xs
b3dlZCBieSBhIGJ5dGVzd2FwcGluZyB3cml0ZSBvbiBwcGMgLSBjbGVhcmx5IG5vdCBpZGVhbC4N
Ckl0IG1pZ2h0IGV2ZW4gZ2VuZXJhdGUgYmFjayB0byBiYWNrIHNvZnR3YXJlIGJ5dGVzd2Fwcy4N
Cg0KSWYgdGhlIHdyaXRlIHRvIHRoZSBkb29yYmVsbCByZWdpc3RlciBpbmNsdWRlcyBhIGJ5dGVz
d2FwIG9uIEJFIChwcGMpDQp0aGVuIHRoZXJlIGlzIG5vIHJlYWwgdmFsdWUgaW4ga2VlcGluZyB0
aGUgdmFsdWUgYXMgQkUuDQoNCk9UT0ggcHBjIG91Z2h0IHRvIGhhdmUgd2F5cyBvZiBkb2luZyBJ
TyB3cml0ZXMgd2l0aG91dCB0aGUgYnl0ZXN3YXANCihhbmQgYnl0ZXN3YXBwaW5nIGFjY2Vzc2Vz
IHRvIG5vbi1pbyBtZW1vcnkgZm9yIHRoYXQgbWF0dGVyKS4NCg0KV2hhdCBoYXBwZW5zIG9uIGEg
QkUgc3lzdGVtIHdpdGggQkUgcGVyaXBoZXJhbHMgaXMgYW5vdGhlciBtYXR0ZXIuDQoNCglEYXZp
ZA0KDQo=
