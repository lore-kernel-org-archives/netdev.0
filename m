From: Nogah Frankel <nogahf@mellanox.com>
Subject: RE: [PATCH iproute2 v2 1/3] ifstat: Add extended statistics to ifstat
Date: Sun, 18 Dec 2016 14:22:20 +0000
Message-ID: <DB5PR05MB1895C7228A72DE423E1346B0AC9E0@DB5PR05MB1895.eurprd05.prod.outlook.com>
References: <1481806845-63384-1-git-send-email-nogahf@mellanox.com>
 <1481806845-63384-2-git-send-email-nogahf@mellanox.com>
 <20161215093327.2daf60c6@xeon-e3>
 <DB5PR05MB1895991888E270CE790F1C16AC9C0@DB5PR05MB1895.eurprd05.prod.outlook.com>
 <CAKoUArk5oSseSGDdZ_TEGLbG-jabdArUmz3pZ7kdoZKiNpqPrQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
        Jiri Pirko <jiri@mellanox.com>, Elad Raz <eladr@mellanox.com>,
        Yotam Gigi <yotamg@mellanox.com>,
        Ido Schimmel <idosch@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: Rami Rosen <roszenrami@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0089.outbound.protection.outlook.com ([104.47.2.89]:43104
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750770AbcLRXtR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 18 Dec 2016 18:49:17 -0500
In-Reply-To: <CAKoUArk5oSseSGDdZ_TEGLbG-jabdArUmz3pZ7kdoZKiNpqPrQ@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBSYW1pIFJvc2VuIFttYWlsdG86
cm9zemVucmFtaUBnbWFpbC5jb21dDQo+IFNlbnQ6IEZyaWRheSwgRGVjZW1iZXIgMTYsIDIwMTYg
NToyMSBQTQ0KPiBUbzogTm9nYWggRnJhbmtlbCA8bm9nYWhmQG1lbGxhbm94LmNvbT4NCj4gQ2M6
IFN0ZXBoZW4gSGVtbWluZ2VyIDxzdGVwaGVuQG5ldHdvcmtwbHVtYmVyLm9yZz47IG5ldGRldkB2
Z2VyLmtlcm5lbC5vcmc7DQo+IHJvb3BhQGN1bXVsdXNuZXR3b3Jrcy5jb207IEppcmkgUGlya28g
PGppcmlAbWVsbGFub3guY29tPjsgRWxhZCBSYXoNCj4gPGVsYWRyQG1lbGxhbm94LmNvbT47IFlv
dGFtIEdpZ2kgPHlvdGFtZ0BtZWxsYW5veC5jb20+OyBJZG8gU2NoaW1tZWwNCj4gPGlkb3NjaEBt
ZWxsYW5veC5jb20+OyBPciBHZXJsaXR6IDxvZ2VybGl0ekBtZWxsYW5veC5jb20+DQo+IFN1Ympl
Y3Q6IFJlOiBbUEFUQ0ggaXByb3V0ZTIgdjIgMS8zXSBpZnN0YXQ6IEFkZCBleHRlbmRlZCBzdGF0
aXN0aWNzIHRvIGlmc3RhdA0KPiANCj4gSGksDQo+IA0KPiA+VGhhbmtzLCBJJ2xsIGZpeCBpdC4N
Cj4gQW5vdGhlciBtaW5vciBuaXQsIG9uIHRoaXMgb2NjYXNpb246DQo+IA0KPiBib29sIGlzX2V4
dGFuZGVkIHNob3VsZCBiZTogYm9vbCBpc19leHRlbmRlZA0KPiANCj4gUmVnYXJkcywNCj4gUmFt
aSBSb3Nlbg0KDQpUaGFuayB5b3UsIEkgd2lsbCBmaXggaXQuDQoNCk5vZ2FoDQo=
