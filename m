From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: e1000e on thinkpad x60: interrupt problem
Date: Tue, 9 Jul 2013 17:15:48 +0000
Message-ID: <1373390146.4286.1.camel@ppwaskie-mobl2>
References: <20130709010500.GA21248@amd.pavel.ucw.cz>
	 <D38E8E86660E514AB505863C19C9287C73E60E70@ORSMSX102.amr.corp.intel.com>
	 <20130709170242.GA14112@amd.pavel.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "Ronciak, John" <john.ronciak@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Dave, Tushar N" <tushar.n.dave@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Pavel Machek <pavel@ucw.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:18753 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751197Ab3GIRPu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jul 2013 13:15:50 -0400
In-Reply-To: <20130709170242.GA14112@amd.pavel.ucw.cz>
Content-Language: en-US
Content-ID: <5AA23D6FD6F81841B821FBE6A1E6C314@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gVHVlLCAyMDEzLTA3LTA5IGF0IDE5OjAyICswMjAwLCBQYXZlbCBNYWNoZWsgd3JvdGU6DQo+
IEhpIQ0KPiANCj4gPiBOb3RoaW5nIGFwcGVhcnMgdG8gYmUgd3JvbmcuICBJZiB0aGUgc3lzdGVt
IGlzIHNlZWluZyBwaW5nIHBhY2tldHMNCj4gPmF0IGFsbCBtZWFucyB0aGF0IGRldmljZSBpcyBn
ZW5lcmF0aW5nIGludGVycnVwdHMgYW5kIHRoYXQgdGhleSBhcmUNCj4gPmJlaW5nIHByb2Nlc3Nl
ZC4gIElmIHlvdSBhcmUgbG9va2luZyBhdCBwZXJmb3JtYW5jZSB0aGVuIHNoYXJpbmcNCj4gDQo+
IE5vLCB0aGF0J3Mgbm90IHRydWUuIFRoZXJlIGlzIG90aGVyIGludGVycnVwdCBsb2FkLCBhbmQg
ZTEwMDBlIGhhcyBiaWcNCj4gZW5vdWdoIGJ1ZmZlcnM7IHRoYXQgbWVhbnMgdGhhdCBwYWNrZXRz
IGV2ZW50dWFsbHkgZ2V0IHByb2Nlc3NlZC4gSQ0KPiBzdHJvbmdseSBzdXNwZWN0IGUxMDAwZSBn
ZW5lcmF0ZXMgbGl0dGxlIG9yIG5vIGludGVycnVwdHMgYW5kIHBhY2tldHMNCj4gb25seSBnZXQg
cHJvY2Vzc2VkIHdoZW4gb3RoZXIgZGV2aWNlcyBvbiBzaGFyZWQgaW50ZXJydXB0IGxpbmUNCj4g
Z2VuZXJhdGUgaW50ZXJydXB0LiANCg0KSWYgdGhlIGludGVycnVwdCBpcyBzaGFyZWQsIGUxMDAw
ZSBjaGVja3MgaWYgaXQncyB0aGUgaGFyZHdhcmUgdGhhdA0KZ2VuZXJhdGVkIGl0IGJlZm9yZSBw
cm9jZXNzaW5nIHBhY2tldHMuICBDb25zdW1pbmcgYW4gaW50ZXJydXB0IHRoYXQNCmlzbid0IG1l
YW50IGZvciB0aGlzIGRldmljZSB3aWxsIHRocm93IG1ham9yIHdhcm5pbmdzIGluIHRoZSBrZXJu
ZWwNCmFib3V0IGJhZCBpbnRlcnJ1cHQgcm91dGluZywgZXRjLiAgSGVyZSdzIHRoZSBjb2RlIGZy
b20gdGhlIGludGVycnVwdA0KaGFuZGxlciAobm90ZSB0aGUgbGFzdCBwYXJ0IG9mIHRoZSBwYXN0
ZWQgY29kZSk6DQoNCi8qKg0KICogZTEwMDBfaW50ciAtIEludGVycnVwdCBIYW5kbGVyDQogKiBA
aXJxOiBpbnRlcnJ1cHQgbnVtYmVyDQogKiBAZGF0YTogcG9pbnRlciB0byBhIG5ldHdvcmsgaW50
ZXJmYWNlIGRldmljZSBzdHJ1Y3R1cmUNCiAqKi8NCnN0YXRpYyBpcnFyZXR1cm5fdCBlMTAwMF9p
bnRyKGludCBfX2Fsd2F5c191bnVzZWQgaXJxLCB2b2lkICpkYXRhKQ0Kew0KICAgICAgICBzdHJ1
Y3QgbmV0X2RldmljZSAqbmV0ZGV2ID0gZGF0YTsNCiAgICAgICAgc3RydWN0IGUxMDAwX2FkYXB0
ZXIgKmFkYXB0ZXIgPSBuZXRkZXZfcHJpdihuZXRkZXYpOw0KICAgICAgICBzdHJ1Y3QgZTEwMDBf
aHcgKmh3ID0gJmFkYXB0ZXItPmh3Ow0KICAgICAgICB1MzIgcmN0bCwgaWNyID0gZXIzMihJQ1Ip
Ow0KDQogICAgICAgIGlmICghaWNyIHx8IHRlc3RfYml0KF9fRTEwMDBfRE9XTiwgJmFkYXB0ZXIt
PnN0YXRlKSkNCiAgICAgICAgICAgICAgICByZXR1cm4gSVJRX05PTkU7ICAvKiBOb3Qgb3VyIGlu
dGVycnVwdCAqLw0KDQogICAgICAgIC8qIElNUyB3aWxsIG5vdCBhdXRvLW1hc2sgaWYgSU5UX0FT
U0VSVEVEIGlzIG5vdCBzZXQsIGFuZCBpZiBpdA0KaXMNCiAgICAgICAgICogbm90IHNldCwgdGhl
biB0aGUgYWRhcHRlciBkaWRuJ3Qgc2VuZCBhbiBpbnRlcnJ1cHQNCiAgICAgICAgICovDQogICAg
ICAgIGlmICghKGljciAmIEUxMDAwX0lDUl9JTlRfQVNTRVJURUQpKQ0KICAgICAgICAgICAgICAg
IHJldHVybiBJUlFfTk9ORTsNCg0KQ2hlZXJzLA0KLVBKDQo=
