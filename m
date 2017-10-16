From: Madalin-cristian Bucur <madalin.bucur@nxp.com>
Subject: RE: [PATCH v2 5/5] fsl/fman: add dpaa in module names
Date: Mon, 16 Oct 2017 03:15:58 +0000
Message-ID: <DB3PR0402MB3849CE2038F3035F2CECBE7EEC4F0@DB3PR0402MB3849.eurprd04.prod.outlook.com>
References: <1507906212-10076-1-git-send-email-madalin.bucur@nxp.com>
 <1507906212-10076-6-git-send-email-madalin.bucur@nxp.com>
 <ba387138-03e5-52df-dc5b-98c6c9d57be8@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "andrew@lunn.ch" <andrew@lunn.ch>,
        "vivien.didelot@savoirfairelinux.com"
        <vivien.didelot@savoirfairelinux.com>,
        "junote@outlook.com" <junote@outlook.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr40083.outbound.protection.outlook.com ([40.107.4.83]:43555
        "EHLO EUR03-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751461AbdJPDQB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 15 Oct 2017 23:16:01 -0400
In-Reply-To: <ba387138-03e5-52df-dc5b-98c6c9d57be8@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBGbG9yaWFuIEZhaW5lbGxpIFtt
YWlsdG86Zi5mYWluZWxsaUBnbWFpbC5jb21dDQo+IFNlbnQ6IEZyaWRheSwgT2N0b2JlciAxMywg
MjAxNyA4OjM5IFBNDQo+IFRvOiBNYWRhbGluLWNyaXN0aWFuIEJ1Y3VyIDxtYWRhbGluLmJ1Y3Vy
QG54cC5jb20+Ow0KPiBuZXRkZXZAdmdlci5rZXJuZWwub3JnOyBkYXZlbUBkYXZlbWxvZnQubmV0
DQo+IENjOiBhbmRyZXdAbHVubi5jaDsgdml2aWVuLmRpZGVsb3RAc2F2b2lyZmFpcmVsaW51eC5j
b207DQo+IGp1bm90ZUBvdXRsb29rLmNvbTsgbGludXgta2VybmVsQHZnZXIua2VybmVsLm9yZw0K
PiBTdWJqZWN0OiBSZTogW1BBVENIIHYyIDUvNV0gZnNsL2ZtYW46IGFkZCBkcGFhIGluIG1vZHVs
ZSBuYW1lcw0KPiANCj4gT24gMTAvMTMvMjAxNyAwNzo1MCBBTSwgTWFkYWxpbiBCdWN1ciB3cm90
ZToNCj4gPiBTaWduZWQtb2ZmLWJ5OiBNYWRhbGluIEJ1Y3VyIDxtYWRhbGluLmJ1Y3VyQG54cC5j
b20+DQo+IA0KPiBZb3Ugc2hvdWxkIHByb3ZpZGUgYSBsaW5lIG9yIHR3byB0byBleHBsYWluIHdo
eSBhcmUgeW91IG1ha2luZyB0aGlzDQo+IGNoYW5nZSwgaXQgaXMgdG8gcmVzb2x2ZSBtb2R1bGFy
IGJ1aWxkIGNvbmZpZ3VyYXRpb25zPw0KDQpUaGlzIGNoYW5nZSBqdXN0IHJlbmFtZXMgdGhlIEZN
YW4gZHJpdmVyIG1vZHVsZXMsIHVzaW5nIGEgY29tbW9uIHByZWZpeCBmb3INCnRoZSBEUEFBIEZN
YW4gYW5kIERQQUEgRXRoZXJuZXQgZHJpdmVycy4gQmVzaWRlcyBtYWtpbmcgdGhlIG5hbWVzIG1v
cmUgYWxpZ25lZCwNCnRoaXMgYWxsb3dzIHdyaXRpbmcgdWRldiBydWxlcyB0aGF0IG1hdGNoIG9u
IGVpdGhlciBkcml2ZXIgbmFtZSwgaWYgbmVlZGVkLA0KdXNpbmcgdGhlIGZzbF9kcGFhXyogcHJl
Zml4LiBUaGUgY2hhbmdlIG9mIG5ldGRldiBkZXYgcmVxdWlyZWQgZm9yIHRoZSBEU0ENCnByb2Jp
bmcgbWFrZXMgdGhlIHByZXZpb3VzIHJ1bGVzIHdyaXR0ZW4gdXNpbmcgdGhpcyBwcmVmaXggZmFp
bCwgdGhpcyBjaGFuZ2UNCm1ha2VzIHRoZW0gd29yayBhZ2Fpbi4NCg0KPiA+IC0tLQ0KPiA+ICBk
cml2ZXJzL25ldC9ldGhlcm5ldC9mcmVlc2NhbGUvZm1hbi9NYWtlZmlsZSB8IDEyICsrKysrKy0t
LS0tLQ0KPiA+ICAxIGZpbGUgY2hhbmdlZCwgNiBpbnNlcnRpb25zKCspLCA2IGRlbGV0aW9ucygt
KQ0KPiA+DQo+ID4gZGlmZiAtLWdpdCBhL2RyaXZlcnMvbmV0L2V0aGVybmV0L2ZyZWVzY2FsZS9m
bWFuL01ha2VmaWxlDQo+IGIvZHJpdmVycy9uZXQvZXRoZXJuZXQvZnJlZXNjYWxlL2ZtYW4vTWFr
ZWZpbGUNCj4gPiBpbmRleCAyYzM4MTE5Li40YWU1MjRhIDEwMDY0NA0KPiA+IC0tLSBhL2RyaXZl
cnMvbmV0L2V0aGVybmV0L2ZyZWVzY2FsZS9mbWFuL01ha2VmaWxlDQo+ID4gKysrIGIvZHJpdmVy
cy9uZXQvZXRoZXJuZXQvZnJlZXNjYWxlL2ZtYW4vTWFrZWZpbGUNCj4gPiBAQCAtMSw5ICsxLDkg
QEANCj4gPiAgc3ViZGlyLWNjZmxhZ3MteSArPSAgLUkkKHNyY3RyZWUpL2RyaXZlcnMvbmV0L2V0
aGVybmV0L2ZyZWVzY2FsZS9mbWFuDQo+ID4NCj4gPiAtb2JqLSQoQ09ORklHX0ZTTF9GTUFOKSAr
PSBmc2xfZm1hbi5vDQo+ID4gLW9iai0kKENPTkZJR19GU0xfRk1BTikgKz0gZnNsX2ZtYW5fcG9y
dC5vDQo+ID4gLW9iai0kKENPTkZJR19GU0xfRk1BTikgKz0gZnNsX21hYy5vDQo+ID4gK29iai0k
KENPTkZJR19GU0xfRk1BTikgKz0gZnNsX2RwYWFfZm1hbi5vDQo+ID4gK29iai0kKENPTkZJR19G
U0xfRk1BTikgKz0gZnNsX2RwYWFfZm1hbl9wb3J0Lm8NCj4gPiArb2JqLSQoQ09ORklHX0ZTTF9G
TUFOKSArPSBmc2xfZHBhYV9tYWMubw0KPiA+DQo+ID4gLWZzbF9mbWFuLW9ianMJOj0gZm1hbl9t
dXJhbS5vIGZtYW4ubyBmbWFuX3NwLm8gZm1hbl9rZXlnZW4ubw0KPiA+IC1mc2xfZm1hbl9wb3J0
LW9ianMgOj0gZm1hbl9wb3J0Lm8NCj4gPiAtZnNsX21hYy1vYmpzOj0gbWFjLm8gZm1hbl9kdHNl
Yy5vIGZtYW5fbWVtYWMubyBmbWFuX3RnZWMubw0KPiA+ICtmc2xfZHBhYV9mbWFuLW9ianMJOj0g
Zm1hbl9tdXJhbS5vIGZtYW4ubyBmbWFuX3NwLm8gZm1hbl9rZXlnZW4ubw0KPiA+ICtmc2xfZHBh
YV9mbWFuX3BvcnQtb2JqcyA6PSBmbWFuX3BvcnQubw0KPiA+ICtmc2xfZHBhYV9tYWMtb2Jqczo9
IG1hYy5vIGZtYW5fZHRzZWMubyBmbWFuX21lbWFjLm8gZm1hbl90Z2VjLm8NCj4gPg0KPiANCj4g
DQo+IC0tDQo+IEZsb3JpYW4NCg==
