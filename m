From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: Re: [PATCH net-next 3/4] igb: enable internal PPS for the i210.
Date: Wed, 19 Nov 2014 19:32:33 +0000
Message-ID: <1416425553.15933.32.camel@jekeller-desk1.amr.corp.intel.com>
References: <cover.1416265321.git.richardcochran@gmail.com>
	 <e5b4ef7c56119e2d86e42f5680b1b82c9ec1a38e.1416265321.git.richardcochran@gmail.com>
	 <20141119063724.GB4109@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Vick, Matthew" <matthew.vick@intel.com>
To: "richardcochran@gmail.com" <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:16195 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753865AbaKSTfP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Nov 2014 14:35:15 -0500
In-Reply-To: <20141119063724.GB4109@localhost.localdomain>
Content-Language: en-US
Content-ID: <7330D2E0B6FC744989565E3DAA2C4C67@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gV2VkLCAyMDE0LTExLTE5IGF0IDA3OjM3ICswMTAwLCBSaWNoYXJkIENvY2hyYW4gd3JvdGU6
DQo+IE9uIFR1ZSwgTm92IDE4LCAyMDE0IGF0IDEyOjA2OjI0QU0gKzAxMDAsIFJpY2hhcmQgQ29j
aHJhbiB3cm90ZToNCj4gPiAtLS0gYS9kcml2ZXJzL25ldC9ldGhlcm5ldC9pbnRlbC9pZ2IvaWdi
X21haW4uYw0KPiA+ICsrKyBiL2RyaXZlcnMvbmV0L2V0aGVybmV0L2ludGVsL2lnYi9pZ2JfbWFp
bi5jDQo+ID4gQEAgLTUzODYsOCArNTM4NiwxNCBAQCB2b2lkIGlnYl91cGRhdGVfc3RhdHMoc3Ry
dWN0IGlnYl9hZGFwdGVyICphZGFwdGVyLA0KPiA+ICBzdGF0aWMgdm9pZCBpZ2JfdHN5bmNfaW50
ZXJydXB0KHN0cnVjdCBpZ2JfYWRhcHRlciAqYWRhcHRlcikNCj4gPiAgew0KPiA+ICAJc3RydWN0
IGUxMDAwX2h3ICpodyA9ICZhZGFwdGVyLT5odzsNCj4gPiArCXN0cnVjdCBwdHBfY2xvY2tfZXZl
bnQgZXZlbnQ7DQo+ID4gIAl1MzIgdHNpY3IgPSByZDMyKEUxMDAwX1RTSUNSKTsNCj4gPiAgDQo+
ID4gKwlpZiAodHNpY3IgJiBUU0lOVFJfU1lTX1dSQVApIHsNCj4gPiArCQlldmVudC50eXBlID0g
UFRQX0NMT0NLX1BQUzsNCj4gPiArCQlwdHBfY2xvY2tfZXZlbnQoYWRhcHRlci0+cHRwX2Nsb2Nr
LCAmZXZlbnQpOw0KPiANCj4gVGhpcyBjYXVzZXMgYSBCVUcgZm9yIHRoZSA4MjU4MC4gV2hlbiB5
b3UgZW5hYmxlIEUxMDAwX1RTSUNSX1RYVFMsIGl0DQo+IHNlZW1zIHRoYXQgVFNJTlRSX1NZU19X
UkFQIGlzIGFsc28gYXV0b21hdGljYWxseSBlbmFibGVkLiBCZWNhdXNlIHRoZQ0KPiA4MjU4MCB2
YXJpYW50IGhhcyBubyBwcHMgZGV2aWNlIGVuYWJsZWQsIHRoZSBkcml2ZXIgdGhlbiBkZXJlZmVy
ZW5jZXMNCj4gYSBudWxsIHBvaW50ZXIuDQo+IA0KPiBTbyB3ZSBuZWVkIHRvIG1ha2UgdGhlIGNh
bGwgdG8gcHRwX2Nsb2NrX2V2ZW50KCkgY29uZGl0aW9uYWwgYmFzZWQgb24NCj4gd2hldGhlciBw
cHMgaXMgZW5hYmxlZC4gSSdsbCBmaXggdGhpcyBpbiBWMi4NCj4gDQo+ID4gKwl9DQo+ID4gKw0K
PiANCj4gVGhhbmtzLA0KPiBSaWNoYXJkDQoNCkdvb2QgY2F0Y2ggOikNCg0KRGlkIHlvdSBzZWUg
bXkgY29uY2VybiBhYm91dCB0aGUgcmVzZXQgcGF0aCBuZWVkaW5nIHRvIGZ1bGx5IHJlc3RvcmUg
dGhlDQpzdGF0ZSBzaW5jZSBpdCBpcyBjYWxsZWQgYWZ0ZXIgYSBoYXJkd2FyZSBNQUMgcmVzZXQg
d2hpY2ggaGFzIGNsZWFyZWQNCmFsbCB0aGVzZSByZWdpc3RlcnM/DQoNClJlZ2FyZHMsDQpKYWtl
DQo=
