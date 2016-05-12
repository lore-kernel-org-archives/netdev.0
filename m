From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [Xen-devel] [PATCH net-next v2 0/4] xen-netback: support for
	control ring
Date: Thu, 12 May 2016 15:56:23 +0000
Message-ID: <99660e360c764dee86b40056947429d4@AMSPEX02CL03.citrite.net>
References: <1462979790-2824-1-git-send-email-paul.durrant@citrix.com>
 <20160512.115219.759608823316429913.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([185.25.65.24]:63725 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932120AbcELP41 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2016 11:56:27 -0400
In-Reply-To: <20160512.115219.759608823316429913.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBYZW4tZGV2ZWwgW21haWx0bzp4
ZW4tZGV2ZWwtYm91bmNlc0BsaXN0cy54ZW4ub3JnXSBPbiBCZWhhbGYgT2YNCj4gRGF2aWQgTWls
bGVyDQo+IFNlbnQ6IDEyIE1heSAyMDE2IDE2OjUyDQo+IFRvOiBQYXVsIER1cnJhbnQNCj4gQ2M6
IHhlbi1kZXZlbEBsaXN0cy54ZW5wcm9qZWN0Lm9yZzsgbmV0ZGV2QHZnZXIua2VybmVsLm9yZw0K
PiBTdWJqZWN0OiBSZTogW1hlbi1kZXZlbF0gW1BBVENIIG5ldC1uZXh0IHYyIDAvNF0geGVuLW5l
dGJhY2s6IHN1cHBvcnQgZm9yDQo+IGNvbnRyb2wgcmluZw0KPiANCj4gRnJvbTogUGF1bCBEdXJy
YW50IDxwYXVsLmR1cnJhbnRAY2l0cml4LmNvbT4NCj4gRGF0ZTogV2VkLCAxMSBNYXkgMjAxNiAx
NjoxNjoyNiArMDEwMA0KPiANCj4gPiBNeSByZWNlbnQgcGF0Y2ggdG8gaW1wb3J0IGFuIHVwLXRv
LWRhdGUgaW5jbHVkZS94ZW4vaW50ZXJmYWNlL2lvL25ldGlmLmgNCj4gPiBmcm9tIHRoZSBYZW4g
UHJvamVjdCBicm91Z2h0IGluIHRoZSBuZWNlc3NhcnkgZGVmaW5pdGlvbnMgdG8gc3VwcG9ydCB0
aGUNCj4gPiBuZXcgY29udHJvbCBzaGFyZWQgcmluZyBhbmQgcHJvdG9jb2wuIFRoaXMgcGF0Y2gg
c2VyaWVzIHVwZGF0ZXMgeGVuLQ0KPiBuZXRiYWNrDQo+ID4gdG8gc3VwcG9ydCB0aGUgbmV3IHJp
bmcuDQo+IA0KPiBJIGxvc3QgbXkgY29weSBvZiB5b3VyIFYzIGNvdmVyIGxldHRlciwgc28gSSdt
IHJlcGx5aW5nIHRvIHRoaXMgb25lLCBidXQNCj4gYmUgc3VyZSBJIHRlc3RlZCBWMyA6LSkNCj4g
DQo+IFRoaXMgZG9lc24ndCBidWlsZCwgcGxlYXNlIGZpeDoNCj4gDQo+IEVSUk9SOiAiaW5pdF9y
Y3VfaGVhZCIgW2RyaXZlcnMvbmV0L3hlbi1uZXRiYWNrL3hlbi1uZXRiYWNrLmtvXQ0KPiB1bmRl
ZmluZWQhDQo+IEVSUk9SOiAiZGVzdHJveV9yY3VfaGVhZCIgW2RyaXZlcnMvbmV0L3hlbi1uZXRi
YWNrL3hlbi1uZXRiYWNrLmtvXQ0KPiB1bmRlZmluZWQhDQo+IA0KDQpPSy4NCg0KICBQYXVsDQoN
Cj4gX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18NCj4gWGVu
LWRldmVsIG1haWxpbmcgbGlzdA0KPiBYZW4tZGV2ZWxAbGlzdHMueGVuLm9yZw0KPiBodHRwOi8v
bGlzdHMueGVuLm9yZy94ZW4tZGV2ZWwNCg==
