From: "Skidmore, Donald C" <donald.c.skidmore@intel.com>
Subject: RE: [Intel-wired-lan] [BUG] Panic on boot in ixgbe with Xeon D-1531
Date: Tue, 12 Jul 2016 00:37:41 +0000
Message-ID: <F6FB0E698C9B3143BDF729DF2228664696AC91FF@ORSMSX116.amr.corp.intel.com>
References: <CAE2NFgU+p3jq2ERHDBvZGc=nf0qqjmY0WKGT-oSteeTqmoMj7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
To: Patrick McLean <patrickm@gaikai.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:6235 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932088AbcGLAhn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jul 2016 20:37:43 -0400
In-Reply-To: <CAE2NFgU+p3jq2ERHDBvZGc=nf0qqjmY0WKGT-oSteeTqmoMj7w@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

VGhlIGlnYnZmIGlzIGEgYml0IG9mIGEgcmVkIGhlcnJpbmcgc2luY2UgaXQgaXMgbm90IHRoZSBW
RiBkcml2ZXIgZm9yIGl4Z2JlIGFuZCBzcmlvdiBpc24ndCBlbmFibGUgb24gdGhpcyBib290IGFu
eXdheSBhcyB3ZSBjYW4gdGVsbCBieSB0aGUgbnVtYmVyIG9mIHF1ZXVlIGFsbG9jYXRlZC4NCg0K
QXMgZm9yIHRoZSBwYW5pYyBJIGJlbGlldmUgd2UgYWxyZWFkeSBoYXZlIGEgcGF0Y2gsIGJ1dCBp
ZiB5b3UgY291bGQgc3VwcGx5IHRoZSBEZXZJRCB3ZSBjb3VsZCB0ZWxsIHlvdSBmb3Igc3VyZS4N
Cg0KVGhhbmtzLA0KLURvbiBTa2lkbW9yZSA8ZG9uYWxkLmMuc2tpZG1vcmVAaW50ZWwuY29tPg0K
DQoNCg0KPiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBJbnRlbC13aXJlZC1s
YW4gW21haWx0bzppbnRlbC13aXJlZC1sYW4tYm91bmNlc0BsaXN0cy5vc3Vvc2wub3JnXSBPbg0K
PiBCZWhhbGYgT2YgUGF0cmljayBNY0xlYW4NCj4gU2VudDogVGh1cnNkYXksIEp1bmUgMzAsIDIw
MTYgOToxMiBQTQ0KPiBUbzogS2lyc2hlciwgSmVmZnJleSBUIDxqZWZmcmV5LnQua2lyc2hlckBp
bnRlbC5jb20+DQo+IENjOiBuZXRkZXZAdmdlci5rZXJuZWwub3JnOyBpbnRlbC13aXJlZC1sYW5A
bGlzdHMub3N1b3NsLm9yZw0KPiBTdWJqZWN0OiBbSW50ZWwtd2lyZWQtbGFuXSBbQlVHXSBQYW5p
YyBvbiBib290IGluIGl4Z2JlIHdpdGggWGVvbiBELTE1MzENCj4gDQo+IEhpLA0KPiANCj4gV2Ug
YXJlIGdldHRpbmcgYSBwYW5pYyBvbiBib290IHdpdGggTGludXMgZ2l0IGFzIG9mIHRoaXMgbW9y
bmluZy4gSSBoYXZlDQo+IGF0dGFjaGVkIHRoZSBib290IGxvZywgaXQgbG9va3MgbGlrZSB0aGUg
cGFuaWMgaXMgaW4gaWdidmYvaXhnYmUuDQo+IFRoZSBtYWNoaW5lIGlzIGJlaW5nIG5ldGJvb3Rl
ZCB2aWEgbGVnYWN5IFBYRS4NCj4gDQo+IEkgaGF2ZSBhdHRhY2hlZCB0aGUgZnVsbCBib290IGxv
ZyBmcm9tIGEga2VybmVsIHdpdGggaWdidmYgZW5hYmxlZCwgYW5kIG9uZSBsb2cNCj4gb2YganVz
dCB0aGUgcGFuaWMgbWVzc2FnZSB3aXRoIGlnYnZmIGRpc2FibGVkLiBQbGVhc2UgbGV0IG1lIGtu
b3cgaWYgeW91IG5lZWQNCj4gYW55IG1vcmUgaW5mb3JtYXRpb24uDQo=
