From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH net v2 2/2] r8152: reset device when tx timeout
Date: Wed, 29 Jul 2015 11:09:32 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB2F3CDA7@RTITMBSV03.realtek.com.tw>
References: <1394712342-15778-156-Taiwan-albertk@realtek.com>
	 <1394712342-15778-159-Taiwan-albertk@realtek.com>
	 <1394712342-15778-161-Taiwan-albertk@realtek.com>
	 <1438085645.1787.4.camel@suse.com>
	 <0835B3720019904CB8F7AA43166CEEB2F3C538@RTITMBSV03.realtek.com.tw>
	 <1438088317.1787.5.camel@suse.com>
	 <0835B3720019904CB8F7AA43166CEEB2F3C673@RTITMBSV03.realtek.com.tw>
 <1438154521.9445.3.camel@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	nic_swsd <nic_swsd@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: Oliver Neukum <oneukum@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438154521.9445.3.camel@suse.com>
Content-Language: zh-TW
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

T2xpdmVyIE5ldWt1bSBbbWFpbHRvOm9uZXVrdW1Ac3VzZS5jb21dDQo+IFNlbnQ6IFdlZG5lc2Rh
eSwgSnVseSAyOSwgMjAxNSAzOjIyIFBNDQpbLi4uXQ0KPiBOb3csIEkgdGhpbmsgSSBnb3QgdGhl
IHJlYXNvbiBmb3IgdGhlIGNvbmZ1c2lvbi4NCj4gDQo+IFlvdSBhcmUgdXNpbmcgY2FuY2VsX2Rl
bGF5ZWRfd29yaygmdHAtPnNjaGVkdWxlKTsgYWZ0ZXIgeW91IHF1ZXVlIGEgcmVzZXQuDQo+IFRo
ZXJlZm9yZSB0aGUgb3JkZXIgaW4gd2hpY2ggdGhlIHdvcmsgYW5kIHRoZSByZXNldCB3aWxsIGJl
IGV4ZWN1dGVkIGlzIHVuZGVmaW5lZC4NCj4gVXN1YWxseSB0aGUgc2NoZWR1bGVkIHdvcmsgd2ls
bCBiZSBjYW5jZWxlZCwgYnV0IG5vdCBhbHdheXMuDQoNCkFjdHVhbGx5LCB0aGUgb3JkZXIgaXMg
bm90IGltcG9ydGFudCBmb3IgbWUuIFRoZXJlIGFyZSBzb21lIHByb3RlY3Rpb25zIHRvIGF2b2lk
DQp0aGUgd29yayBhbmQgdGhlIHJlc2V0IHJ1biBhdCB0aGUgc2FtZSB0aW1lLiBCZXNpZGVzLCB0
aGUgcmVzZXQgY291bGQgYmUgcnVuIGJlZm9yZQ0Kb3IgYWZ0ZXIgdGhlIHdvcmsuIEkgY2FuY2Vs
IHRoZSB3b3JrIGJlY2F1c2UgSSB3YW50IHRvIGxldCB0aGUgcmVzZXQgc3RhcnQgYXMgZWFybHkg
YXMNCnBvc3NpYmxlLiBJZiB0aGUgd29yayBydW5zIGJlZm9yZSB0aGUgcmVzZXQsIHRoZSByZXNl
dCB3b3VsZG4ndCBzdGFydCB1bnRpbCB0aGUgd29yayBpcw0KZmluaXNoZWQuDQoNCj4gVGhhdCBp
cyBub3QgZ29vZC4NCg0KSSB0aGluayBJIGhhZCBiZXR0ZXIgdG8gcmVtb3ZlIGNhbmNlbF9kZWxh
eV93b3JrKCksIGJlY2F1c2UgaXQgbWFrZXMgY29uZnVzaW9uLg0KQW5kLCBpdCBkb2Vzbid0IHNl
ZW0gdG8gYmUgbmVjZXNzYXJ5LiBUaGFua3MuIA0KDQpCZXN0IFJlZ2FyZHMsDQpIYXllcw0KDQo=
