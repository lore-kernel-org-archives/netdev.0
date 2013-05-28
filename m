From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] net: ethernet: xilinx_emaclite: keep protocol selector bits by reading ANAR
Date: Tue, 28 May 2013 17:22:07 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7251@saturn3.aculab.com>
References: <51A4D6FE.3080308@efe-gmbh.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Cc: <davem@davemloft.net>
To: "Jens Renner (EFE)" <renner@efe-gmbh.de>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:51825 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S934660Ab3E1QWl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 May 2013 12:22:41 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 30518-06 for <netdev@vger.kernel.org>;
 Tue, 28 May 2013 17:22:37 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <51A4D6FE.3080308@efe-gmbh.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBUaGlzIHBhdGNoIHJlYWRzIHRoZSBQSFkncyBNSUlfQURWRVJUSVNFIHJlZ2lzdGVyIChBTkFS
KSBiZWZvcmUgbW9kaWZ5aW5nIGl0Lg0KPiBIZW5jZSwgdGhlIHByb3RvY29sIHNlbGVjdG9yIGJp
dHMgKDQ6MCkgd2hpY2ggaW5kaWNhdGUgSUVFRSA4MDMuM3Ugc3VwcG9ydCBhcmUNCj4gcHJldmVu
dGVkIGZyb20gYmVpbmcgY2xlYXJlZC4NCj4gLi4uDQo+ICAgICAgICAgICAgICAgICAvKiBBZHZl
cnRpc2Ugb25seSAxMCBhbmQgMTAwbWJwcyBmdWxsL2hhbGYgZHVwbGV4IHNwZWVkcyAqLw0KPiAt
ICAgICAgICAgICAgICAgcGh5X3dyaXRlKGxwLT5waHlfZGV2LCBNSUlfQURWRVJUSVNFLCBBRFZF
UlRJU0VfQUxMKTsNCj4gKyAgICAgICAgICAgICAgIGFkdiA9IHBoeV9yZWFkKGxwLT5waHlfZGV2
LCBNSUlfQURWRVJUSVNFKTsNCj4gKyAgICAgICAgICAgICAgIGlmIChhZHYgPCAwKQ0KPiArICAg
ICAgICAgICAgICAgICAgICAgICByZXR1cm4gYWR2Ow0KPiArICAgICAgICAgICAgICAgcGh5X3dy
aXRlKGxwLT5waHlfZGV2LCBNSUlfQURWRVJUSVNFLCBhZHYgfCBBRFZFUlRJU0VfQUxMKTsNCg0K
R2l2ZW4gdGhlIGNvbW1lbnQgc2hvdWxkbid0IHRoaXMgYmUgcmVtb3Zpbmcgc29tZSBiaXRzPw0K
DQpJdCBpcyBhIGxvbmcgdGltZSBzaW5jZSBJIHJlYWQgdGhlIGRlZmluaXRpb25zIG9mIHRoZSBB
TkFSIChldGMpLg0KQnV0IEkgcmVtZW1iZXIgaXQgaGF2aW5nIGF0IGxlYXN0IDUgYml0cyBkZWZp
bmVkIGZvciAxME0gYW5kIDEwME0NCm9wZXJhdGlvbiAoaW5jbHVkaW5nIDEwMFQ0KSwgc28gdGhl
IHJlZmVyZW5jZSB0byBrZWVwaW5nIGJpdHMgKDQ6MCkNCnNlZW1zIGNvbmZ1c2luZy4NCg0KCURh
dmlkDQoNCg==
