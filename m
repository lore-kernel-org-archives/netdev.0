From: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Subject: RE: [net-next 04/10] igb: Fix for sparse warning in
 igb_get_i2c_client
Date: Tue, 12 Feb 2013 17:12:34 +0000
Message-ID: <9BBC4E0CF881AA4299206E2E1412B6264EE7F672@ORSMSX102.amr.corp.intel.com>
References: <1360319958-10497-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1360319958-10497-5-git-send-email-jeffrey.t.kirsher@intel.com>
 <1360602355.2701.5.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Ben Hutchings <bhutchings@solarflare.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:46227 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933470Ab3BLRMh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Feb 2013 12:12:37 -0500
In-Reply-To: <1360602355.2701.5.camel@bwh-desktop.uk.solarflarecom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBuZXRkZXYtb3duZXJAdmdlci5r
ZXJuZWwub3JnIFttYWlsdG86bmV0ZGV2LW93bmVyQHZnZXIua2VybmVsLm9yZ10NCj4gT24gQmVo
YWxmIE9mIEJlbiBIdXRjaGluZ3MNCj4gU2VudDogTW9uZGF5LCBGZWJydWFyeSAxMSwgMjAxMyA5
OjA2IEFNDQo+IFRvOiBLaXJzaGVyLCBKZWZmcmV5IFQ7IFd5Ym9ybnksIENhcm9seW4NCj4gQ2M6
IGRhdmVtQGRhdmVtbG9mdC5uZXQ7IG5ldGRldkB2Z2VyLmtlcm5lbC5vcmc7IGdvc3BvQHJlZGhh
dC5jb207DQo+IHNhc3NtYW5uQHJlZGhhdC5jb20NCj4gU3ViamVjdDogUmU6IFtuZXQtbmV4dCAw
NC8xMF0gaWdiOiBGaXggZm9yIHNwYXJzZSB3YXJuaW5nIGluIGlnYl9nZXRfaTJjX2NsaWVudA0K
PiANCj4gT24gRnJpLCAyMDEzLTAyLTA4IGF0IDAyOjM5IC0wODAwLCBKZWZmIEtpcnNoZXIgd3Jv
dGU6DQo+ID4gRnJvbTogQ2Fyb2x5biBXeWJvcm55IDxjYXJvbHluLnd5Ym9ybnlAaW50ZWwuY29t
Pg0KPiA+DQo+ID4gVGhpcyBwYXRjaCBjaGFuZ2VzIGRlZmluaXRpb24gb2YgaTJjX2NsaWVudCBp
biBpZ2JfZ2V0X2kyY19jbGllbnQgdG8NCj4gPiBzdGF0aWMgdG8gcHJldmVudCBzcGFyc2Ugd2Fy
bmluZy4NCj4gDQo+IFNvLCBpbiBvcmRlciB0byBmaXggdGhlIHdhcm5pbmc6DQo+IA0KPiBkcml2
ZXJzL25ldC9ldGhlcm5ldC9pbnRlbC9pZ2IvaWdiX21haW4uYzo3NjExOjE5OiB3YXJuaW5nOiBz
eW1ib2wNCj4gJ2lnYl9nZXRfaTJjX2NsaWVudCcgd2FzIG5vdCBkZWNsYXJlZC4gU2hvdWxkIGl0
IGJlIHN0YXRpYz8NClsuLl0NCg0KQW5kIHRoaXMgd2FzIG5vdCB0aGUgd2FybmluZyBJIHdhcyB0
cnlpbmcgdG8gZml4IHdpdGggdGhlIHN0YXRpYyBjaGFuZ2UuICBUaGUgc3BhcnNlIHdhcm5pbmcg
d2FzICJjYXN0IHRvIA0KcmVzdHJpY3RlZCBfX2xlNjQuIiAgTm90IHN1cmUgd2h5IHlvdSBhcmUg
c2VlaW5nIHRoYXQgcGFydGljdWxhciB3YXJuaW5nLCBidXQgSSB3aWxsIGxvb2sgZm9yIGl0IGlu
IG15IG5leHQgcGF0Y2ggb24gdGhpcyBmdW5jdGlvbi4NCg0KVGhhbmtzLA0KDQpDYXJvbHluDQoN
CkNhcm9seW4gV3lib3JueSANCkxpbnV4IERldmVsb3BtZW50IA0KTmV0d29ya2luZyBEaXZpc2lv
biANCkludGVsIENvcnBvcmF0aW9uIA0KDQoNCg==
