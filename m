From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH iproute2] ss: better 32bit support
Date: Mon, 16 Mar 2015 16:39:35 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB017F6@AcuExch.aculab.com>
References: <1426006607.11398.5.camel@edumazet-glaptop2.roam.corp.google.com>
 <1426360760.4173.101.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Stephen Hemminger <shemming@brocade.com>,
	netdev <netdev@vger.kernel.org>
To: 'Ben Hutchings' <ben@decadent.org.uk>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.183]:53915 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932901AbbCPQkq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 12:40:46 -0400
In-Reply-To: <1426360760.4173.101.camel@decadent.org.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogQmVuIEh1dGNoaW5ncw0KPiBPbiBUdWUsIDIwMTUtMDMtMTAgYXQgMDk6NTYgLTA3MDAs
IEVyaWMgRHVtYXpldCB3cm90ZToNCj4gPiBGcm9tOiBFcmljIER1bWF6ZXQgPGVkdW1hemV0QGdv
b2dsZS5jb20+DQo+ID4NCj4gPiBTb2NrZXQgY29va2llcyBhcmUgNjRiaXQsIGV2ZW4gaWYgc3Mg
aGFwcGVucyB0byBiZQ0KPiA+IGEgMzJiaXQgYmluYXJ5LCBydW5uaW5nIG9uIGEgNjQgYml0IGhv
c3QuDQo+ID4NCj4gPiBTaWduZWQtb2ZmLWJ5OiBFcmljIER1bWF6ZXQgPGVkdW1hemV0QGdvb2ds
ZS5jb20+DQo+ID4gLS0tDQo+ID4gIG1pc2Mvc3MuYyB8ICAgIDQgKystLQ0KPiA+ICAxIGZpbGUg
Y2hhbmdlZCwgMiBpbnNlcnRpb25zKCspLCAyIGRlbGV0aW9ucygtKQ0KPiA+DQo+ID4gZGlmZiAt
LWdpdCBhL21pc2Mvc3MuYyBiL21pc2Mvc3MuYw0KPiA+IGluZGV4IDIxYTQzNjYuLmJhNTg4OTQg
MTAwNjQ0DQo+ID4gLS0tIGEvbWlzYy9zcy5jDQo+ID4gKysrIGIvbWlzYy9zcy5jDQo+ID4gQEAg
LTY3OSw5ICs2NzksOSBAQCBzdGF0aWMgaW5saW5lIGNoYXIgKnNvY2tfYWRkcl9nZXRfc3RyKGNv
bnN0IGluZXRfcHJlZml4ICpwcmVmaXgpDQo+ID4gICAgICByZXR1cm4gdG1wOw0KPiA+ICB9DQo+
ID4NCj4gPiAtc3RhdGljIHVuc2lnbmVkIGxvbmcgY29va2llX3NrX2dldCh1aW50MzJfdCAqY29v
a2llKQ0KPiA+ICtzdGF0aWMgdW5zaWduZWQgbG9uZyBsb25nIGNvb2tpZV9za19nZXQoY29uc3Qg
dWludDMyX3QgKmNvb2tpZSkNCj4gPiAgew0KPiA+IC0JcmV0dXJuICgoKHVuc2lnbmVkIGxvbmcp
Y29va2llWzFdIDw8IDMxKSA8PCAxKSB8IGNvb2tpZVswXTsNCj4gPiArCXJldHVybiAoKCh1bnNp
Z25lZCBsb25nIGxvbmcpY29va2llWzFdIDw8IDMxKSA8PCAxKSB8IGNvb2tpZVswXTsNCj4gDQo+
IFRoZW4geW91IHNob3VsZCBhbHNvIHVzZSA8PCAzMiBpbnN0ZWFkIG9mIHNwbGl0dGluZyBpdCBp
bnRvIHR3byBzaGlmdHMuDQoNCkkgd29uZGVyZWQgaWYgdGhlIGNvZGUgc2hvdWxkIGJlIHJlYWRp
bmcgdGhlIHZhbHVlIGluIHRoZSBob3N0J3MgbmF0dXJhbA0KZW5kaWFubmVzcz8NClRoZW4gdGhl
IGNvZGUgbWlnaHQgYmUgb3B0aW1pc2FibGUgdG86DQoJcmV0dXJuICoodW5zaWduZWQgbG9uZyBs
b25nICopY29va2llOw0Kd2hpY2ggcmF0aGVyIGJlZ3MgdGhlIHF1ZXN0aW9uIGFzIHRvIHdoeSBj
b29raWUgaXMgdWludDMyX3RbMl0gaW5zdGVhZCBvZg0KdWludDY0X3QuDQoNCglEYXZpZA0KDQoN
Cg==
