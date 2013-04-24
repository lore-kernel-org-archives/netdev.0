From: "Li, Sibai" <sibai.li@intel.com>
Subject: RE: getting VF link info seems to be broken in 3.9-rc8
Date: Wed, 24 Apr 2013 16:44:13 +0000
Message-ID: <A3A921390EAE4044940E99EBF13D973224263635@FMSMSX104.amr.corp.intel.com>
References: <5177D946.9080704@mellanox.com>
 <20130424083825.00004f94@unknown> <20130424090133.00005ca6@unknown>
 <A3A921390EAE4044940E99EBF13D97322426359F@FMSMSX104.amr.corp.intel.com>
 <517809A4.3070001@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "Rose, Gregory V" <gregory.v.rose@intel.com>,
	David Miller <davem@davemloft.net>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	netdev <netdev@vger.kernel.org>, Rony Efraim <ronye@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:35448 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753407Ab3DXQoR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Apr 2013 12:44:17 -0400
In-Reply-To: <517809A4.3070001@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

VGhpcyBtZWFucyB0aGF0IHRoZSBWRiBkcml2ZXIgaXMgbG9hZGVkIGJlZm9yZSB0aGUgUEYgaXMg
bG9hZGVkLiBEaWQgeW91IHJlbG9hZCB0aGUgVkYgYWZ0ZXIgdGhlIFBGIGlzIGxvYWRlZD8NCj4g
LS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogT3IgR2VybGl0eiBbbWFpbHRvOm9n
ZXJsaXR6QG1lbGxhbm94LmNvbV0NCj4gU2VudDogV2VkbmVzZGF5LCBBcHJpbCAyNCwgMjAxMyA5
OjM1IEFNDQo+IFRvOiBMaSwgU2liYWkNCj4gQ2M6IFJvc2UsIEdyZWdvcnkgVjsgRGF2aWQgTWls
bGVyOyBEdXljaywgQWxleGFuZGVyIEg7IG5ldGRldjsgUm9ueSBFZnJhaW0NCj4gU3ViamVjdDog
UmU6IGdldHRpbmcgVkYgbGluayBpbmZvIHNlZW1zIHRvIGJlIGJyb2tlbiBpbiAzLjktcmM4DQo+
IA0KPiBPbiAyNC8wNC8yMDEzIDE5OjA4LCBMaSwgU2liYWkgd3JvdGU6DQo+ID4gVGhlIHZmcyBh
cmUgbGlzdGVkLCBldGgyMi9ldGgyMC4gSnVzdCB0aGUgbWFjIGFkZHJlc3MgaXMgZGlmZmVyZW50
LiBSZWxvYWQgdGhlDQo+IHZmIGRyaXZlciB0byBzZWUgaWYgaXQgY29ycmVjdHMgdGhlIHRoaW5n
Lg0KPiANCj4gU3VyZSwgdGhlIFZGIGFyZSBsaXN0ZWQgYXMgTklDcyBvZiB0aGVpciBvd24sIHdo
YXQncyBpc24ndCBsaXN0ZWQgaXMgdGhlIFZGIGluZm8gZnJvbQ0KPiB0aGUgUEYgTklDIGxpbmsg
aW5mbywgZS5nIGhlcmUncyB0aGUgY2FzZXdoZXJlIGl0cyB3b3JraW5nLCBvbiBrZXJuZWwgMy44
LjgtLSBteQ0KPiBwcm9ibGVtIGlzbid0IHRoZSBNQUMgbWlzYWxpZ25tZW50DQo+IA0KPiA4OiBl
dGgxMTogPE5PLUNBUlJJRVIsQlJPQURDQVNULE1VTFRJQ0FTVCxVUD4gbXR1IDE1MDAgcWRpc2Mg
bXEgc3RhdGUNCj4gRE9XTiBtb2RlIERFRkFVTFQgcWxlbiAxMDAwDQo+ICAgICAgbGluay9ldGhl
ciAwMDoxYjoyMTo1NToxZDowMCBicmQgZmY6ZmY6ZmY6ZmY6ZmY6ZmYNCj4gICAgICB2ZiAwIE1B
QyAwMDoxMTowMDoxMTowMDoxMSwgc3Bvb2YgY2hlY2tpbmcgb24NCj4gOTogZXRoMTA6IDxCUk9B
RENBU1QsTVVMVElDQVNULFVQLExPV0VSX1VQPiBtdHUgMTUwMCBxZGlzYyBtcSBzdGF0ZQ0KPiBV
UCBtb2RlIERPUk1BTlQgcWxlbiAxMDAwDQo+ICAgICAgbGluay9ldGhlciAwMDoxYjoyMTo1NTox
ZDowMSBicmQgZmY6ZmY6ZmY6ZmY6ZmY6ZmYNCj4gICAgICB2ZiAwIE1BQyAwMDoxMDowMDoxMDow
MDoxMCwgc3Bvb2YgY2hlY2tpbmcgb24NCg==
