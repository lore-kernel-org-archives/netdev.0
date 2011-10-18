From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: RE: [PATCH 3/7] mlx4_en: Incoming traffic alignment optimizations
Date: Tue, 18 Oct 2011 07:43:08 +0000
Message-ID: <953B660C027164448AE903364AC447D2235EEB7E@MTLDAG01.mtl.com>
References: <4E9C8D53.5040006@mellanox.co.il>
 <1318902799.2571.26.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog112.obsmtp.com ([207.126.144.133]:57559 "HELO
	eu1sys200aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757300Ab1JRHsQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 03:48:16 -0400
In-Reply-To: <1318902799.2571.26.camel@edumazet-laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiANCj4gPiBAQCAtOTEsNyArOTEsNyBAQA0KPiA+ICAvKiBSZWNlaXZlIGZyYWdtZW50IHNpemVz
OyB3ZSB1c2UgYXQgbW9zdCA0IGZyYWdtZW50cyAoZm9yIDk2MDAgYnl0ZSBNVFUNCj4gPiAgICog
YW5kIDRLIGFsbG9jYXRpb25zKSAqLw0KPiA+ICBlbnVtIHsNCj4gPiAtCUZSQUdfU1owID0gNTEy
IC0gTkVUX0lQX0FMSUdOLA0KPiA+ICsJRlJBR19TWjAgPSAyMDQ4LA0KPiA+ICAJRlJBR19TWjEg
PSAxMDI0LA0KPiA+ICAJRlJBR19TWjIgPSA0MDk2LA0KPiA+ICAJRlJBR19TWjMgPSBNTFg0X0VO
X0FMTE9DX1NJWkUNCj4gDQo+IElzIHRoZSA1MTIgLT4gMjA0OCBjaGFuZ2UgcmVhbGx5IHdhbnRl
ZCA/IEl0cyBub3QgbWVudGlvbmVkIGluIGNoYW5nZWxvZyBhbmQgaXMgY29uZnVzaW5nLg0KPiAN
Cj4gVGhpcyBtZWFucyBtbHg0IGxvc3QgdGhlIGFiaWxpdHkgdG8gdXNlIGEgc21hbGwgZnJhZyAo
NTEyIGJ5dGVzKSB0byBzdG9yZSBzbWFsbCBmcmFtZXMuDQo+IA0KVGhlIGNoYW5nZSBpcyB3YW50
ZWQgYXMgYW4gb3B0aW1pemF0aW9uIGZvciBvdXIgSFcuDQpXZSBkbyBnZXQgYmV0dGVyIG51bWJl
cnMgd2l0aCB0aGlzIGNoYW5nZSwgZXZlbiB3aXRoIHNtYWxsIHBhY2tldHMuDQpZb3UgYXJlIGNv
cnJlY3QsIEkgc2hvdWxkIGhhdmUgbWVudGlvbmVkIGl0IGluIHRoZSBjaGFuZ2Vsb2cuDQoNClll
dmdlbnkNCg0KIA0KDQo=
