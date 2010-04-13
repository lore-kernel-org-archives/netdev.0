From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 1/3 (TAKE 3 RESENT)] ipv6 mcast: Introduce
 include/net/mld.h for MLD definitions.
Date: Tue, 13 Apr 2010 01:21:55 -0700 (PDT)
Message-ID: <20100413.012155.66629185.davem@davemloft.net>
References: <201004080659.o386xIXP019382@94.43.138.210.xn.2iij.net>
	<20100408094753.596bb61c@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37415
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751112Ab0DMIVv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 04:21:51 -0400
In-Reply-To: <20100408094753.596bb61c@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogU3RlcGhlbiBIZW1taW5nZXIgPHNoZW1taW5nZXJAdnlhdHRhLmNvbT4NCkRhdGU6IFRo
dSwgOCBBcHIgMjAxMCAwOTo0Nzo1MyAtMDcwMA0KDQo+IElzIHRoZXJlIGEgcGllY2UgbWlzc2lu
Zy4gSSB0cmllZCB0aGlzIGFnYWluc3QgbmV0LW5leHQtMi42DQo+IA0KPiANCj4gLS0gDQo+ICAg
Q0MgW01dICBuZXQvaXB2Ni9tY2FzdC5vDQo+IG5ldC9pcHY2L21jYXN0LmM6IEluIGZ1bmN0aW9u
IKFpZ21wNl9ldmVudF9xdWVyeaI6DQo+IG5ldC9pcHY2L21jYXN0LmM6MTEzNDogZXJyb3I6IGlt
cGxpY2l0IGRlY2xhcmF0aW9uIG9mIGZ1bmN0aW9uIKFtbGRfbXNnog0KPiBuZXQvaXB2Ni9tY2Fz
dC5jOjExMzQ6IHdhcm5pbmc6IGFzc2lnbm1lbnQgbWFrZXMgcG9pbnRlciBmcm9tIGludGVnZXIg
d2l0aG91dCBhIGNhc3QNCj4gbmV0L2lwdjYvbWNhc3QuYzogSW4gZnVuY3Rpb24goWlnbXA2X2V2
ZW50X3JlcG9ydKI6DQo+IG5ldC9pcHY2L21jYXN0LmM6MTI1NDogd2FybmluZzogYXNzaWdubWVu
dCBtYWtlcyBwb2ludGVyIGZyb20gaW50ZWdlciB3aXRob3V0IGEgY2FzdA0KDQpZZWFoIEkgYWxz
byBjYW4ndCBzZWUgaG93IHRoaXMgcGF0Y2ggc2V0IGV2ZXIgY29tcGlsZWQgc3VjY2Vzc2Z1bGx5
Lg0KDQpJJ20gdG9zc2luZyB0aGlzIGVudGlyZSBzZXQuDQo=
