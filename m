From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [net-next-2.6 PATCH] ixgbe: Use netdev_<level>, dev_<level>,
 pr_<level>
Date: Fri, 4 Jun 2010 17:44:04 -0600
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365FF4077103@rrsmsx501.amr.corp.intel.com>
References: <20100604025225.16120.30293.stgit@localhost.localdomain>
 <1275621605.1703.38.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: Joe Perches <joe@perches.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:6846 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757461Ab0FDXoF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jun 2010 19:44:05 -0400
In-Reply-To: <1275621605.1703.38.camel@Joe-Laptop.home>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sm9lIFBlcmNoZXMgd3JvdGU6DQo+IE9uIFRodSwgMjAxMC0wNi0wMyBhdCAxOTo1MyAtMDcwMCwg
SmVmZiBLaXJzaGVyIHdyb3RlOg0KPj4gRnJvbTogRW1pbCBUYW50aWxvdiA8ZW1pbC5zLnRhbnRp
bG92QGludGVsLmNvbT4NCj4gDQo+IEhpIEVtaWwuDQo+IA0KPj4gVGhpcyBwYXRjaCBpcyBhbHRl
cm5hdGl2ZSB0byBhIHByZXZpb3VzIHBhdGNoIHN1Ym1pdHRlZCBieSBKb2UNCj4+IFBlcmNoZXMu
IA0KPiANCj4gV2h5IGVsaW1pbmF0ZSBhbGwgdGhlIGFkYXB0ZXItPm1zZ19lbmFibGUgdGVzdHM/
DQo+IA0KPiBUaGVyZSBhcmUgbWFueSBjaGFuZ2VzIGxpa2UgdGhpcy4gRm9yIGluc3RhbmNlOg0K
PiANCj4+ICAJaWYgKGxpbmtfdXAgJiYgKGxpbmtfc3BlZWQgPT0gSVhHQkVfTElOS19TUEVFRF8x
R0JfRlVMTCkpDQo+PiAtCQluZXRpZl9pbmZvKGFkYXB0ZXIsIGh3LCBhZGFwdGVyLT5uZXRkZXYs
ICJTbWFydHNwZWVkIGhhcyINCj4+IC0JCQkiIGRvd25ncmFkZWQgdGhlIGxpbmsgc3BlZWQgZnJv
bSB0aGUgbWF4aW11bSINCj4+IC0JCQkiIGFkdmVydGlzZWRcbiIpOw0KPj4gKwkJZV9pbmZvKCJT
bWFydHNwZWVkIGhhcyBkb3duZ3JhZGVkIHRoZSBsaW5rIHNwZWVkIGZyb20gIg0KPj4gKwkJICAg
ICAgICJ0aGUgbWF4aW11bSBhZHZlcnRpc2VkXG4iKTsNCj4gDQo+IFRoaXMgd2FzIG9ubHkgcHJp
bnRlZCB3aGVuIE5FVElGX01TR19IVyB3YXMgc2V0LA0KPiBub3cgaXQncyBhbHdheXMgcHJpbnRl
ZC4NCg0KVGhhdCdzIGEgZ29vZCBxdWVzdGlvbi4gSSdsbCBmaXggaXQgdXAgYW5kIHBvc3QgYSBm
b2xsb3ctdXAgcGF0Y2gsIG9yIGlmIERhdmUgd2FudHMgdG8gcmV2ZXJzZSBpdCAtIGVpdGhlciB3
YXkgaXQncyBmaW5lIHdpdGggbWUuDQoNClRoYW5rcyBmb3IgcmV2aWV3aW5nLg0KRW1pbA==
