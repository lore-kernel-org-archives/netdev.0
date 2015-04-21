From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH] e1000e: Do not allow CRC stripping to
 be disabled on 82579 w/ jumbo frames
Date: Tue, 21 Apr 2015 03:12:05 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B78DA68B4@ORSMSX101.amr.corp.intel.com>
References: <20150409013554.3231.10427.stgit@ahduyck-vm-fedora22>
 <1428548302.2729.9.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
To: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:44448 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753058AbbDUDMH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Apr 2015 23:12:07 -0400
In-Reply-To: <1428548302.2729.9.camel@jtkirshe-mobl>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBGcm9tOiBJbnRlbC13aXJlZC1sYW4gW21haWx0bzppbnRlbC13aXJlZC1sYW4tYm91bmNlc0Bs
aXN0cy5vc3Vvc2wub3JnXSBPbg0KPiBCZWhhbGYgT2YgSmVmZiBLaXJzaGVyDQo+IFNlbnQ6IFdl
ZG5lc2RheSwgQXByaWwgMDgsIDIwMTUgNzo1OCBQTQ0KPiBUbzogQWxleGFuZGVyIER1eWNrDQo+
IENjOiBuZXRkZXZAdmdlci5rZXJuZWwub3JnOyBpbnRlbC13aXJlZC1sYW5AbGlzdHMub3N1b3Ns
Lm9yZw0KPiBTdWJqZWN0OiBSZTogW0ludGVsLXdpcmVkLWxhbl0gW1BBVENIXSBlMTAwMGU6IERv
IG5vdCBhbGxvdyBDUkMgc3RyaXBwaW5nDQo+IHRvIGJlIGRpc2FibGVkIG9uIDgyNTc5IHcvIGp1
bWJvIGZyYW1lcw0KPiANCj4gT24gV2VkLCAyMDE1LTA0LTA4IGF0IDE4OjM3IC0wNzAwLCBBbGV4
YW5kZXIgRHV5Y2sgd3JvdGU6DQo+ID4gVGhlIGRyaXZlciB3YXNuJ3QgYWxsb3dpbmcganVtYm8g
ZnJhbWVzIHRvIGJlIGVuYWJsZWQgd2hlbiBDUkMNCj4gPiBzdHJpcHBpbmcNCj4gPiB3YXMgZGlz
YWJsZWQsIGhvd2V2ZXIgaXQgd2FzIGFsbG93aW5nIENSQyBzdHJpcHBpbmcgdG8gYmUgZGlzYWJs
ZWQNCj4gPiB3aGlsZQ0KPiA+IGp1bWJvIGZyYW1lcyB3ZXJlIGVuYWJsZWQuICBUaGlzIGZpeGVz
IHRoYXQgYnkgbWFraW5nIGl0IHNvIHRoYXQgdGhlDQo+ID4gTkVUSUZfRl9SWEZDUyBmbGFnIGNh
bm5vdCBiZSBzZXQgd2hlbiBqdW1ibyBmcmFtZXMgYXJlIGVuYWJsZWQgb24NCj4gPiA4MjU3OSBh
bmQNCj4gPiBuZXdlciBwYXJ0cy4NCj4gPg0KPiA+IFNpZ25lZC1vZmYtYnk6IEFsZXhhbmRlciBE
dXljayA8YWxleGFuZGVyLmguZHV5Y2tAcmVkaGF0LmNvbT4NCj4gPiAtLS0NCj4gPiAgZHJpdmVy
cy9uZXQvZXRoZXJuZXQvaW50ZWwvZTEwMDBlL25ldGRldi5jIHwgICAxNCArKysrKysrKysrKysr
Kw0KPiA+ICAxIGZpbGUgY2hhbmdlZCwgMTQgaW5zZXJ0aW9ucygrKQ0KPiANCj4gVGhhbmtzIEFs
ZXgsIEkgd2lsbCBhZGQgeW91ciBwYXRjaCB0byBteSBxdWV1ZS4NCg0KVGVzdGVkLWJ5OiBBYXJv
biBCcm93biA8YWFyb24uZi5icm93bkBpbnRlbC5jb20+DQoNCj4gLS0NCj4gZ2l0Oi8vZ2l0Lmtl
cm5lbC5vcmcvcHViL3NjbS9saW51eC9rZXJuZWwvZ2l0L2praXJzaGVyL25leHQtcXVldWUuZ2l0
DQo+IGRldi1xdWV1ZQ0K
