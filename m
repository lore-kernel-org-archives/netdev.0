From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [PATCH] net: netfilter/xt_CT.c: fix uninitialized variable
Date: Tue, 15 Jan 2013 19:06:51 +0000
Message-ID: <1358276792.1991.121.camel@ppwaskie-mobl2>
References: <1358276314-9536-1-git-send-email-dinggnu@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netfilter@vger.kernel.org" <netfilter@vger.kernel.org>,
	"coreteam@netfilter.org" <coreteam@netfilter.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Cong Ding <dinggnu@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1358276314-9536-1-git-send-email-dinggnu@gmail.com>
Content-Language: en-US
Content-ID: <54B6BD695D25314E926B20A4E27867BC@intel.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

T24gVHVlLCAyMDEzLTAxLTE1IGF0IDE5OjU4ICswMTAwLCBDb25nIERpbmcgd3JvdGU6DQo+IElm
IENPTkZJR19ORl9DT05OVFJBQ0tfWk9ORVMgaXMgbm90IGRlZmluZWQsIHRoZSB2YXJpYWJsZSBy
ZXQgbWlnaHQgYmUNCj4gdW5pbml0aWFsaXplZCB3aGVuIGl0IGdvZXMgdG8gZXJyMSB0aHJvdWdo
IGxpbmUgMTI1IGFuZCAyNjMgcmVzcGVjdGl2ZWx5Lg0KPiBTbyBJIGNoYW5nZSB0aGVzZSBnb3Rv
IGVycjEgdG8gcmV0dXJuIC1FSU5WQUwgZGlyZWN0bHkuDQo+IA0KPiBTaWduZWQtb2ZmLWJ5OiBD
b25nIERpbmcgPGRpbmdnbnVAZ21haWwuY29tPg0KPiAtLS0NCj4gIG5ldC9uZXRmaWx0ZXIveHRf
Q1QuYyB8ICAgIDQgKystLQ0KPiAgMSBmaWxlIGNoYW5nZWQsIDIgaW5zZXJ0aW9ucygrKSwgMiBk
ZWxldGlvbnMoLSkNCj4gDQo+IGRpZmYgLS1naXQgYS9uZXQvbmV0ZmlsdGVyL3h0X0NULmMgYi9u
ZXQvbmV0ZmlsdGVyL3h0X0NULmMNCj4gaW5kZXggMmEwODQzMC4uOTQxZjYwMCAxMDA2NDQNCj4g
LS0tIGEvbmV0L25ldGZpbHRlci94dF9DVC5jDQo+ICsrKyBiL25ldC9uZXRmaWx0ZXIveHRfQ1Qu
Yw0KPiBAQCAtMTIyLDcgKzEyMiw3IEBAIHN0YXRpYyBpbnQgeHRfY3RfdGdfY2hlY2tfdjAoY29u
c3Qgc3RydWN0IHh0X3RnY2hrX3BhcmFtICpwYXIpDQo+ICANCj4gICNpZm5kZWYgQ09ORklHX05G
X0NPTk5UUkFDS19aT05FUw0KPiAgCWlmIChpbmZvLT56b25lKQ0KPiAtCQlnb3RvIGVycjE7DQo+
ICsJCXJldHVybiAtRUlOVkFMOw0KPiAgI2VuZGlmDQo+ICANCj4gIAlyZXQgPSBuZl9jdF9sM3By
b3RvX3RyeV9tb2R1bGVfZ2V0KHBhci0+ZmFtaWx5KTsNCj4gQEAgLTI2MCw3ICsyNjAsNyBAQCBz
dGF0aWMgaW50IHh0X2N0X3RnX2NoZWNrX3YxKGNvbnN0IHN0cnVjdCB4dF90Z2Noa19wYXJhbSAq
cGFyKQ0KPiAgDQo+ICAjaWZuZGVmIENPTkZJR19ORl9DT05OVFJBQ0tfWk9ORVMNCj4gIAlpZiAo
aW5mby0+em9uZSkNCj4gLQkJZ290byBlcnIxOw0KPiArCQlyZXR1cm4gLUVJTlZBTDsNCj4gICNl
bmRpZg0KDQpJbiBkcm9wcGluZyBib3RoIGdvdG8ncywgeW91IGxlZnQgdGhlIGVycjEgbGFiZWwg
dW51c2VkLiAgV291bGRuJ3QganVzdA0KaW5pdGlhbGl6aW5nIHJldCB0byAtRUlOVkFMIGJlIGVh
c2llciBhbmQgY2xlYW5lcj8gIFRoZW4geW91IHdvdWxkbid0IGJlDQptZXNzaW5nIHdpdGggdGhl
IGZsb3cgb2YgdGhlIGZ1bmN0aW9uLg0KDQotUEoNCg==
