From: Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>
Subject: RE: [PATCH v3 net-next 1/2] ethtool: Support for configurable RSS
 hash key
Date: Wed, 12 Mar 2014 08:59:36 +0000
Message-ID: <BF3270C86E8B1349A26C34E4EC1C44CB2C88E4CF@CMEXMB1.ad.emulex.com>
References: <1393589141-10597-1-git-send-email-VenkatKumar.Duvvuru@Emulex.com>
	 <0e1d7b54-dcbd-446d-b1c9-644086da138f@CMEXHTCAS2.ad.emulex.com>
	 <1394063979.2861.25.camel@deadeye.wl.decadent.org.uk>
	 <BF3270C86E8B1349A26C34E4EC1C44CB2C889D94@CMEXMB1.ad.emulex.com>
 <1394407382.15968.84.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:26454 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751802AbaCLI7i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 04:59:38 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiA+ID4gPiBXaHkgaXMgMHhERUFEQkVFRiBzcGVjaWFsPw0KPiA+ID4gU2luY2UgMCBpcyB1c2Vk
IGFzIGEgaGludCB0byByZXNldCB0byBkZWZhdWx0LCB3ZSBzaG91bGQgaGF2ZSBhIHdheQ0KPiA+
ID4gdG8gaGludCB0aGF0IGluZGlyZWN0aW9uIHRhYmxlIGNvbmZpZ3VyYXRpb24gaXMgbm90IHJl
cXVlc3RlZCBpbg0KPiA+ID4gdGhpcyBjb250ZXh0Lg0KPiA+DQo+ID4gVGhhdCdzIG5vdCBuZWNl
c3NhcnksIGFzIHlvdSBjYW4gcmVhZCBhbmQgdGhlbiB3cml0ZSBiYWNrIHRoZSBzYW1lIHZhbHVl
cy4NCj4gPg0KPiA+IEJlbi4NCj4NCg0KDQo+IE1heSBiZSB0aGlzIGlzIGV4dHJlbWVseSBoeXBv
dGhldGljYWwgYnV0IHdoYXQgaWYgYSBkcml2ZXIgZG9lc24ndCB3YW50IHRvDQo+IHN1cHBvcnQg
aW5kaXJlY3Rpb24gY29uZmlndXJhdGlvbiBhbmQgb25seSB3YW50cyB0byBzdXBwb3J0IGhhc2gg
a2V5DQo+IGNvbmZpZ3VyYXRpb24uDQo+IEluIHN1Y2ggYSBjYXNlLCB0aGUga2VybmVsIHNob3Vs
ZCBrbm93IHRoYXQgYXJlIG5vIGVudHJpZXMgb2YgaW5kaXJlY3Rpb24gaW4NCj4gcnNzX2NvbmZp
Zy4gQWxzbyBJIHRoaW5rIGl0J3MgYmV0dGVyIHRvIGtlZXAgaGFzaCBrZXkgYW5kIGluZGlyZWN0
aW9uDQo+IGNvbmZpZ3VyYXRpb25zIGluZGVwZW5kZW50IG9mIGVhY2ggb3RoZXIuDQoNCkJlbiwg
cGxlYXNlIGxldCBtZSBrbm93IHlvdXIgb3BpbmlvbiBvbiBteSBhYm92ZSBjb21tZW50LiBUaGFu
a3MuDQo=
