From: Claudiu Manoil <claudiu.manoil@nxp.com>
Subject: RE: [PATCH net] gianfar: Do not reuse pages from emergency reserve
Date: Thu, 19 Jan 2017 14:04:19 +0000
Message-ID: <AM5PR0401MB256107232ECF3DFC8004657F967E0@AM5PR0401MB2561.eurprd04.prod.outlook.com>
References: <1484797482.16328.13.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0085.outbound.protection.outlook.com ([104.47.2.85]:51520
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752718AbdASOUV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Jan 2017 09:20:21 -0500
In-Reply-To: <1484797482.16328.13.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pi0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+RnJvbTogRXJpYyBEdW1hemV0IFttYWlsdG86
ZXJpYy5kdW1hemV0QGdtYWlsLmNvbV0NCj5TZW50OiBUaHVyc2RheSwgSmFudWFyeSAxOSwgMjAx
NyA1OjQ1IEFNDQo+VG86IERhdmlkIE1pbGxlciA8ZGF2ZW1AZGF2ZW1sb2Z0Lm5ldD4NCj5DYzog
bmV0ZGV2IDxuZXRkZXZAdmdlci5rZXJuZWwub3JnPjsgQ2xhdWRpdSBNYW5vaWwNCj48Y2xhdWRp
dS5tYW5vaWxAZnJlZXNjYWxlLmNvbT4NCj5TdWJqZWN0OiBbUEFUQ0ggbmV0XSBnaWFuZmFyOiBE
byBub3QgcmV1c2UgcGFnZXMgZnJvbSBlbWVyZ2VuY3kgcmVzZXJ2ZQ0KPg0KPkZyb206IEVyaWMg
RHVtYXpldCA8ZWR1bWF6ZXRAZ29vZ2xlLmNvbT4NCj4NCj5BIGRyaXZlciB1c2luZyBkZXZfYWxs
b2NfcGFnZSgpIG11c3Qgbm90IHJldXNlIGEgcGFnZSB0aGF0IGhhZCB0bw0KPnVzZSBlbWVyZ2Vu
Y3kgbWVtb3J5IHJlc2VydmUuDQo+DQo+T3RoZXJ3aXNlIGFsbCBwYWNrZXRzIHVzaW5nIHRoaXMg
cGFnZSB3aWxsIGJlIGltbWVkaWF0ZWx5IGRyb3BwZWQsDQo+dW5sZXNzIGZvciB2ZXJ5IHNwZWNp
ZmljIHNvY2tldHMgaGF2aW5nIFNPQ0tfTUVNQUxMT0MgYml0IHNldC4NCj4NCj5UaGlzIGlzc3Vl
IG1pZ2h0IGJlIGhhcmQgdG8gZGVidWcsIGJlY2F1c2Ugb25seSBhIGZyYWN0aW9uIG9mIHRoZSBS
WA0KPnJpbmcgYnVmZmVyIHdvdWxkIHN1ZmZlciBmcm9tIGRyb3BzLg0KPg0KPkZpeGVzOiA3NTM1
NDE0OGNlNjkgKCJnaWFuZmFyOiBBZGQgcGFnZWQgYWxsb2NhdGlvbiBhbmQgUnggUy9HIikNCj5T
aWduZWQtb2ZmLWJ5OiBFcmljIER1bWF6ZXQgPGVkdW1hemV0QGdvb2dsZS5jb20+DQo+Q2M6IENs
YXVkaXUgTWFub2lsIDxjbGF1ZGl1Lm1hbm9pbEBmcmVlc2NhbGUuY29tPg0KDQpUaGFua3MuDQoN
CkFja2VkLWJ5OiBDbGF1ZGl1IE1hbm9pbCA8Y2xhdWRpdS5tYW5vaWxAbnhwLmNvbT4NCg==
