From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH net v2 2/2] r8152: reset device when tx timeout
Date: Wed, 29 Jul 2015 02:06:40 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB2F3C673@RTITMBSV03.realtek.com.tw>
References: <1394712342-15778-156-Taiwan-albertk@realtek.com>
	 <1394712342-15778-159-Taiwan-albertk@realtek.com>
	 <1394712342-15778-161-Taiwan-albertk@realtek.com>
	 <1438085645.1787.4.camel@suse.com>
	 <0835B3720019904CB8F7AA43166CEEB2F3C538@RTITMBSV03.realtek.com.tw>
 <1438088317.1787.5.camel@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	nic_swsd <nic_swsd@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: Oliver Neukum <oneukum@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438088317.1787.5.camel@suse.com>
Content-Language: zh-TW
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

IE9saXZlciBOZXVrdW0gW21haWx0bzpvbmV1a3VtQHN1c2UuY29tXQ0KPiBTZW50OiBUdWVzZGF5
LCBKdWx5IDI4LCAyMDE1IDg6NTkgUE0NClsuLi5dDQo+ID4gPiA+ICBzdGF0aWMgdm9pZCBydGw4
MTUyX3R4X3RpbWVvdXQoc3RydWN0IG5ldF9kZXZpY2UgKm5ldGRldikgIHsNCj4gPiA+ID4gICAg
ICAgICBzdHJ1Y3QgcjgxNTIgKnRwID0gbmV0ZGV2X3ByaXYobmV0ZGV2KTsNCj4gPiA+ID4gLSAg
ICAgICBpbnQgaTsNCj4gPiA+ID4NCj4gPiA+ID4gICAgICAgICBuZXRpZl93YXJuKHRwLCB0eF9l
cnIsIG5ldGRldiwgIlR4IHRpbWVvdXRcbiIpOw0KPiA+ID4gPiAtICAgICAgIGZvciAoaSA9IDA7
IGkgPCBSVEw4MTUyX01BWF9UWDsgaSsrKQ0KPiA+ID4gPiAtICAgICAgICAgICAgICAgdXNiX3Vu
bGlua191cmIodHAtPnR4X2luZm9baV0udXJiKTsNCj4gPiA+ID4gKw0KPiA+ID4gPiArICAgICAg
IHVzYl9xdWV1ZV9yZXNldF9kZXZpY2UodHAtPmludGYpOw0KPiA+ID4gPiArICAgICAgIGNhbmNl
bF9kZWxheWVkX3dvcmsoJnRwLT5zY2hlZHVsZSk7DQo+ID4gPg0KPiA+ID4gU29ycnkgdG8gYm90
aGVyIHlvdSBhZ2FpbiwgYnV0IHRoaXMgbG9va3Mgd3JvbmcuDQo+ID4gPiBZb3Ugd2FudCB0byBj
YW5jZWwgZmlyc3QuIFRoZXJlIGlzIG5vIHBvaW50IGluIHJ1bm5pbmcgYW55IHdvcmsNCj4gPiA+
IGJlZm9yZSB0aGUgcmVzZXQgaXMgZG9uZS4gSXQgd2lsbCB1bmRvIGFueSBwcm9ncmVzcyBhbnl3
YXkuDQo+ID4NCj4gPiBFeGN1c2UgbWUuIERvIHlvdSBtZWFuIEkgZG9uJ3QgbmVlZCBjYW5jZWwg
dGhlIG90aGVyIHdvcmsgYmVjYXVzZSBpdA0KPiA+IHdvdWxkbid0IGJlIHJ1biBiZWZvcmUgdGhl
IHJlc2V0IGlzIGZpbmlzaGVkPw0KPiANCj4gTm8sIHdoYXRldmVyIHRoZSBvdGhlciB3b3JrIHdp
bGwgZG8sIHRoZSByZXNldCB3aWxsIHVuZG8uDQoNCkV4Y3VzZSBtZS4gSSBkb24ndCB1bmRlcnN0
YW5kIHdoeSBJIGNvdWxkbid0IHVzZSB1c2JfcXVldWVfcmVzZXRfZGV2aWNlKCkgZGlyZWN0bHku
DQpXaHkgdGhlIHJlc2V0IHdpbGwgdW5kbz8gDQoNCkJlc3QgUmVnYXJkcywNCkhheWVzDQoNCg==
