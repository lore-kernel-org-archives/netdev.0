From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH v3 net-next] bnx2x: ethtool -x support for rss_key
Date: Sun, 25 Dec 2016 11:36:53 +0000
Message-ID: <BY2PR07MB2309A45B4840D485F98148FA8D970@BY2PR07MB2309.namprd07.prod.outlook.com>
References: <1476810487.5650.68.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480875338.18162.475.camel@edumazet-glaptop3.roam.corp.google.com>
         <BL2PR07MB2306F104F51FD4494FDC172E8D830@BL2PR07MB2306.namprd07.prod.outlook.com>
 <1482342498.8944.62.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0075.outbound.protection.outlook.com ([104.47.36.75]:59808
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753137AbcLYLg4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Dec 2016 06:36:56 -0500
In-Reply-To: <1482342498.8944.62.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ICsJaWYgKGtleSkgew0KPiArCQlXQVJOX09OX09OQ0UoYm54MnhfZ2V0X3J4Zmhfa2V5X3NpemUo
ZGV2KSAhPQ0KPiBUX0VUSF9SU1NfS0VZICogNCk7DQo+ICsJCWJueDJ4X2dldF9yc3Nfa2V5KCZi
cC0+cnNzX2NvbmZfb2JqLCBrZXkpOw0KPiArCX0NCg0KVGhpcyBkb2VzbuKAmXQgd29yayBWRnMg
W3RoZSBQRiBoYXMgdGhlIFJTUyBjb25maWd1cmF0aW9uIG9iamVjdCBpbiB0aGVpcg0KY2FzZTsg
VGhleSBkb24ndCBoYXZlIGl0XSwgd2hpY2ggaXMgZmluZSBhcyAna2V5JyBzaG91bGQgbmV2ZXIg
YmUgc2V0IGZvcg0KdGhlbSBbc2luY2UgeW91J3JlIGFkZGluZyBibngyeF9nZXRfcnhmaF9rZXlf
c2l6ZSgpIHRvIGV0aHRvb2wgb3BzDQpvbmx5IGZvciBQRnNdLiBCdXQgdGhpcyBwcm9iYWJseSBz
dGlsbCB3b3J0aCBhIGNvbW1lbnQsIHRob3VnaC4NCg0KPiAtCW1lbWNweShyc3MucnNzX2tleSwg
cnNzX3Rsdi0+cnNzX2tleSwgc2l6ZW9mKHJzc190bHYtPnJzc19rZXkpKTsNCj4gKwltZW1jcHko
JnZmLT5yc3NfY29uZl9vYmoucnNzX2tleSwgcnNzX3Rsdi0+cnNzX2tleSwNCj4gK3NpemVvZihy
c3NfdGx2LT5yc3Nfa2V5KSk7DQo+ICAJcnNzLnJzc19vYmogPSAmdmYtPnJzc19jb25mX29iajsN
Cj4gIAlyc3MucnNzX3Jlc3VsdF9tYXNrID0gcnNzX3Rsdi0+cnNzX3Jlc3VsdF9tYXNrOw0KDQpU
aGUgY2hhbmdlIHlvdSd2ZSBhcHBsaWVkIGluIGJueDJ4X3NldHVwX3JzcygpIHNob3VsZCBhZmZl
Y3QgaGVyZQ0KYXMgd2VsbCwgbWVhbmluZyB0aGUgUEYgd291bGQgY29weSB0aGUgcGFyYW1ldGVy
cyBpbnRvIHRoZSBQRidzIFJTUw0KY29uZmlndXJhdGlvbiBvYmplY3QgYmVsb25naW5nIHRvIHRo
ZSBWRiBmcm9tIHRoZSBwYXJhbWV0ZXIuDQoNClRoaXMgY2hhbmdlIHdvdWxkIGNhdXNlIHRoZSBQ
RiB0byBjb25maWd1cmUgdGhlIFZGJ3MgUlNTIGtleQ0KYXMgYWxsLXplcm9zIFthcyBwYXJhbWV0
ZXJzIHdlcmUgaW5pdGlhbGx5IHplcm9lZF0uDQo=
