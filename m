From: Andy Duan <fugang.duan@nxp.com>
Subject: RE: [PATCH v2] net: fec: Fixed panic problem with non-tso
Date: Wed, 18 Jan 2017 05:38:27 +0000
Message-ID: <AM4PR0401MB2260C7895A8D9F51F68E4279FF7F0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
References: <20170117.154512.612465430064515761.davem@davemloft.net>
         <20170118041140.15371-1-ashiduka@jp.fujitsu.com>
 <1484715738.13165.95.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        Yuusuke Ashiduka <ashiduka@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr40071.outbound.protection.outlook.com ([40.107.4.71]:30930
        "EHLO EUR03-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750703AbdARFjM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Jan 2017 00:39:12 -0500
In-Reply-To: <1484715738.13165.95.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0IDxlcmljLmR1bWF6ZXRAZ21haWwuY29tPiBTZW50OiBXZWRuZXNk
YXksIEphbnVhcnkgMTgsIDIwMTcgMTowMiBQTQ0KPlRvOiBZdXVzdWtlIEFzaGlkdWthIDxhc2hp
ZHVrYUBqcC5mdWppdHN1LmNvbT4NCj5DYzogQW5keSBEdWFuIDxmdWdhbmcuZHVhbkBueHAuY29t
PjsgbmV0ZGV2QHZnZXIua2VybmVsLm9yZw0KPlN1YmplY3Q6IFJlOiBbUEFUQ0ggdjJdIG5ldDog
ZmVjOiBGaXhlZCBwYW5pYyBwcm9ibGVtIHdpdGggbm9uLXRzbw0KPg0KPk9uIFdlZCwgMjAxNy0w
MS0xOCBhdCAxMzoxMSArMDkwMCwgWXV1c3VrZSBBc2hpZHVrYSB3cm90ZToNCj4+IElmIGhpZ2ht
ZW0gYW5kIDJHQiBvciBtb3JlIG9mIG1lbW9yeSBhcmUgdmFsaWQsICJ0aGlzX2ZyYWctPiBwYWdl
LnAiDQo+PiBpbmRpY2F0ZXMgdGhlIGhpZ2htZW0gYXJlYSwgc28gdGhlIHJlc3VsdCBvZiBwYWdl
X2FkZHJlc3MoKSBpcyBOVUxMDQo+PiBhbmQgcGFuaWMgb2NjdXJzLg0KPj4NCj4+IFRoaXMgY29t
bWl0IGZpeGVzIHRoaXMgYnkgdXNpbmcgdGhlIHNrYl9mcmFnX2RtYV9tYXAoKSBoZWxwZXIsIHdo
aWNoDQo+PiB0YWtlcyBjYXJlIG9mIG1hcHBpbmcgdGhlIHNrYiBmcmFnbWVudCBwcm9wZXJseS4g
QWRkaXRpb25hbGx5LCB0aGUNCj4+IHR5cGUgb2YgbWFwcGluZyBpcyBub3cgdHJhY2tlZCwgc28g
aXQgY2FuIGJlIHVubWFwcGVkIHVzaW5nDQo+PiBkbWFfdW5tYXBfcGFnZSBvciBkbWFfdW5tYXBf
c2luZ2xlIHdoZW4gYXBwcm9wcmlhdGUuDQo+DQo+DQo+SSB3b3VsZCBwcmVmZXIgd2UgZml4IHRo
ZSByb290IGNhdXNlLCBpbnN0ZWFkIG9mIHR3ZWFraW5nIGFsbCBsZWdhY3kgZHJpdmVycyBvdXQN
Cj50aGVyZSA6Lw0KPg0KPg0KSSBhZ3JlZSB3aXRoIHlvdS4NCg0KVGhlIGRyaXZlciBhbHdheXMg
ZG9lc24ndCBzdXBwb3J0IGhpZ2htZW0uIFRoZSBmcmFnbWVudCBzaG91bGRuJ3QgIGFsbG9jYXRl
IGZyb20gaGlnaG1lbSBleGNlcHQgdGhlIGNvbW1vbiBjb2RlIGJ1Zy4NCklmIHJlcXVlc3QgdGhl
IGRyaXZlciB0byBzdXBwb3J0IE5FVElGX0ZfSElHSERNQSBmZWF0dXJlLCB3ZSBhbHNvIGFkZCBo
aWdobWVtIHN1cHBvcnQgZm9yIHRzbyBkcml2ZXIuDQoNCkFuZHkNCg==
