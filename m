From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] enic: reset fetch index
Date: Sat, 28 Oct 2017 00:08:10 +0900 (KST)
Message-ID: <20171028.000810.246505527728273410.davem@davemloft.net>
References: <1509035405-20497-1-git-send-email-pkaustub@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, gvaradar@cisco.com, benve@cisco.com
To: pkaustub@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51130 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751290AbdJ0PIO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 11:08:14 -0400
In-Reply-To: <1509035405-20497-1-git-send-email-pkaustub@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogUGFydmkgS2F1c3R1YmhpIDxwa2F1c3R1YkBjaXNjby5jb20+DQpEYXRlOiBUaHUsIDI2
IE9jdCAyMDE3IDA5OjMwOjA0IC0wNzAwDQoNCj4gU2luY2Ugd2UgYXJlIGFsbG93aW5nIHJ4IHJp
bmcgc2l6ZSBtb2RpZmljYXRpb24sIHJlc2V0IGZldGNoIGluZGV4DQo+IGV2ZXJ5dGltZS4gT3Ro
ZXJ3aXNlIGl0IGNvdWxkIGhhdmUgYSBzdGFsZSB2YWx1ZSB0aGF0IGNhbiBsZWFkIHRvIGEgbnVs
bA0KPiBwb2ludGVyIGRlcmVmZXJlbmNlLg0KPiANCj4gU2lnbmVkLW9mZi1ieTogR292aW5kYXJh
anVsdSBWYXJhZGFyYWphbiA8Z3ZhcmFkYXJAY2lzY28uY29tPg0KPiBTaWduZWQtb2ZmLWJ5OiBQ
YXJ2aSBLYXVzdHViaGkgPHBrYXVzdHViQGNpc2NvLmNvbT4NCj4gLS0tDQo+ICBkcml2ZXJzL25l
dC9ldGhlcm5ldC9jaXNjby9lbmljL3ZuaWNfcnEuYyB8IDE0ICsrLS0tLS0tLS0tLS0tDQo+ICAx
IGZpbGUgY2hhbmdlZCwgMiBpbnNlcnRpb25zKCspLCAxMiBkZWxldGlvbnMoLSkNCj4gDQo+IGRp
ZmYgLS1naXQgYS9kcml2ZXJzL25ldC9ldGhlcm5ldC9jaXNjby9lbmljL3ZuaWNfcnEuYyBiL2Ry
aXZlcnMvbmV0L2V0aGVybmV0L2Npc2NvL2VuaWMvdm5pY19ycS5jDQo+IGluZGV4IDM2YmMyYzcu
LjkwNTM3ZDkgMTAwNjQ0DQo+IC0tLSBhL2RyaXZlcnMvbmV0L2V0aGVybmV0L2Npc2NvL2VuaWMv
dm5pY19ycS5jDQo+ICsrKyBiL2RyaXZlcnMvbmV0L2V0aGVybmV0L2Npc2NvL2VuaWMvdm5pY19y
cS5jDQo+IEBAIC0xNDEsMTggKzE0MSw4IEBAIHZvaWQgdm5pY19ycV9pbml0KHN0cnVjdCB2bmlj
X3JxICpycSwgdW5zaWduZWQgaW50IGNxX2luZGV4LA0KPiAgew0KPiAgCXUzMiBmZXRjaF9pbmRl
eCA9IDA7DQo+ICANCg0KUGxlYXNlIGxvb2sgYXQgdGhlIGJ1aWxkIHdoZW4geW91IG1ha2UgY2hh
bmdlczoNCg0KZHJpdmVycy9uZXQvZXRoZXJuZXQvY2lzY28vZW5pYy92bmljX3JxLmM6IEluIGZ1
bmN0aW9uIKF2bmljX3JxX2luaXSiOg0KZHJpdmVycy9uZXQvZXRoZXJuZXQvY2lzY28vZW5pYy92
bmljX3JxLmM6MTQyOjY6IHdhcm5pbmc6IHVudXNlZCB2YXJpYWJsZSChZmV0Y2hfaW5kZXiiIFst
V3VudXNlZC12YXJpYWJsZV0NCg0KVGhhbmsgeW91Lg0K
