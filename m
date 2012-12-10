From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: RE: [PATCH net-next] bnx2x: use netdev_alloc_frag()
Date: Mon, 10 Dec 2012 22:57:44 +0000
Message-ID: <504C9EFCA2D0054393414C9CB605C37F1BFC4273@SJEXCHMB06.corp.ad.broadcom.com>
References: <1355177766.27891.68.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: base64
Cc: netdev <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3630 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751595Ab2LJW6P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Dec 2012 17:58:15 -0500
In-Reply-To: <1355177766.27891.68.camel@edumazet-glaptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBFcmljIER1bWF6ZXQgW21haWx0
bzplcmljLmR1bWF6ZXRAZ21haWwuY29tXQ0KPiBTZW50OiBUdWVzZGF5LCBEZWNlbWJlciAxMSwg
MjAxMiAxMjoxNiBBTQ0KPiBUbzogRGF2aWQgTWlsbGVyDQo+IENjOiBuZXRkZXY7IEVpbG9uIEdy
ZWVuc3RlaW47IERtaXRyeSBLcmF2a292DQo+IFN1YmplY3Q6IFtQQVRDSCBuZXQtbmV4dF0gYm54
Mng6IHVzZSBuZXRkZXZfYWxsb2NfZnJhZygpDQo+IA0KPiBGcm9tOiBFcmljIER1bWF6ZXQgPGVk
dW1hemV0QGdvb2dsZS5jb20+DQo+IA0KPiBVc2luZyBuZXRkZXZfYWxsb2NfZnJhZygpIGluc3Rl
YWQgb2Yga21hbGxvYygpIHBlcm1pdHMgYmV0dGVyIEdSTyBvcg0KPiBUQ1AgY29hbGVzY2luZyBi
ZWhhdmlvciwgYXMgc2tiX2dyb19yZWNlaXZlKCkgZG9lc24ndCBoYXZlIHRvIGZhbGxiYWNrDQo+
IHRvIGZyYWdfbGlzdCBvdmVyaGVhZC4NCj4gDQo+IFNpZ25lZC1vZmYtYnk6IEVyaWMgRHVtYXpl
dCA8ZWR1bWF6ZXRAZ29vZ2xlLmNvbT4NCj4gQ2M6IERtaXRyeSBLcmF2a292IDxkbWl0cnlAYnJv
YWRjb20uY29tPg0KPiBDYzogRWlsb24gR3JlZW5zdGVpbiA8ZWlsb25nQGJyb2FkY29tLmNvbT4N
Cg0KVGhhbmtzIGEgbG90LCBFcmljIQ0KDQpBY2tlZC1ieTogRG1pdHJ5IEtyYXZrb3YgPGRtaXRy
eUBicm9hZGNvbS5jb20+DQo=
