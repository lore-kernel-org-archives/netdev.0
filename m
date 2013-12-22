From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sctp: fix missing include file
Date: Sat, 21 Dec 2013 22:01:27 -0500 (EST)
Message-ID: <20131221.220127.245659333298463184.davem@davemloft.net>
References: <20131221.000055.1377147691178558975.davem@davemloft.net>
	<52B562FE.4000207@redhat.com>
	<A1B7221A-6C6E-4B3B-8A7A-8492D04049D2@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: dborkman@redhat.com, vyasevich@gmail.com, nhorman@tuxdriver.com,
	netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	shm@cumulusnetworks.com, hannes@stressinduktion.org,
	linux-sctp@vger.kernel.org
To: sfeldma@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48644 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751583Ab3LVDBd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Dec 2013 22:01:33 -0500
In-Reply-To: <A1B7221A-6C6E-4B3B-8A7A-8492D04049D2@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogU2NvdHQgRmVsZG1hbiA8c2ZlbGRtYUBjdW11bHVzbmV0d29ya3MuY29tPg0KRGF0ZTog
U2F0LCAyMSBEZWMgMjAxMyAwNzoxOTowMyAtMDgwMA0KDQo+IA0KPiBPbiBEZWMgMjEsIDIwMTMs
IGF0IDE6NDQgQU0sIERhbmllbCBCb3JrbWFubiA8ZGJvcmttYW5AcmVkaGF0LmNvbT4gd3JvdGU6
DQo+IA0KPj4gT24gMTIvMjEvMjAxMyAwNjowMCBBTSwgRGF2aWQgTWlsbGVyIHdyb3RlOg0KPj4+
IEZyb206IFNjb3R0IEZlbGRtYW4gPHNmZWxkbWFAY3VtdWx1c25ldHdvcmtzLmNvbT4NCj4+PiBE
YXRlOiBGcmksIDIwIERlYyAyMDEzIDE4OjUxOjEwIC0wODAwDQo+Pj4gDQo+Pj4+IENvbXBpbGUg
ZXJyb3IgcmVwb3J0ZWQgYnkgSmltIERhdmlzIG9uIG5ldGRldi4NCj4+Pj4gDQo+Pj4+IGlwNl9z
a19hY2NlcHRfcG10dSgpIG5lZWRzIG5ldC9pcDZfcm91dGUuaA0KPj4+PiANCj4+Pj4gU2lnbmVk
LW9mZi1ieTogU2NvdHQgRmVsZG1hbiA8c2ZlbGRtYUBjdW11bHVzbmV0d29ya3MuY29tPg0KPj4+
IA0KPj4+IEFwcGxpZWQsIHRoYW5rcy4NCj4+IA0KPj4gU29ycnkgZm9yIHRoZSBsYXRlIHJlcGx5
IGFzIEknbSBvbiB0cmF2ZWwgd2l0aCBsaW1pdGVkIGNvbm5lY3Rpdml0eS4NCj4+IA0KPj4gU2Nv
dHQsIHRoaXMgZml4IGlzIG5vdCBjb3JyZWN0LCBhbmQgcHJvYmFibHkgc2hvdWxkIGJlIHJldmVy
dGVkLiBUaGUNCj4+IGNvcnJlY3Qgb25lIHdhcyBhbHJlYWR5IGluIHBhdGNod29yayB1bmRlciBb
MV0uIEluIFNDVFAsIHdlIGhhdmUNCj4+IG5ldC9zY3RwL2lwdjYuYyBmb3IgYWxsIElQdjYgcmVs
YXRlZCBmdW5jdGlvbnMuIEFsc28gdGhlcmUsIHRoaXMNCj4+IGluY2x1ZGUgZmlsZSBpcyBhbHJl
YWR5IHByZXNlbnQuDQo+PiANCj4+IFRoYW5rcyAhDQo+PiANCj4+IFsxXSBodHRwOi8vcGF0Y2h3
b3JrLm96bGFicy5vcmcvcGF0Y2gvMzAzMzA4Lw0KPiANCj4gT29wcywgc29ycnksIHR3byBzaGlw
cyBwYXNzaW5nLCBldGMuICBJIHNob3VsZCBoYXZlIGxvb2tlZCB1bmRlciBwYXRjaHdvcmsgZmly
c3QuDQo+IA0KPiBEYXZpZCwgcGxlYXNlIHJldmVydCBteSBjaGFuZ2UgYWMwOTE3ZjIgcGVuZGlu
ZyBEYW5pZWyicyBmaXguDQoNCkRvbmUuDQo=
