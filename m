From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [E1000-devel] [PATCH] e100: Fix inconsistency in bad frames
 handling
Date: Tue, 14 Jun 2011 11:57:08 -0700
Message-ID: <1308077828.4651.5.camel@jbrandeb-mobl2>
References: <BANLkTimpYniHhN6ccMXN7Lx3xDdK6sC+FQ@mail.gmail.com>
	 <alpine.WNT.2.00.1106060940010.3568@JBRANDEB-DESK2.amr.corp.intel.com>
	 <4DED14E7.2050405@candelatech.com>  <1307391315.22348.454.camel@localhost>
	 <1307392197.2642.14.camel@edumazet-laptop>
	 <4DF79AB1.2080109@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Andrea Merello <andrea.merello@gmail.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:24464 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752842Ab1FNS5L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2011 14:57:11 -0400
In-Reply-To: <4DF79AB1.2080109@candelatech.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gVHVlLCAyMDExLTA2LTE0IGF0IDEwOjMwIC0wNzAwLCBCZW4gR3JlZWFyIHdyb3RlOg0KPiA+
PiBIb3cgd291bGQgYSByZWNlaXZlZCBza2IgYmUgZmxhZ2dlZCBhcyBoYXZpbmcgYSBDUkMgZXJy
b3I/DQo+ID4+DQo+ID4NCj4gPiBtYXliZSBzb21lIHNrYi0+cGt0X3R5cGUgPSBQQUNLRVRfSU5W
QUxJRDsgb3Igc29tZXRoaW5nLi4uDQo+IA0KPiBKZXNzZTogIElmIEkgY2FuIGdldCB0aGUgZXRo
dG9vbCByZWxhdGVkIHBhdGNoZXMgYWNjZXB0ZWQsIHdvdWxkDQo+IHlvdSBhY2NlcHQgcGF0Y2hl
cyB0byBlMTAwIChhbmQgb3RoZXIgSW50ZWwgZHJpdmVycykgZm9yDQo+IHRoaXMgZmVhdHVyZT8N
Cg0Kc2VlbXMgbGlrZSBhIHJlYXNvbmFibGUgdGhpbmcsIGJ1dCwgdGhlcmUgaXMgc29tZSByaXNr
IHRoYXQgbWlnaHQNCnByZXZlbnQgdXMgdHVybmluZyB0aGlzIG9uIGhvd2V2ZXIsIGJlY2F1c2Ug
d2Ugb2Z0ZW4gbGlrZSBvdXIgaGFyZHdhcmUNCnRvIGRpc2NhcmQgYmFkIGZyYW1lcyBiZWNhdXNl
IChlc3BlY2lhbGx5KSBsb25nIG9uZXMgY2FuIHVzZSBxdWl0ZSBhIGZldw0KYnVmZmVycy4NCg0K
SSBzdGlsbCBhbSBnZW5lcmFsbHkgdW5jb21mb3J0YWJsZSB3aXRoIHRoaXMgaWRlYS4gIFdlJ3Zl
IHN1cnZpdmVkIGENCmxvbmcgdGltZSB3aXRob3V0IGl0IGFuZCBpdCBvcGVucyB1cCB0aGUgcG9z
c2liaWxpdHkgb2YgZXh0cmEgYnVncyAobGlrZQ0KcG9zc2libGUgc2VjdXJpdHkgaXNzdWVzLCBl
dGMpIHdpdGggdmVyeSBsaXR0bGUgb3Bwb3J0dW5pdHkgZm9yDQp3b3J0aHdoaWxlIGdhaW4uDQoN
Ckplc3NlDQoNCg0K
