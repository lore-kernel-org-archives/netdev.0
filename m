From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH iproute2] ss: better 32bit support
Date: Tue, 17 Mar 2015 09:56:03 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB02288@AcuExch.aculab.com>
References: <1426006607.11398.5.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1426360760.4173.101.camel@decadent.org.uk>
	 <063D6719AE5E284EB5DD2968C1650D6D1CB017F6@AcuExch.aculab.com>
 <1426530554.11398.219.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: 'Ben Hutchings' <ben@decadent.org.uk>,
	Stephen Hemminger <shemming@brocade.com>,
	netdev <netdev@vger.kernel.org>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.181]:63075 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932589AbbCQJ5O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 05:57:14 -0400
In-Reply-To: <1426530554.11398.219.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyANCj4gT24gTW9uLCAyMDE1LTAzLTE2IGF0IDE2OjM5ICswMDAwLCBEYXZpZCBM
YWlnaHQgd3JvdGU6DQo+IA0KPiA+IEkgd29uZGVyZWQgaWYgdGhlIGNvZGUgc2hvdWxkIGJlIHJl
YWRpbmcgdGhlIHZhbHVlIGluIHRoZSBob3N0J3MgbmF0dXJhbA0KPiA+IGVuZGlhbm5lc3M/DQo+
ID4gVGhlbiB0aGUgY29kZSBtaWdodCBiZSBvcHRpbWlzYWJsZSB0bzoNCj4gPiAJcmV0dXJuICoo
dW5zaWduZWQgbG9uZyBsb25nICopY29va2llOw0KPiANCj4gVGhpcyB3aWxsIHRyYXAgb24gYXJj
aGVzIHJlcXVlc3RpbmcgOCBieXRlcyBhbGlnbm1lbnQuDQoNClRoYXQgaXMgd2h5IEkgd3JvdGUg
J21pZ2h0IGJlIG9wdGltaXNhYmxlIHRvJyA6LSkNCg0KSWYgdGhlICdjb29raWUnIHdlcmUgYWx3
YXlzIHByb2Nlc3NlZCAnaG9zdCBlbmRpYW4nIHRoZW4gaXQNCmNvdWxkIGJlIGFjY2Vzc2VkIHVz
aW5nIGEgc3RydWN0dXJlIHRoYXQgY29udGFpbnMgYSA2NGJpdCBtZW1iZXINCnRoYXQgaGFzIHRo
ZSBfX2FsaWduZWQoNCkgYXR0cmlidXRlLg0KT24geDg2IChldGMpIHRoaXMgd291bGQgZ2VuZXJh
dGUgYSA2NGJpdCBhY2Nlc3MsIG9uIHNwYXJjIChldGMpIHRoZSBjb21waWxlcg0Kd291bGQgZ2Vu
ZXJhdGUgdGhlIHJlcXVpcmVkIHNoaWZ0cy4NCg0KPiBMb29rIGF0IHJ0YV9nZXRhdHRyX3U2NCgp
LCBhbmQgeW91J2xsIHNlZSB0aGF0IG1hbmlwdWxhdGluZyA2NGJpdCB2YWx1ZXMNCj4gaW4gbmV0
bGluayByZXF1aXJlcyBhIG1lbWNweSgpIGJlY2F1c2Ugd2UgaGF2ZSBubyA2NGJpdCBhbGlnbm1l
bnQNCj4gZ3VhcmFudGVlLg0KDQpVc2luZyBtZW1jcHkoKSBpc24ndCBuZWNlc3NhcmlseSBlbm91
Z2guDQpJZiB5b3UgaGF2ZSBhICd1NjQgKicgcG9pbnRlciB5b3UgY2FuJ3QgZ2V0IGdjYyB0byAn
Zm9yZ2V0JyB0aGF0IGl0DQptdXN0IGhhdmUgOCBieXRlIGFsaWdubWVudCwgc28gaXQgd2lsbCBv
cHRpbWlzZSB0aGUgbWVtY3B5IGJhY2sgdG8NCmEgNjRiaXQgd29yZCBjb3B5Lg0KDQoJRGF2aWQN
Cg0K
