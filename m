From: "Loke, Chetan" <Chetan.Loke@netscout.com>
Subject: RE: [PATCH 2/2] packet: Add fanout support.
Date: Tue, 5 Jul 2011 12:03:29 -0400
Message-ID: <D3F292ADF945FB49B35E96C94C2061B91257D61B@nsmail.netscout.com>
References: <20110704.212014.236340473910292460.davem@davemloft.net> <1309846875.2720.43.camel@edumazet-laptop>  <4E12B5A6.2020802@inliniac.net> <1309849214.2720.45.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "David Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"Victor Julien" <victor@inliniac.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod6og101.obsmtp.com ([64.18.1.181]:53607 "HELO
	exprod6og101.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753318Ab1GEQDc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 12:03:32 -0400
Content-class: urn:content-classes:message
In-Reply-To: <1309849214.2720.45.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBuZXRkZXYtb3duZXJAdmdlci5r
ZXJuZWwub3JnIFttYWlsdG86bmV0ZGV2LQ0KPiBvd25lckB2Z2VyLmtlcm5lbC5vcmddIE9uIEJl
aGFsZiBPZiBFcmljIER1bWF6ZXQNCj4gU2VudDogSnVseSAwNSwgMjAxMSAzOjAwIEFNDQo+IFRv
OiBWaWN0b3IgSnVsaWVuDQo+IENjOiBEYXZpZCBNaWxsZXI7IG5ldGRldkB2Z2VyLmtlcm5lbC5v
cmcNCj4gU3ViamVjdDogUmU6IFtQQVRDSCAyLzJdIHBhY2tldDogQWRkIGZhbm91dCBzdXBwb3J0
Lg0KPiANCj4gTGUgbWFyZGkgMDUganVpbGxldCAyMDExIMOgIDA4OjU2ICswMjAwLCBWaWN0b3Ig
SnVsaWVuIGEgw6ljcml0IDoNCj4gDQo+ID4gSXMgdGhpcyBzdGlsbCBhbHNvIHRydWUgZm9yIElQ
IGZyYWdtZW50cz8NCj4gPg0KPiANCj4gVGhpcyBwb2ludCB3YXMgYWxyZWFkeSByYWlzZWQuIElQ
IGZyYWdtZW50cyBoYXZlIHJ4aGFzaCA9IDAsIG9idmlvdXNseSwNCj4gc2luY2Ugd2UgZG9udCBo
YXZlIGZ1bGwgaW5mb3JtYXRpb24gKHNvdXJjZSAvIGRlc3RpbmF0aW9uIHBvcnRzIGZvcg0KPiBl
eGFtcGxlKQ0KDQpDYW4gd2Ugbm90IGRvIHNvbWV0aGluZyBsaWtlOg0KDQphID0gc3JjX2lwX2Fk
ZHI7DQpiID0gZHN0X2lwX2FkZHI7DQoNCmlmIChpcF9pc19mcmFnbWVudChpcF9oZHIoc2tiKSkp
DQoJYyA9IGlwX2hkci0+aWQ7DQplbHNlDQoJYyA9IHNyY19wb3J0IHwgZGVzdF9wb3J0IDsgLyog
cG9ydF8zMiBldGMgLSBTaW1pbGFyIHRvIHdoYXQgd2UgaGF2ZSB0b2RheSAqLw0KDQovKiBzd2Fw
IGEvYiBldGMgKi8NCmpoYXNoM193b3JkcyhhLGIsYyk7DQoNCg0KDQpDaGV0YW4gTG9rZQ0K
