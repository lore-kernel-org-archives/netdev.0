From: "Underwood, JohnX" <johnx.underwood@intel.com>
Subject: RE: [net-next 10/16] i40e: add check for null VSI
Date: Fri, 19 Feb 2016 19:51:39 +0000
Message-ID: <49FCCD093EDAFE45B73804AC3C1112E52E5CFF@ORSMSX116.amr.corp.intel.com>
References: <1455875651-21696-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1455875651-21696-11-git-send-email-jeffrey.t.kirsher@intel.com>
	 <49FCCD093EDAFE45B73804AC3C1112E52E5CC6@ORSMSX116.amr.corp.intel.com>
	 <20160219.144117.1906425963316380038.davem@davemloft.net>
 <1455911339.3016.7.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>
To: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:37762 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1424609AbcBSTvl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Feb 2016 14:51:41 -0500
In-Reply-To: <1455911339.3016.7.camel@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

U29ycnksIGZvbGtzLiAgSSB3YXMgY29uZnVzZWQuICBUaGUgcGF0Y2ggbG9va2VkIGZhbWlsaWFy
LCBidXQgSSB3YXNuJ3QgYWJsZSB0byBmaW5kIHRoZSBlbWFpbCB3aGVyZSBJIG9yaWdpbmFsbHkg
c2VudCBpdCBvdXQuDQoNCi0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQpGcm9tOiBLaXJzaGVy
LCBKZWZmcmV5IFQgDQpTZW50OiBGcmlkYXksIEZlYnJ1YXJ5IDE5LCAyMDE2IDExOjQ5IEFNDQpU
bzogRGF2aWQgTWlsbGVyOyBVbmRlcndvb2QsIEpvaG5YDQpDYzogbmV0ZGV2QHZnZXIua2VybmVs
Lm9yZzsgbmhvcm1hbkByZWRoYXQuY29tOyBzYXNzbWFubkByZWRoYXQuY29tOyBqb2dyZWVuZUBy
ZWRoYXQuY29tDQpTdWJqZWN0OiBSZTogW25ldC1uZXh0IDEwLzE2XSBpNDBlOiBhZGQgY2hlY2sg
Zm9yIG51bGwgVlNJDQoNCk9uIEZyaSwgMjAxNi0wMi0xOSBhdCAxNDo0MSAtMDUwMCwgRGF2aWQg
TWlsbGVyIHdyb3RlOg0KPiBGcm9tOiAiVW5kZXJ3b29kLCBKb2huWCIgPGpvaG54LnVuZGVyd29v
ZEBpbnRlbC5jb20+DQo+IERhdGU6IEZyaSwgMTkgRmViIDIwMTYgMTk6MTU6NTMgKzAwMDANCj4g
DQo+ID4gQUNLDQo+IA0KPiBZb3Ugc2hvdWxkIG5ldmVyIHRvcC1wb3N0IG9uIHRoaXMgbWFpbGlu
ZyBsaXN0Lg0KPiANCj4gQnV0IGluIHRoaXMgc3BlY2lmaWMgY2FzZSBpdCBpcyBldmVuIG1vcmUg
aW1wb3J0YW50Lg0KPiANCj4gU28ganVzdCBpbiBjYXNlIGl0IGlzIG5vdCBjbGVhcjoNCj4gDQo+
IMKgwqDCoMKgwqDCoMKgwqBQbGVhc2UsIHByZXR0eSBwbGVhc2UsIERPIE5PVCB0b3AtcG9zdCBB
Q0tzIHRvIHBhdGNoZXMgbGlrZSANCj4gdGhpcy4NCj4gDQo+IEl0IGxvb2tzIGxpa2UgYSBuZXcs
IGZyZXNoLCBwYXRjaCBzdWJtaXNzaW9uIHRvIHBhdGNod29yayB0aGVyZWZvcmUgDQo+IHlvdSBh
cmUgY3JlYXRpbmcgYSBzaWduaWZpY2FudCBidXJkb24gZm9yIG1lLg0KDQpOb3QgdG8gbWVudGlv
biBoZSB3YXMgQUNLJ2luZyBoaXMgb3duIHBhdGNoIHRoYXQgaGUgYXV0aG9yZWQuIDotKA0KDQpT
b3JyeSBEYXZlLCBJIHdpbGwgd29yayB3aXRoIGhpbSBvZmZsaW5lLg0K
