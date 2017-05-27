From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH net-next 1/3] net: phy: Create sysfs reciprocal links
 for attached_dev/phydev
Date: Sat, 27 May 2017 00:43:16 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40A9DB14@CHN-SV-EXMX02.mchp-main.com>
References: <20170524193354.10739-1-f.fainelli@gmail.com>
 <20170524193354.10739-2-f.fainelli@gmail.com>
 <9235D6609DB808459E95D78E17F2E43D40A9DAA2@CHN-SV-EXMX02.mchp-main.com>
 <d2d97683-3fcc-6603-09e1-13818464de18@gmail.com>
 <9235D6609DB808459E95D78E17F2E43D40A9DACE@CHN-SV-EXMX02.mchp-main.com>
 <44f24fbd-5093-faa2-02cd-f8d4d835b59d@gmail.com>
 <9235D6609DB808459E95D78E17F2E43D40A9DAF6@CHN-SV-EXMX02.mchp-main.com>
 <05a159af-6689-70db-9506-09059a09f1a5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: <davem@davemloft.net>, <andrew@lunn.ch>
To: <f.fainelli@gmail.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa6.microchip.iphmx.com ([216.71.154.253]:3307 "EHLO
        esa6.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1948892AbdE0AnS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 20:43:18 -0400
In-Reply-To: <05a159af-6689-70db-9506-09059a09f1a5@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SGkgRmxvcmlhbiwNCiANCj4gT0ssIHNvIGhlcmUgaXMgd2hhdCBpcyBoYXBwZW5pbmc6IG1hY2Jf
bWlpX2luaXQoKSBjYWxscyBtYWNiX21paV9wcm9iZSgpDQo+IGFuZCBzbyBieSB0aGUgdGltZSB3
ZSBjYWxsIHBoeV9jb25uZWN0X2RpcmVjdCgpLCB3ZSBoYXZlIG5vdCBjYWxsZWQNCj4gcmVnaXN0
ZXJfbmV0ZGV2aWNlKCkgeWV0LCBuZXRkZXZfcmVnaXN0ZXJfa29iamVjdCgpIGhhcyBub3QgYmVl
biBjYWxsZWQNCj4gZWl0aGVyLCBhbmQgc28gc3lzZnNfY3JlYXRlX2xpbmsoKSBmYWlscy4uLi4N
CkkganVzdCBmb3VuZCBzYW1lIHRoaW5nLg0KWWVzLCByZWdpc3Rlcl9uZXRkZXYoKSB3YXMgbm90
IGNhbGxlZCBhdCBwaHlfY29ubmVjdF9kaXJlY3QoKSB0aW1lLiANCg0KPiBMZXQgbWUgdGhpbmsg
YWJvdXQgYSB3YXkgdG8gc29sdmUgdGhhdCwgZXZlbiB0aG91Z2ggSSBhbSBsZWFuaW5nIHRvd2Fy
ZHMNCj4gaWdub3JpbmcgdGhlIGVycm9ycyBmcm9tIHN5c2ZzX2NyZWF0ZV9saW5rKCkgcmF0aGVy
IHRoYW4gZml4aW5nIGVhY2ggYW5kDQo+IGV2ZXJ5IEV0aGVybmV0IGRyaXZlciB0byBtYWtlIGl0
IHByb2JlIGl0cyBNSUkgYnVzICphZnRlciogY2FsbGluZw0KPiByZWdpc3Rlcl9uZXRkZXZpY2Uo
KS4uLi4NCkFncmVlLg0KIA0KPiA+DQo+ID4gV2hhdCBpcyBkcml2ZXIgeW91IGFyZSB0ZXN0aW5n
PyBJIGNhbiBjaGVjayB0aGUgZmlsZS4NCj4gDQo+IERyaXZlcnMgaW52b2x2ZWQgYXJlIHRoZSBm
b2xsb3dpbmc6DQo+IA0KPiBkcml2ZXJzL25ldC9ldGhlcm5ldC9icm9hZGNvbS9iY21zeXNwb3J0
LmMsDQo+IGRyaXZlcnMvbmV0L2RzYS9iY21fc2YyLmMNCj4gZHJpdmVycy9uZXQvZXRoZXJuZXQv
YnJvYWRjb20vZ2VuZXQvDQo+IGRyaXZlcnMvbmV0L3BoeS9iY203eHh4LmMNClRoYW5rcyBmb3Ig
bGlzdCBvZiBmaWxlcy4NCg0KLSBXb29qdW5nDQo=
