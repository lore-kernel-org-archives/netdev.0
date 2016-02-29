From: David Miller <davem@davemloft.net>
Subject: Re: [net] net: fix double free issue of skbuff
Date: Mon, 29 Feb 2016 12:11:53 -0500 (EST)
Message-ID: <20160229.121153.1765066549122216101.davem@davemloft.net>
References: <001c01d172fb$cddc7530$69955f90$@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: base64
Cc: pabeni@redhat.com, netdev@vger.kernel.org
To: zhangshengju@cmss.chinamobile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47368 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750871AbcB2RLz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 12:11:55 -0500
In-Reply-To: <001c01d172fb$cddc7530$69955f90$@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTog5byg6IOc5Li+IDx6aGFuZ3NoZW5nanVAY21zcy5jaGluYW1vYmlsZS5jb20+DQpEYXRl
OiBNb24sIDI5IEZlYiAyMDE2IDIyOjE2OjM3ICswODAwDQoNCj4+IE9uIE1vbiwgMjAxNi0wMi0y
OSBhdCAxMjoyMiArMDAwMCwgWmhhbmcgU2hlbmdqdSB3cm90ZToNCj4+ID4gSWYgc2tiX3Jlb3Jk
ZXJfdmxhbl9oZWFkZXIoKSBmYWlsZWQsIHNrYiBpcyBmcmVlZCBhbmQgTlVMTCBpcyByZXR1cm5l
ZC4NCj4+ID4gVGhlbiBhdCBza2Jfdmxhbl91bnRhZygpLCBpdCB3aWxsIGZyZWUgc2tidWZmIGFn
YWluIHdoaWNoIGNhdXNlIGRvdWJsZQ0KPj4gPiBmcmVlLg0KPj4gDQo+PiBPbiBza2JfcmVvcmRl
cl92bGFuX2hlYWRlcigpIGZhaWx1cmUsIHNrYl92bGFuX3VudGFnKCkgd2lsbCBjYWxsDQo+PiBr
ZnJlZV9za2IoKSB1c2luZyB0aGUgcmV0dXJuIHZhbHVlIG9mIHNrYl9yZW9yZGVyX3ZsYW5faGVh
ZGVyKCksIHRoYXQgaXMNCj4+IE5VTEwuIGtmcmVlX3NrYigpIGlzIGEgbm9vcCB3aGVuIHRoZSBh
cmd1bWVudCBpcyBOVUxMLg0KPj4gDQo+PiBUaGUgY3VycmVudCBjb2RlIHNlYW1zIHNhZmUuDQo+
PiANCj4+IFBhb2xvDQo+IEhpIFBhb2xvLCBldmVuIGN1cnJlbnQgY29kZSBpcyBzYWZlLCB0aGlz
J3Mgc3RpbGwgYSBwb3RlbnRpYWwgcHJvYmxlbS4gV2Ugc2hvdWxkIG1ha2UgYW4NCj4gYXNzdW1w
dGlvbiB0aGF0IGlubmVyIGZ1bmN0aW9uIGRvZXNuJ3QgZnJlZSBza2IsIGFuZCBsZXQgb3V0c2lk
ZSBmdW5jdGlvbiB0YWtlIGNhcmUgb2YgdGhpcy4NCg0KTm8sIHRoZSBjdXJyZW50IGNvZGUgaXMg
aW50ZW50aW9uYWwgYW5kIHBlcmZlY3RseSBmaW5lLg0KDQpGaXggcmVhbCBidWdzLCBub3QgaW1h
Z2luYXJ5IG9uZXMuDQoNClRoYW5rcy4NCg==
