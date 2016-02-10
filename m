From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH net-next 2/3] lan78xx: setting phy features in phy driver
Date: Wed, 10 Feb 2016 23:18:27 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D404ABB4D@CHN-SV-EXMX02.mchp-main.com>
References: <9235D6609DB808459E95D78E17F2E43D404AB9F9@CHN-SV-EXMX02.mchp-main.com>
 <56BBC0BB.3010100@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: <netdev@vger.kernel.org>
To: <f.fainelli@gmail.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp01.microchip.com ([198.175.253.37]:55953 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752233AbcBJXSc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2016 18:18:32 -0500
In-Reply-To: <56BBC0BB.3010100@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiA+ICtzdGF0aWMgaW50IGxhbjg4eHhfY29uZmlnX2luaXQoc3RydWN0IHBoeV9kZXZpY2UgKnBo
eWRldikNCj4gPiArew0KPiA+ICsJcGh5ZGV2LT5zdXBwb3J0ZWQgJj0gcGh5ZGV2LT5kcnYtPmZl
YXR1cmVzOw0KPiA+ICsJcGh5ZGV2LT5hZHZlcnRpc2luZyAmPSBwaHlkZXYtPmRydi0+ZmVhdHVy
ZXM7DQo+IA0KPiBUaGlzIGxvb2tzIHN1c3BpY2lvdXMsIHBoeV9wcm9iZSgpIHRha2VzIHRoZSBk
cml2ZXIgc3VwcG9ydGVkIGZlYXR1cmVzDQo+IGFuZCBhc3NpZ25zIGl0IHRvIHBoeWRldi0+c3Vw
cG9ydGVkLCBhbmQgcGh5ZGV2LT5hZHZlcnRpc2luZywgaXMgbm90DQo+IHRoYXQgd29ya2luZyBz
b21laG93Pw0KPiANCj4gZ2VucGh5X2NvbmZpZ19pbml0KCkgZG9lcyBsb29rIGF0IHRoZSBjdXJy
ZW50IE1JSV9CTVJTIHZhbHVlIHRvDQo+IGRldGVybWluZSB3aGF0IGlzIHN1cHBvcnRlZCBieSB0
aGUgUEhZLCBhbmQgbWFza3MgaXQgaW4NCj4gcGh5ZGV2LT5zdXBwb3J0ZWQsIHNvIHRoYXQgY291
bGQgaW5kZWVkIGJlIGFuIGlzc3VlIGlmIHdlIGhhZCBub3QgaGFkIGENCj4gY2hhbmdlIHRvIG1h
c2sgd2l0aCB0aGUgc3VwcG9ydGVkIG1vZGVzIGJlZm9yZS4NCj4gDQo+IEkgdGhpbmsgd2UgbmVl
ZCBtb3JlIGV4cGxhbmF0aW9uIGhlcmUgYXMgdG8gd2hhdCBraW5kIG9mIGJ1ZyB5b3UgbWF5DQo+
IGhhdmUgYmVlbiBvYnNlcnZpbmcsIHRoZXJlIGNvdWxkIGJlIG9uZS4NCg0KU1VQUE9SVEVEX1Bh
dXNlICYgU1VQUE9SVEVEX0FzeW1fUGF1c2Ugc2V0IGF0IHBoeWRldi0+ZmVhdHVyZXMgIGFyZSBy
ZW1vdmVkIGJ5IGdlbnBoeV9jb25maWdfaW5pdCgpLg0KQXMgeW91IHBvaW50ZWQsIGl0IG1heSBi
ZSBiZXR0ZXIgdG8gbW9kaWZ5IGdlbnBoeV9jb25maWdfaW5pdCgpIHRoYW4gZWFjaCBkcml2ZXIn
cyBjb25maWdfaW5pdCByb3V0aW5lLg0KDQotIFdvb2p1bmcNCg==
