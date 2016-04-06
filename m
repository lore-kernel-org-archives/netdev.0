From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: Re: [net-next 03/16] fm10k: Avoid crashing the kernel
Date: Wed, 6 Apr 2016 23:24:12 +0000
Message-ID: <1459985052.17828.22.camel@intel.com>
References: <1459843288-40623-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1459843288-40623-4-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20160405.121234.207383895896842448.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "nhorman@redhat.com" <nhorman@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>
To: "davem@davemloft.net" <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:45466 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752352AbcDFXYP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Apr 2016 19:24:15 -0400
In-Reply-To: <20160405.121234.207383895896842448.davem@davemloft.net>
Content-Language: en-US
Content-ID: <0432712159ED9C43A43706E6790516C3@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gVHVlLCAyMDE2LTA0LTA1IGF0IDEyOjEyIC0wNDAwLCBEYXZpZCBNaWxsZXIgd3JvdGU6DQo+
IEFzIEpvZSBzdWdnZXN0ZWQsIGl0IGlzIG5vdCByZWFzb25hYmxlIHRvIGV4cGVjdCBhbGwgY29t
cGlsZXJzIHRvIGJlDQo+IGFibGUgdG8gZmlndXJlDQo+IG91dCB0aGUgcmVzdWx0IG9mIGFsbCBv
ZiB0aGUgaW5kZXggaW5jcmVtZW50cyBpbiB0aGlzIGZ1bmN0aW9uIGxlYWQNCj4gdG8gYSBzcGVj
aWZpYw0KPiBjb25zdGFudCB2YWx1ZS4NCj4gDQo+IFlvdXIgb25seSBvcHRpb24gaXMgdG8gZWl0
aGVyIGtlZXAgdGhlIGNvZGUgYXMtaXMsIG9yIGFkZCBwcm9wZXINCj4gZXJyb3IgcmVwb3J0aW5n
IHRvDQo+IHRoaXMgZnVuY3Rpb24gYW5kIHRvIGFsbCBjYWxsZXJzLCBpbiBvcmRlciB0byBoYW5k
bGUgdGhlIHNpdHVhdGlvbiBhdA0KPiBydW4gdGltZSB3aGljaA0KPiBJIHJlYWxpemUgaXMgZXhh
Y3RseSB3aGF0IHlvdSBhcmUgdHJ5aW5nIHRvIGF2b2lkLg0KPiANCj4gSWYgdGhpcyBjcmFzaGVz
IGF0IHJ1biB0aW1lIHdpdGggdGhlIEJVR19PTigpLCBpdCdzIGdvaW5nIHRvIGhhcHBlbg0KPiBy
ZWFsbHkgcXVpY2tseQ0KPiB3aGVuIHlvdSBicmluZyB0aGUgaW50ZXJmYWNlIHVwLsKgwqBTbyBJ
IGRvbid0IHNlZSANCj4gdGhlIHJ1biB0aW1lIGNoZWNrIGFzIHNvIHRyYWdpYy4NCg0KU28gd2Un
cmUgb2sgd2l0aCBqdXN0IG5vdCBjaGFuZ2luZyB0aGlzIHRoZW4sIGFuZCBsaXZpbmcgd2l0aCBh
IGNyYXNoPw0KVGhhdCdzIGZpbmUgd2l0aCBtZSwgSSBzdXBwb3NlLg0KDQpTaG91bGQgdGhlIHNl
Y29uZCBXQVJOX09OQ0UgYmUgY2hhbmdlZCB0byBhIEJVR19PTiBhcyB3ZWxsIHRvIGdldCBhDQpj
cmFzaCBpbnN0ZWFkIG9mIGp1c3QgYSB3YXJuaW5nP8KgDQoNClRoYW5rcywNCkpha2U=
