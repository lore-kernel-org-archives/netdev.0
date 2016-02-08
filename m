From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: Re: [PATCH 3/4] ethtool: can't set combined and tx/rx channel
 counts at the same time
Date: Mon, 8 Feb 2016 22:15:09 +0000
Message-ID: <1454969709.25441.23.camel@intel.com>
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
Received: from mga14.intel.com ([192.55.52.115]:2431 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754457AbcBHWPL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Feb 2016 17:15:11 -0500
In-Reply-To: <20160208205247.74aaaee8@jkicinski-Precision-T1700>
Content-Language: en-US
Content-ID: <F4B62FE260B42D4D8E3A54481249D8DC@intel.com>
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
dWV1ZSBibG9ja2VkIGJ5DQo+IG90aGVyIHRoaW5ncywgdW5mb3J0dW5hdGVseS4NCg0KDQpJdCBs
b29rcyBsaWtlIHRoZXJlIHdhcyBubyBmb2xsb3cgdXAgZnJvbSB5b3VyIHByZXZpb3VzIGNvbW1l
bnQ/DQoNCkkgdGhpbmsgdGhpcyBsb29rcyByaWdodCwgaW4gd2hpY2ggY2FzZSBteSBwYXRjaCBz
aG91bGQgYmUgZHJvcHBlZC4gSQ0KZG8gbm90IHRoaW5rIHRoYXQgLm1heF9yeCBhbmQgLm1heF90
eCBpbmNsdWRlIHRoZSB0b3RhbCBmb3IgYm90aCBUeCBhbmQNClJ4IG1heGltdW1zLCB0aG91Z2gs
IHNvIEkgYW0gbm90IHN1cmUgYmVzdCBob3cgdG8gZXhwcmVzcyB0aGUNCnBvc3NpYmlsaXR5Lg0K
DQpGb3Igbm93LCBJJ2xsIGp1c3QgZHJvcCB0aGlzIHBhdGNoIGZyb20gdGhlIHNlcmllcy4NCg0K
UmVnYXJkcywNCkpha2U=
