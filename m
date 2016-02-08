From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: Re: [PATCH 3/4] ethtool: can't set combined and tx/rx channel
 counts at the same time
Date: Mon, 8 Feb 2016 22:00:16 +0000
Message-ID: <1454968816.25441.20.camel@intel.com>
References: <1454961965-15116-1-git-send-email-jacob.e.keller@intel.com>
	 <1454961965-15116-4-git-send-email-jacob.e.keller@intel.com>
	 <20160208205247.74aaaee8@jkicinski-Precision-T1700>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "moorray3@wp.pl" <moorray3@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:52026 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755658AbcBHWA2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Feb 2016 17:00:28 -0500
In-Reply-To: <20160208205247.74aaaee8@jkicinski-Precision-T1700>
Content-Language: en-US
Content-ID: <100BECC1115023418546DBCED1B2B053@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gTW9uLCAyMDE2LTAyLTA4IGF0IDIwOjUyICswMDAwLCBKYWt1YiBLaWNpbnNraSB3cm90ZToN
Cj4gT24gTW9uLMKgwqA4IEZlYiAyMDE2IDEyOjA2OjA0IC0wODAwLCBKYWNvYiBLZWxsZXIgd3Jv
dGU6DQo+ID4gKwkvKiBjYW4ndCBzZXQgY29tYmluZWQgYW5kIHNlcGFyYXRlIGNoYW5uZWxzIGF0
IHRoZSBzYW1lDQo+ID4gdGltZSAqLw0KPiA+ICsJaWYgKChjaGFubmVscy5jb21iaW5lZF9jb3Vu
dCAmJg0KPiA+ICsJwqDCoMKgwqDCoChjaGFubmVscy5yeF9jb3VudCB8fCBjaGFubmVscy50eF9j
b3VudCkpDQo+ID4gKwnCoMKgwqDCoHJldHVybiAtRUlOVkFMOw0KPiA+ICsNCj4gPiDCoAkvKiBl
bnN1cmUgdGhlIG5ldyBSeCBjb3VudCBmaXRzIHdpdGhpbiB0aGUgY29uZmlndXJlZCBSeA0KPiA+
IGZsb3cNCj4gPiDCoAnCoCogaW5kaXJlY3Rpb24gdGFibGUgc2V0dGluZ3MgKi8NCj4gPiDCoAlp
ZiAobmV0aWZfaXNfcnhmaF9jb25maWd1cmVkKGRldikgJiYNCj4gDQo+IE15IHVuZGVyc3RhbmRp
bmcgaXMgdGhhdCB1bnN5bW1ldHJpY2FsIHJ4L3R4IHF1ZXVlIGNvbmZpZ3VyYXRpb24gd2l0aA0K
PiBjb21iaW5lZCBJUlEgdmVjdG9ycyBzaG91bGQgYmUgZXhwcmVzc2VkIGFzOg0KPiANCj4gY29t
YmluZWQgPSBtaW4odHgsIHJ4KTsNCj4gbnVtX3R4ID0gdHggLSBjb21iaW5lZDsNCj4gbnVtX3J4
ID0gcnggLSBjb21iaW5lZDsNCj4gDQo+IFBsZWFzZSBzZWU6DQo+IA0KPiBodHRwczovL3d3dy5t
YWlsLWFyY2hpdmUuY29tL25ldGRldkB2Z2VyLmtlcm5lbC5vcmcvbXNnOTM5NzcuaHRtbA0KPiAN
Cj4gUGF0Y2hlcyB3aGljaCBJIGNvb2tlZCB1cCBmb3IgdGhpcyBhcmUgcm90dGluZyBpbiBteSBx
dWV1ZSBibG9ja2VkIGJ5DQo+IG90aGVyIHRoaW5ncywgdW5mb3J0dW5hdGVseS4NCg0KVGhhdCdz
IGRlZmluaXRlbHkgbm90IGhvdyBhbnkgZHJpdmVyIGN1cnJlbnRseSB1c2VzIGl0IHRvZGF5LCB0
aGF0IEkNCmNhbiBzZWUuLi4gQXQgbGVhc3QgZHJpdmVycy9uZXQvZXRoZXJuZXQvYnJvYWRjb20v
Ym54dC9ibnh0X2V0aHRvb2wuYw0KaXMgY3VycmVudGx5IGFzc3VtaW5nIHlvdSBjYW4ndCBzZXQg
Y29tYmluZWQgYW5kIGFzeW1tZXRyaWMgcXVldWVzIGF0DQp0aGUgc2FtZSB0aW1lLg0KDQpJIGNh
biBvayBkcm9wcGluZyB0aGlzIGNoYW5nZSwgYW5kIGxvb2tpbmcgYXQgaW1wbGVtZW50aW5nIHdo
YXQgeW91DQpzdWdnZXN0LCBhcyB0aGF0IG1ha2VzIG1vcmUgc2Vuc2UgdG8gbWUuDQoNClJlZ2Fy
ZHMsDQpKYWtl
