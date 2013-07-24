From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: trans_rdma: remove unused function
Date: Wed, 24 Jul 2013 16:45:14 -0700 (PDT)
Message-ID: <20130724.164514.393667021861625699.davem@davemloft.net>
References: <1374497956-32104-1-git-send-email-andi@etezian.org>
	<20130724.154646.2283898956674234778.davem@davemloft.net>
	<1374707387.29835.23.camel@x61.thuisdomein>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: andi@etezian.org, ericvh@gmail.com, rminnich@sandia.gov,
	lucho@ionkov.net, v9fs-developer@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: pebolle@tiscali.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36510 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753264Ab3GXXpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jul 2013 19:45:17 -0400
In-Reply-To: <1374707387.29835.23.camel@x61.thuisdomein>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogUGF1bCBCb2xsZSA8cGVib2xsZUB0aXNjYWxpLm5sPg0KRGF0ZTogVGh1LCAyNSBKdWwg
MjAxMyAwMTowOTo0NyArMDIwMA0KDQo+IE9uIFdlZCwgMjAxMy0wNy0yNCBhdCAxNTo0NiAtMDcw
MCwgRGF2aWQgTWlsbGVyIHdyb3RlOg0KPj4gRnJvbTogQW5kaSBTaHl0aSA8YW5kaUBldGV6aWFu
Lm9yZz4NCj4+ID4gVGhpcyBwYXRjaCBnZXRzIHJpZCBvZiB0aGUgZm9sbG93aW5nIHdhcm5pbmc6
DQo+PiA+IA0KPj4gPiBuZXQvOXAvdHJhbnNfcmRtYS5jOjU5NDoxMjogd2FybmluZzogoXJkbWFf
Y2FuY2VsbGVkoiBkZWZpbmVkIGJ1dCBub3QgdXNlZCBbLVd1bnVzZWQtZnVuY3Rpb25dDQo+PiA+
ICBzdGF0aWMgaW50IHJkbWFfY2FuY2VsbGVkKHN0cnVjdCBwOV9jbGllbnQgKmNsaWVudCwgc3Ry
dWN0IHA5X3JlcV90ICpyZXEpDQo+PiA+IA0KPj4gPiBUaGUgcmRtYV9jYW5jZWxsZWQgZnVuY3Rp
b24gaXMgbm90IGNhbGxlZCBhbnl3aGVyZSBpbiB0aGUga2VybmVsDQo+PiA+IA0KPj4gPiBTaWdu
ZWQtb2ZmLWJ5OiBBbmRpIFNoeXRpIDxhbmRpQGV0ZXppYW4ub3JnPg0KPj4gDQo+PiBBcHBsaWVk
IHRvIG5ldC1uZXh0LCB0aGFua3MuDQo+IA0KPiBBZnRlciB0aGlzIHBhdGNoIG9uZSBtaWdodCBh
cyB3ZWxsIHJldmVydCB0aGUgcmVzdCBvZiBjb21taXQNCj4gODBiNDUyNjFhMGIyICgiOVA6IEFk
ZCBjYW5jZWxsZWQoKSB0byB0aGUgdHJhbnNwb3J0IGZ1bmN0aW9ucy4iKSB0b28uIEl0DQo+IHNl
ZW1zIHRoZSBlbnRpcmUgY2FuY2VsbGVkIGNhbGxiYWNrIHN0dWZmIGlzIG5vdyBwb2ludGxlc3Mu
DQo+IA0KPiBBcyBJIGFscmVhZHkgYXNrZWQgaW4gaHR0cHM6Ly9sa21sLm9yZy9sa21sLzIwMTMv
Ny8xNS84NyA6IGRpZCB0aGF0DQo+IGNvbW1pdCAiZm9yZ2V0IHRvIGFjdHVhbGx5IGhvb2sgdXAg
cmRtYV9jYW5jZWxsZWQoKSBpbnRvDQo+IHA5X3JkbWFfdHJhbnMoKT8iLiBJdCBkb2VzIGxvb2sg
c28gdG8gbWUuDQoNCklmIG5vYm9keSByZXNwb25kcyB0byB0aGlzIGluIHRoZSBuZXh0IGRheSBv
ciBzbywgZmVlbCBmcmVlIHRvIHNlbmQgbWUNCmEgcGF0Y2ggd2hpY2ggcmlwcyBpdCBhbGwgb3V0
Lg0KDQpObyByZXNwb25zZSBtZWFucyB0aGV5IGRvbid0IGNhcmUsIGFuZCBuZWl0aGVyLCB0aGVy
ZWZvcmUsIHNob3VsZCB3ZS4NCg0KVGhhbmtzLg0K
