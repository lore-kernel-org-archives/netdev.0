From: Amit Salecha <amit.salecha@qlogic.com>
Subject: RE: [PATCH] qlcnic: dma address align check
Date: Tue, 26 Oct 2010 05:52:13 -0500
Message-ID: <99737F4847ED0A48AECC9F4A1974A4B80F871A8182@MNEXMB2.qlogic.org>
References: <1288085882-11988-1-git-send-email-amit.salecha@qlogic.com>
	 <1288085882-11988-5-git-send-email-amit.salecha@qlogic.com>
	 <1288086894.3169.53.camel@edumazet-laptop>
	 <99737F4847ED0A48AECC9F4A1974A4B80F871A817A@MNEXMB2.qlogic.org>
 <1288089033.3169.73.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexcashub1.qlogic.com ([198.70.193.61]:5721 "EHLO
	avexcashub1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932363Ab0JZKwT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 06:52:19 -0400
In-Reply-To: <1288089033.3169.73.camel@edumazet-laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiA+IElzIHBjaV9hbGxvY19jb25zaXN0ZW50IGd1YXJhbnRlZSB0byBnaXZlIFBBR0UgYWxpZ24g
ZG1hIGFkZHJlc3MgPw0KPiANCj4gSSBiZWxpZXZlIHNvDQo+IA0KPiBCeSB0aGUgd2F5LCB5b3Ug
c2hvdWxkIHVzZSBkbWFfYWxsb2NfY29oZXJlbnQoKSBpbnN0ZWFkIG9mDQo+IHBjaV9hbGxvY19j
b25zaXN0ZW50KCkgc28gdGhhdCB5b3UgY2FuIHVzZSBHRlBfS0VSTkVMIGFsbG9jYXRpb25zDQo+
IGluc3RlYWQgb2YgR0ZQX0FUT01JQywgaXQgbWlnaHQgaGVscCBpbiBsb3cgbWVtb3J5IGNvbmRp
dGlvbnMgKGlmIHlvdQ0KPiBkb250IGhvbGQgYSBzcGlubG9jayBhdCB0aGlzIHBvaW50KQ0KPiAN
Cj4gDQo+IElmIFRYX0RFU0NfUklOR1NJWkUodHhfcmluZykgaXMgbm90IGEgcG93ZXIgb2YgdHdv
LCB0aGVuIHllcyB5b3UgY291bGQNCj4gcHJvYmFibHkgYWRkIDY0IGJ5dGVzIGFuZCBhdm9pZCBh
bGxvY2F0aW5nIGEgZnVsbCBwYWdlIG9ubHkgZm9yIHRoZSB1MzINCj4gZmllbGQgOykNCj4gDQo+
IA0KDQpUWF9ERVNDX1JJTkdTSVpFIGlzIHBvd2VyIG9mIHR3by4NCg0KSWYgcGNpX2FsbG9jX2Nv
bnNpc3RlbnQgZ3VhcmFudGVlIHRvIGdpdmUgUEFHRSBhbGlnbiBkbWEgYWRkcmVzcywgdGhlbiB0
aGlzIHBhdGNoIGlzIG5vdCByZXF1aXJlZC4NCj4NCg==
