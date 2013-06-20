From: "Nelson, Shannon" <shannon.nelson@intel.com>
Subject: RE: [net-next 3/8] i40e: driver ethtool core
Date: Thu, 20 Jun 2013 20:04:15 +0000
Message-ID: <FC41C24E35F18A40888AACA1A36F3E4168533F3F@FMSMSX102.amr.corp.intel.com>
References: <1371182122-26629-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1371182122-26629-4-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1371666430.1956.102.camel@bwh-desktop.uk.level5networks.com>
	 <FC41C24E35F18A40888AACA1A36F3E4168533EAD@FMSMSX102.amr.corp.intel.com>
 <1371758352.1946.16.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:51814 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422782Ab3FTUEv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jun 2013 16:04:51 -0400
In-Reply-To: <1371758352.1946.16.camel@bwh-desktop.uk.level5networks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBGcm9tOiBCZW4gSHV0Y2hpbmdzIFttYWlsdG86Ymh1dGNoaW5nc0Bzb2xhcmZsYXJlLmNvbV0N
Cj4gU2VudDogVGh1cnNkYXksIEp1bmUgMjAsIDIwMTMgMTI6NTkgUE0NCj4gDQo+IE9uIFRodSwg
MjAxMy0wNi0yMCBhdCAxOTo0NyArMDAwMCwgTmVsc29uLCBTaGFubm9uIHdyb3RlOg0KPiA+ID4g
RnJvbTogQmVuIEh1dGNoaW5ncyBbbWFpbHRvOmJodXRjaGluZ3NAc29sYXJmbGFyZS5jb21dDQo+
ID4gPiBTZW50OiBXZWRuZXNkYXksIEp1bmUgMTksIDIwMTMgMTE6MjcgQU0NCj4gPiA+DQo+ID4g
PiBPbiBUaHUsIDIwMTMtMDYtMTMgYXQgMjA6NTUgLTA3MDAsIEplZmYgS2lyc2hlciB3cm90ZToN
Cj4gPiA+ID4gRnJvbTogSmVzc2UgQnJhbmRlYnVyZyA8amVzc2UuYnJhbmRlYnVyZ0BpbnRlbC5j
b20+DQo+IFsuLi5dDQo+ID4gPiA+ICtzdGF0aWMgc3RydWN0IGk0MGVfc3RhdHMgaTQwZV9nc3Ry
aW5nc19zdGF0c1tdID0gew0KPiA+ID4gPiArCUk0MEVfUEZfU1RBVCgicnhfYnl0ZXMiLCBzdGF0
cy5ldGgucnhfYnl0ZXMpLA0KPiA+ID4gPiArCUk0MEVfUEZfU1RBVCgidHhfYnl0ZXMiLCBzdGF0
cy5ldGgudHhfYnl0ZXMpLA0KPiA+ID4gPiArCUk0MEVfUEZfU1RBVCgicnhfZXJyb3JzIiwgc3Rh
dHMuZXRoLnJ4X2Vycm9ycyksDQo+ID4gPiA+ICsJSTQwRV9QRl9TVEFUKCJ0eF9lcnJvcnMiLCBz
dGF0cy5ldGgudHhfZXJyb3JzKSwNCj4gPiA+DQo+ID4gPiBEdXBsaWNhdGVzLg0KPiA+DQo+ID4g
V2VsbCwgbm90IHJlYWxseSBhcmUgdGhleSBkdXBsaWNhdGVzIC0gdGhlIE5FVERFVl9TVEFUIG51
bWJlcnMgYXJlDQo+ID4gc3BlY2lmaWNhbGx5IGZvciBlYWNoIG5ldGRldiB0aGF0IGlzIGF0dGFj
aGVkIHRvIHRoaXMgZGV2aWNlLiAgQmVjYXVzZQ0KPiA+IHRoZSBYTDcxMCBzdXBwb3J0cyBWTURx
LCBTUi1JT1YsIGFuZCBzb21lIG90aGVyIGRldmljZSBtdWx0aXBsZXhpbmcNCj4gPiBzY2hlbWVz
LCBlYWNoIG5ldGRldidzIE5FVERFVl9TVEFUIHN0cnVjdCBpcyB0aGUgc3Vic2V0IG9mIHRoZSB0
cmFmZmljDQo+ID4gZ29pbmcgdGhyb3VnaCBpdHMgcG9ydGlvbiBvZiB0aGUgZGV2aWNlLg0KPiA+
DQo+ID4gVGhlIFBGX1NUQVQgc3RydWN0IGhvbGRzIHRoZSBzdGF0cyBmb3Igd2hhdCBhY3R1YWxs
eSBnb2VzIHRocm91Z2ggdGhlDQo+ID4gcGh5c2ljYWwgcG9ydC4gIFRoaXMgaXMgbm90IG5lY2Vz
c2FyaWx5IGEgc3VtbWF0aW9uIG9mIHRoZSB2YXJpb3VzDQo+ID4gTkVUREVWX1NUQVQgc3RydWN0
cywgYmVjYXVzZSBzb21lIGNvbm5lY3Rpb25zIG1heSBiZSB0YWxraW5nIHRvIGVhY2gNCj4gPiBv
dGhlciBhbmQgbm90IG91dCB0aGUgcGh5c2ljYWwgcG9ydC4NCj4gPg0KPiA+IFdoZW4gZXRodG9v
bCAtUyBpcyBjYWxsZWQgb24gdGhlIFBGJ3MgbmV0ZGV2LCB3ZSBzZWUgYm90aCB0aGUgbmV0ZGV2
DQo+ID4gYW5kIHRoZSBwb3J0cyBzdGF0cyBwcmludGVkLiAgV2hlbiBjYWxsZWQgb24gbm9uLVBG
IGNvbm5lY3Rpb24gd2Ugb25seQ0KPiA+IHNlZSB0aGUgbmV0ZGV2IHN0YXRzLCBub25lIG9mIHRo
ZSBwb3J0IHN0YXRzLg0KPiANCj4gR29vZCBwb2ludC4gIEFuZCB0aGlzIGlzIHNvbWV0aGluZyBJ
J3ZlIGJlZW4gbWVhbmluZyB0byBicmluZyB1cCBmb3INCj4gZGlzY3Vzc2lvbiBvbiBuZXRkZXYg
bXlzZWxmIC0gd2Ugc2hvdWxkIGhhdmUgc29tZSBuYW1pbmcgY29udmVudGlvbiB0bw0KPiBkaXN0
aW5ndWlzaCBwZXItcG9ydCBhbmQgcGVyLWZ1bmN0aW9uL3Blci1uZXRkZXYgc3RhdGlzdGljcy4N
Cg0KSWYgeW91J3ZlIGdvdCBzb21lIGlkZWFzIG9uIGEgY29udmVudGlvbiB0byB1c2UsIHdlJ2Qg
YmUgaGFwcHkgdG8gc2V0IHRoZSBwcmVjZWRlbnQuDQoNCnNsbg0KDQo=
