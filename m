From: "Reuben Dowle" <Reuben.Dowle@navico.com>
Subject: RE: [PATCH] flexcan: Fix CAN_RAW_RECV_OWN_MSGS and CAN_RAW_LOOPBACK
Date: Thu, 3 Nov 2011 10:31:13 +1300
Message-ID: <70F6AAAFDC054F41B9994A9BCD3DF64E16FAA8E0@exch01-aklnz.MARINE.NET.INT>
References: <70F6AAAFDC054F41B9994A9BCD3DF64E16FAA1DD@exch01-aklnz.MARINE.NET
 .INT> <20111102080438.GA324@e-circ.dyndns.org>
 <70F6AAAFDC054F41B9994A9BCD3DF64E16FAA803@exch01-aklnz.MARINE.NET.INT>
 <4EB1A883.2040605@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain;charset="UTF-8"
Content-Transfer-Encoding: base64
Cc: "Kurt Van Dijck" <kurt.van.dijck@eia.be>, <netdev@vger.kernel.org>,
	<linux-can@vger.kernel.org>
To: "Oliver Hartkopp" <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vw-hfger.navico.com ([81.89.228.210]:2400 "EHLO
	VW-HFGER.navico.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750817Ab1KBVbW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2011 17:31:22 -0400
Content-class: urn:content-classes:message
In-Reply-To: <4EB1A883.2040605@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiA+DQo+ID4gSWYgd2UgY2hhbmdlIHRoZSBiZWhhdmlvdXIgb2YgZmxleGNhbiwgSSB0aGlu
ayBhdDkxIGFuZCBzbGNhbiBzaG91bGQNCj4gYmUgY2hhbmdlZCB0b28sIGJlY2F1c2UgdGhp
cyBzaG91bGQgYmUgaGFuZGxlZCBjb25zaXN0ZW50bHkgYWNyb3NzIGFsbA0KPiBkcml2ZXJz
IEkgd291bGQgdGhpbmsuDQo+IA0KPiANCj4gQXQgbGVhc3QgdGhlIHNsY2FuIGRyaXZlciBk
b2VzIG5vdCBzdXBwb3J0IHRoZSBjb3JyZWN0IGVjaG8gb2YgQ0FODQo+IGZyYW1lcyBvbg0K
PiBkcml2ZXIgbGV2ZWwgYXQgYWxsLiBUaGUgc2xjYW4gZHJpdmVyIGFkYXB0cyBDQU4gZnJh
bWVzIHRvIGEgc2VyaWFsDQo+IGxpbmUgQ0FODQo+IGFkYXB0ZXIgd2hlcmUgdGhlIGZlZWRi
YWNrIG9mIHN1Y2Nlc3NmdWwgdHJhbnNtaXNzaW9uIGlzIG5vdA0KPiBndWFyYW50ZWVkL2No
ZWNrZWQgd2l0aGluIHRoZSBzZXJpYWwgZGF0YSBzdHJlYW0uIFRoZXJlZm9yZSB0aGUNCj4g
aW50ZXJmYWNlIGZsYWcNCj4gSUZGX0VDSE8gaXMgbm90IHNldCBpbiB0aGUgc2xjYW4gZHJp
dmVyIGFuZCB0aGUgbG9jYWwgZWNobyBpcyBwZXJmb3JtZWQNCj4gaW4NCj4gYWZfY2FuLmMg
KGFzIGEgd29ya2Fyb3VuZCkuDQo+IA0KPiBSZWdhcmRzLA0KPiBPbGl2ZXINCg0KVGhhdHMg
ZmluZSBmb3IgdGhlIGVjaG8gYmVoYXZpb3VyLCBidXQgZG9lcyBub3QgcmVhbGx5IGFuc3dl
ciB3aHkgdGhlIHNsY2FuDQooYW5kIGZsZXhjYW4pIGRyaXZlciBpcyBzZXR0aW5nIHRoZSBz
dGF0cyBmb3IgdHhfcGFja2V0cyBhbmQgdHhfYnl0ZXMgYXQgDQpkaWZmZXJlbnQgcG9pbnRz
IGluIHRoZSB0cmFuc21pc3Npb24gbG9naWMuIFRvIG15IG1pbmQsIGVpdGhlciB3ZSB0aGlu
ayB0aGUNCnBhY2tldCBoYXMgdHJhbnNtaXR0ZWQgKGFsb25nIHdpdGggaXRzIGJ5dGVzKSBz
byB3ZSBzaG91bGQgaW5jcmVtZW50IGJvdGgsDQpvciB3ZSBzaG91bGQgaW5jcmVtZW50IG5l
aXRoZXIuDQoNClJldWJlbg0KDQo=
