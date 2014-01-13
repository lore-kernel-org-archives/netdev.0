From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: PROBLEM: usbnet / ax88179_178a: Panic in usb_hcd_map_urb_for_dma
Date: Mon, 13 Jan 2014 11:52:04 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D45904D@AcuExch.aculab.com>
References: <CAHNSM4Kv5gcJn=H4k8QjPggWzjF0zRm_t_icAYXjCTqXx4xL2w@mail.gmail.com>
	<1389385824.2025.95.camel@bwh-desktop.uk.level5networks.com>
	<87ob3j1ocb.fsf@nemi.mork.no>
	<CAHNSM4KU8QEybpHgAcCjQoWuRjU8=wd1O7KUVMnrRJKQ-xr=Gg@mail.gmail.com>
	<87zjn3z6d5.fsf@nemi.mork.no>
	<063D6719AE5E284EB5DD2968C1650D6D458FEE@AcuExch.aculab.com>
 <87zjn086iz.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Thomas Kear <thomas@kear.co.nz>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: =?utf-8?B?J0Jqw7hybiBNb3JrJw==?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:52775 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751531AbaAMLyE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jan 2014 06:54:04 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 07763-01 for <netdev@vger.kernel.org>;
 Mon, 13 Jan 2014 11:54:01 +0000 (GMT)
In-Reply-To: <87zjn086iz.fsf@nemi.mork.no>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogQmrDuHJuIE1vcmsNCj4gRGF2aWQgTGFpZ2h0IDxEYXZpZC5MYWlnaHRAQUNVTEFCLkNP
TT4gd3JpdGVzOg0KPiANCj4gPiBUaGUgcGF0Y2ggeW91IHN1Ym1pdHRlZCBpcyB3cm9uZy4NCj4g
PiBXaG9ldmVyIHdyb3RlIHRoZSBzZyBpbnRlcmZhY2Ugd2FzIG9uIGNyYWNrLg0KPiA+IFRoZSAn
bGFzdCcgbWFya2VyIG5lZWRzIG1vdmluZyBhcyB3ZWxsLg0KPiANCj4gSSdtIGFmcmFpZCBJIGRv
bid0IHVuZGVyc3RhbmQgd2hhdCB5b3UgbWVhbnQgYnkgdGhpcy4NCj4gDQo+IHNnX2luaXRfdGFi
bGUoKSBzZXQgdGhlICdsYXN0JyBtYXJrZXIuICBBRkFJQ1MsIHlvdSBkb24ndCBuZWVkIHRvIGNo
YW5nZQ0KPiBpdCB1bmxlc3MgeW91IHdhbnQgdG8gY2hhaW4gbGlzdHMuDQo+IA0KPiBDYXJlIHRv
IGV4cGxhaW4gd2l0aCBzb21lIGNvZGU/DQoNCkp1c3QgYXNzdW1pbmcgdGhhdCB0aGVyZSB3aWxs
IGJlIHNvbWUgY29kZSwgc29tZXdoZXJlLCB0aGF0IHdpbGwgdHJ5DQp0byBwcm9jZXNzIHRoZSBl
bnRpcmUgc2cgbGlzdCAtIHNvIHdvbid0IGxpa2UgdGhlIGVudHJ5IHdpdGggYQ0KTlVMTCBwb2lu
dGVyIGFuZCB6ZXJvIGxlbmd0aCBhdCB0aGUgZW5kLg0KDQpJZiBhbGwgdGhlIHBsYWNlcyB0aGF0
IHByb2Nlc3MgdGhlIGxpc3QgYXJlIGdpdmVuIGFuIGV4cGxpY2l0DQpudW1iZXIgb2YgZW50cmll
cywgb3IgZG9uJ3QgY2FyZSBhYm91dCB0aGUgTlVMTCBpdCBkb2Vzbid0IG1hdHRlci4NCg0KCURh
dmlkDQoNCg==
