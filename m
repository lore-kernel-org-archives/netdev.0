From: Arvid Brodin <Arvid.Brodin@xdin.com>
Subject: Do I need to skb_put() Ethernet frames to a minimum of 60 bytes?
Date: Tue, 14 Aug 2012 18:53:57 +0000
Message-ID: <502A9EC4.4040208@xdin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spam1.webland.se ([91.207.112.90]:58365 "EHLO spam1.webland.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757307Ab2HNTE7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2012 15:04:59 -0400
Content-Language: en-US
Content-ID: <0BF38BA07B609244AA440365676D488F@redbull.xdin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SGksDQoNCklmIEkgY3JlYXRlIGFuIHNrX2J1ZmYgd2l0aCBhIHBheWxvYWQgb2YgbGVzcyB0aGFu
IDI4IGJ5dGVzIChldGhoZWFkZXIgKyBkYXRhKSwNCmFuZCBzZW5kIGl0IHVzaW5nIHRoZSBjYWRl
bmNlL21hY2IgKEV0aGVybmV0KSBkcml2ZXIsIEkgZ2V0DQoNCmV0aDA6IFRYIHVuZGVycnVuLCBy
ZXNldHRpbmcgYnVmZmVycw0KDQpOb3cgSSBrbm93IHRoZSBtaW5pbXVtIEV0aGVybmV0IGZyYW1l
IHNpemUgaXMgNjQgYnl0ZXMgKGluY2x1ZGluZyB0aGUgNC1ieXRlDQpGQ1MpLCBidXQgd2hvc2Ug
cmVzcG9uc2liaWxpdHkgaXMgaXQgdG8gcGFkIHRoZSBmcmFtZSB0byB0aGlzIHNpemUgaWYgbmVj
ZXNzYXJ5Pw0KTWluZSBvciB0aGUgZHJpdmVyJ3MgLSBpLmUuIHNob3VsZCBJIGp1c3Qgc2tiX3B1
dCgpIHRvIHRoZSBtaW5pbXVtIHNpemUgb3INCnNob3VsZCBJIHJlcG9ydCB0aGUgdW5kZXJydW4g
YXMgYSBkcml2ZXIgYnVnPw0KDQoNCi0tIA0KQXJ2aWQgQnJvZGluIHwgQ29uc3VsdGFudCAoTGlu
dXgpDQpYRElOIEFCIHwgSmFuIFN0ZW5iZWNrcyBUb3JnIDE3IHwgU0UtMTY0IDQwIEtpc3RhIHwg
U3dlZGVuIHwgeGRpbi5jb20=
