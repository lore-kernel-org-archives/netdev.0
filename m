From: Nogah Frankel <nogahf@mellanox.com>
Subject: RE: [PATCH iproute2 v2 1/3] ifstat: Add extended statistics to ifstat
Date: Fri, 16 Dec 2016 12:11:24 +0000
Message-ID: <DB5PR05MB1895991888E270CE790F1C16AC9C0@DB5PR05MB1895.eurprd05.prod.outlook.com>
References: <1481806845-63384-1-git-send-email-nogahf@mellanox.com>
        <1481806845-63384-2-git-send-email-nogahf@mellanox.com>
 <20161215093327.2daf60c6@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
        Jiri Pirko <jiri@mellanox.com>, Elad Raz <eladr@mellanox.com>,
        Yotam Gigi <yotamg@mellanox.com>,
        Ido Schimmel <idosch@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0057.outbound.protection.outlook.com ([104.47.2.57]:24456
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1757726AbcLPOpe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 16 Dec 2016 09:45:34 -0500
In-Reply-To: <20161215093327.2daf60c6@xeon-e3>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQo+IC0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+IEZyb206IFN0ZXBoZW4gSGVtbWluZ2Vy
IFttYWlsdG86c3RlcGhlbkBuZXR3b3JrcGx1bWJlci5vcmddDQo+IFNlbnQ6IFRodXJzZGF5LCBE
ZWNlbWJlciAxNSwgMjAxNiA3OjMzIFBNDQo+IFRvOiBOb2dhaCBGcmFua2VsIDxub2dhaGZAbWVs
bGFub3guY29tPg0KPiBDYzogbmV0ZGV2QHZnZXIua2VybmVsLm9yZzsgcm9vcGFAY3VtdWx1c25l
dHdvcmtzLmNvbTsgSmlyaSBQaXJrbw0KPiA8amlyaUBtZWxsYW5veC5jb20+OyBFbGFkIFJheiA8
ZWxhZHJAbWVsbGFub3guY29tPjsgWW90YW0gR2lnaQ0KPiA8eW90YW1nQG1lbGxhbm94LmNvbT47
IElkbyBTY2hpbW1lbCA8aWRvc2NoQG1lbGxhbm94LmNvbT47IE9yIEdlcmxpdHoNCj4gPG9nZXJs
aXR6QG1lbGxhbm94LmNvbT4NCj4gU3ViamVjdDogUmU6IFtQQVRDSCBpcHJvdXRlMiB2MiAxLzNd
IGlmc3RhdDogQWRkIGV4dGVuZGVkIHN0YXRpc3RpY3MgdG8gaWZzdGF0DQo+IA0KPiBPbiBUaHUs
IDE1IERlYyAyMDE2IDE1OjAwOjQzICswMjAwDQo+IE5vZ2FoIEZyYW5rZWwgPG5vZ2FoZkBtZWxs
YW5veC5jb20+IHdyb3RlOg0KPiANCj4gPiBFeHRlbmRlZCBzdGF0cyBhcmUgcGFydCBvZiB0aGUg
UlRNX0dFVFNUQVRTIG1ldGhvZC4gVGhpcyBwYXRjaCBhZGRzIHRoZW0NCj4gPiB0byBpZnN0YXQu
DQo+ID4gV2hpbGUgZXh0ZW5kZWQgc3RhdHMgY2FuIGNvbWUgaW4gbWFueSBmb3Jtcywgd2Ugc3Vw
cG9ydCBvbmx5IHRoZQ0KPiA+IHJ0bmxfbGlua19zdGF0czY0IHN0cnVjdCBmb3IgdGhlbSAod2hp
Y2ggaXMgdGhlIDY0IGJpdHMgdmVyc2lvbiBvZiBzdHJ1Y3QNCj4gPiBydG5sX2xpbmtfc3RhdHMp
Lg0KPiA+IFdlIHN1cHBvcnQgc3RhdHMgaW4gdGhlIG1haW4gbmVzdGluZyBsZXZlbCwgb3Igb25l
IGxvd2VyLg0KPiA+IFRoZSBleHRlbnNpb24gY2FuIGJlIGNhbGxlZCBieSBpdHMgbmFtZSBvciBh
bnkgc2hvcnRlbiBvZiBpdC4gSWYgdGhlcmUgaXMNCj4gPiBtb3JlIHRoYW4gb25lIG1hdGNoZWQs
IHRoZSBmaXJzdCBvbmUgd2lsbCBiZSBwaWNrZWQuDQo+ID4NCj4gPiBUbyBnZXQgdGhlIGV4dGVu
ZGVkIHN0YXRzIHRoZSBmbGFnIC14IDxzdGF0cyB0eXBlPiBpcyB1c2VkLg0KPiA+DQo+ID4gU2ln
bmVkLW9mZi1ieTogTm9nYWggRnJhbmtlbCA8bm9nYWhmQG1lbGxhbm94LmNvbT4NCj4gPiBSZXZp
ZXdlZC1ieTogSmlyaSBQaXJrbyA8amlyaUBtZWxsYW5veC5jb20+DQo+ID4gLS0tDQo+ID4gIG1p
c2MvaWZzdGF0LmMgfCAxNjENCj4gKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysr
KysrKysrKysrKysrKysrKy0tLS0tLQ0KPiA+ICAxIGZpbGUgY2hhbmdlZCwgMTQ2IGluc2VydGlv
bnMoKyksIDE1IGRlbGV0aW9ucygtKQ0KPiA+DQo+ID4gZGlmZiAtLWdpdCBhL21pc2MvaWZzdGF0
LmMgYi9taXNjL2lmc3RhdC5jDQo+ID4gaW5kZXggOTJkNjdiMC4uZDE3YWUyMSAxMDA2NDQNCj4g
PiAtLS0gYS9taXNjL2lmc3RhdC5jDQo+ID4gKysrIGIvbWlzYy9pZnN0YXQuYw0KPiA+IEBAIC0z
NSw2ICszNSw3IEBADQo+ID4NCj4gPiAgI2luY2x1ZGUgPFNOQVBTSE9ULmg+DQo+ID4NCj4gPiAr
I2luY2x1ZGUgInV0aWxzLmgiDQo+ID4gIGludCBkdW1wX3plcm9zOw0KPiA+ICBpbnQgcmVzZXRf
aGlzdG9yeTsNCj4gPiAgaW50IGlnbm9yZV9oaXN0b3J5Ow0KPiANCj4gTWlub3Igbml0LCBwbGVh
c2UgY2xlYW51cCBpbmNsdWRlIG9yZGVyIGhlcmUgKG9yaWdpbmFsIGNvZGUgd2FzIHdyb25nKS4N
Cj4gDQo+IFN0YW5kYXJkIHByYWN0aWNlIGlzOg0KPiAgI2luY2x1ZGUgc3lzdGVtIGhlYWRlcnMg
KGxpa2Ugc3RkaW8uaCBldGMpDQo+ICAjaW5jbHVkZSAieHh4LmgiIGxvY2FsIGhlYWRlcnMuDQo+
IA0KPiBTaG91bGQgYmU6DQo+ICNpbmNsdWRlIDxnZXRvcHQuaD4NCj4gDQo+ICNpbmNsdWRlIDxs
aW51eC9pZi5oPg0KPiAjaW5jbHVkZSA8bGludXgvaWZfbGluay5oPg0KPiANCj4gI2luY2x1ZGUg
Impzb25fd3JpdGVyLmgiDQo+ICNpbmNsdWRlICJsaWJuZXRsaW5rLmgiDQo+ICNpbmNsdWRlICJ1
dGlscy5oIg0KPiAjaW5jbHVkZSAiU05BUFNIT1QuaCINCg0KVGhhbmtzLCBJJ2xsIGZpeCBpdC4N
Cg==
