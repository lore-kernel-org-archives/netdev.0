From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH net] net: dsa: skb_put_padto() already frees nskb
Date: Tue, 22 Aug 2017 18:01:00 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40B0511C@CHN-SV-EXMX02.mchp-main.com>
References: <20170821194143.27885-1-f.fainelli@gmail.com>
 <9235D6609DB808459E95D78E17F2E43D40B048CD@CHN-SV-EXMX02.mchp-main.com>
 <52a0e01e-8a55-2360-ca11-b65c613a812c@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: <davem@davemloft.net>, <andrew@lunn.ch>,
        <vivien.didelot@savoirfairelinux.com>
To: <f.fainelli@gmail.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa2.microchip.iphmx.com ([68.232.149.84]:28472 "EHLO
        esa2.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751716AbdHVSBr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 14:01:47 -0400
In-Reply-To: <52a0e01e-8a55-2360-ca11-b65c613a812c@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiA+IEJlY2F1c2Ugc2tiX3B1dF9wYWR0bygpIGZyZWVzIHNrYiB3aGVuIGl0IGZhaWxzLCAgYmVs
b3cgbGluZXMgaW4NCj4gZTcxY2I5ZTAwOTIyDQo+ID4gKCJuZXQ6IGRzYToga3N6OiBmaXggc2ti
IGZyZWVpbmciKSB3aWxsIGJlIGFuIGlzc3VlIHRvLg0KPiA+DQo+ID4gCWlmIChza2JfdGFpbHJv
b20oc2tiKSA+PSBwYWRsZW4gKyBLU1pfSU5HUkVTU19UQUdfTEVOKSB7DQo+ID4gKwkJaWYgKHNr
Yl9wdXRfcGFkdG8oc2tiLCBza2ItPmxlbiArIHBhZGxlbikpDQo+ID4gKwkJCXJldHVybiBOVUxM
Ow0KPiA+ICsNCj4gPg0KPiA+IFdoZW4gaXQgZmFpbHMgc2tiIHdpbGwgYmUgZnJlZWQgdHdpY2Ug
aW4gc2tiX3B1dF9wYWR0bygpIGFuZA0KPiA+IGNhbGxlciBvZiBkc2Ffc2xhdmVfeG1pdCgpLg0K
PiANCj4gWW91IGFyZSByaWdodCwgSSBhbSBub3Qgc3VyZSB3aGF0IGlzIHRoZSBiZXN0IHdheSB0
byBmaXggdGFnX2tzei5jIG90aGVyDQo+IHRoYW4gc29tZWhvdyBvcGVuIGNvZGluZyBza2JfcHV0
X3BhZHRvKCkgbWludXMgdGhlIGZyZWVpbmcgb24gZXJyb3IgcGFydD8NCg0KQWdyZWUuIE1heSBu
ZWVkIHRvIGdvIGJhY2sgdG8gMXN0IHN1Ym1pc3Npb24gd2l0aG91dCBza2JfcHV0X3BhZHRvKCku
DQpXaWxsIGNoZWNrIG1vcmUgaWYgYW55IG90aGVyIGlkZWFzLg0KDQpUaGFua3MuDQpXb29qdW5n
DQo=
