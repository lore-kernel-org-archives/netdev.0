From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH net-next] bnx2x: avoid soft lockup in bnx2x_poll()
Date: Tue, 8 Dec 2015 17:02:44 +0000
Message-ID: <CO2PR11MB00881A410C4E35D3859CB84C97080@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1449582880.7632.19.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: netdev <netdev@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	Willem de Bruijn <willemb@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0134.outbound.protection.outlook.com ([157.56.111.134]:52350
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750737AbbLHRCs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2015 12:02:48 -0500
In-Reply-To: <1449582880.7632.19.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBVbmRlciBoZWF2eSBUWCBsb2FkLCBibngyeF9wb2xsKCkgY2FuIGxvb3AgZm9yZXZlciBhbmQg
dHJpZ2dlciBzb2Z0IGxvY2t1cCBidWdzLg0KPiANCj4gQSBuYXBpIHBvbGwgaGFuZGxlciBtdXN0
IHlpZWxkIGFmdGVyIG9uZSBUWCBjb21wbGV0aW9uIHJvdW5kLCByaXNrIG9mIGxpdmVsb2NrIGlz
DQo+IHRvbyBoaWdoIG90aGVyd2lzZS4NCj4gDQo+IEJ1ZyBpcyB2ZXJ5IGVhc3kgdG8gdHJpZ2dl
ciB1c2luZyBhIGRlYnVnIGJ1aWxkLCBhbmQgdWRwIGZsb29kLCBiZWNhdXNlIG9mIGFkZGVkDQo+
IGNwdSBjeWNsZXMgaW4gVFggY29tcGxldGlvbiwgYW5kIHdlIGRvIG5vdCByZWNlaXZlIGVub3Vn
aCBwYWNrZXRzIHRvIGJyZWFrIHRoZQ0KPiBsb29wLg0KDQpFcmljIC0gSSB1bmRlcnN0YW5kIHdo
YXQgeW91J3JlIGRvaW5nIGFuZCBpdCBsb29rcyBmaW5lIFt0byBtZSwgYXQgbGVhc3RdLg0KT3V0
IG9mIGN1cmlvc2l0eSwgZG8geW91IGtub3cgd2hldGhlciByZW1vdmluZyB0aGUgbG9vcCBkYW1h
Z2VzIGFueQ0Kb3RoZXIgZmxvdywgaS5lLiwgYnkgc2xvd2luZyB0cmFuc21pdHRlciBhcyB0cmFu
c21pc3Npb24gcmluZ3MgZ2V0cyBmaWxsZWQNCmNvbXBsZXRlbHkgYmV0d2VlbiBjb25zZWN1dGl2
ZSBOQVBJIHJ1bnM/IA0K
