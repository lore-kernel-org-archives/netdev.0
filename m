From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 1/4] via-rhine: commit receive buffer address
 before descriptor status update.
Date: Wed, 8 Apr 2015 11:40:21 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB168C8@AcuExch.aculab.com>
References: <87c90b27962c818239073d3a65341054922bd563.1428340371.git.romieu@fr.zoreil.com>
	 <20150407.155209.47396464487922345.davem@davemloft.net>
	 <20150407210248.GC24631@electric-eye.fr.zoreil.com>
	 <20150407.172748.700634713750750146.davem@davemloft.net>
	 <1428443685.25985.212.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5524564C.9090809@redhat.com>
 <1428445367.25985.214.camel@edumazet-glaptop2.roam.corp.google.com>
 <55246651.3000007@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: David Miller <davem@davemloft.net>,
	"romieu@fr.zoreil.com" <romieu@fr.zoreil.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nix@esperi.org.uk" <nix@esperi.org.uk>,
	"rl@hellgate.ch" <rl@hellgate.ch>,
	"gurligebis@gentoo.org" <gurligebis@gentoo.org>
To: 'Alexander Duyck' <alexander.h.duyck@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.185]:51392 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751392AbbDHLlz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 07:41:55 -0400
In-Reply-To: <55246651.3000007@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogQWxleGFuZGVyIER1eWNrDQo+IFNlbnQ6IDA4IEFwcmlsIDIwMTUgMDA6MjENCi4uLg0K
PiBkbWFfd21iIC0gd3JpdGUgZGVzY3JpcHRvciBmaWVsZHMsIHRoZW4gZG1hX3dtYiwgdGhlbiB1
cGRhdGUgc3RhdHVzIGJpdA0KPiB0byByZWxlYXNlIG93bmVyc2hpcA0KPiANCj4gQSB3bWIgaXMg
c3RpbGwgbmVlZGVkIGlmIGEgUElPIGRvb3JiZWxsIG11c3QgYmUgdXNlZCB0byBub3RpZnkgdGhl
DQo+IGRldmljZSBvZiBhZGRpdGlvbmFsIGRlc2NyaXB0b3JzLg0KDQpUaGF0IGlzIG5lZWRlZCBh
ZnRlciB0aGUgd3JpdGUgdGhhdCByZWxlYXNlcyBvd25lcnNoaXAuDQpTbyB5b3UgYXJlIGxpa2Vs
eSB0byBuZWVkIGEgZG1hX3dtYigpIGJlZm9yZSB0aGUgc3RhdHVzIGJpdCB1cGRhdGUNCmFuZCBh
IGZ1bGwgd21iKCkganVzdCBhZnRlciBpdC4NCg0KSWYgeW91IGFyZSBhZGRpbmcgYSBsb3Qgb2Yg
ZnJhbWVzIHRoZW4geW91IHNob3VsZCBiZSBhYmxlIHRvIHVwZGF0ZQ0KdGhlIHN0YXR1cyBmb3Ig
dGhlIGZpcnN0IGZyYWdtZW50IGxhc3QgLSBhbmQgb25seSBuZWVkIHRoZSBiYXJyaWVycw0Kb24g
dGhlIGZpbmFsIHVwZGF0ZS4NCg0KCURhdmlkDQoNCg==
