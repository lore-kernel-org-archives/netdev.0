From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/1] net: convert %p usage to %pK
Date: Tue, 24 May 2011 03:58:01 -0400 (EDT)
Message-ID: <20110524.035801.1555795213632087107.davem@davemloft.net>
References: <1306220681.2638.40.camel@edumazet-laptop>
	<1306222507.2298.23.camel@Joe-Laptop>
	<1306223101.2638.43.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: base64
Cc: joe@perches.com, mingo@elte.hu, akpm@linux-foundation.org,
	netdev@vger.kernel.org, drosenberg@vsecurity.com,
	a.p.zijlstra@chello.nl, eparis@parisplace.org,
	eugeneteo@kernel.org, jmorris@namei.org, kees.cook@canonical.com,
	tgraf@infradead.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40643 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754452Ab1EXH71 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 03:59:27 -0400
In-Reply-To: <1306223101.2638.43.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0IDxlcmljLmR1bWF6ZXRAZ21haWwuY29tPg0KRGF0ZTogVHVlLCAy
NCBNYXkgMjAxMSAwOTo0NTowMSArMDIwMA0KDQo+IExlIG1hcmRpIDI0IG1haSAyMDExIMOgIDAw
OjM1IC0wNzAwLCBKb2UgUGVyY2hlcyBhIMOpY3JpdCA6DQo+IA0KPj4gSSB0aGluayBpdCdzIGJl
IGJldHRlciB3aXRob3V0IHRoZSBjYXN0cw0KPj4gdXNpbmcgdGhlIHN0YW5kYXJkIGtlcm5lbC5o
IG1hY3Jvcy4NCj4+IA0KPj4gCXZvaWQgKnB0cjsNCj4+IA0KPj4gCXB0ciA9IG1heWJlX2hpZGVf
cHRyKHNrKTsNCj4+IAlyLT5pZC5pZGlhZ19jb29raWVbMF0gPSBsb3dlcl8zMl9iaXRzKHB0cik7
DQo+PiAJci0+aWQuaWRpYWdfY29va2llWzFdID0gdXBwZXJfMzJfYml0cyhwdHIpOw0KPj4gDQo+
IA0KPiBJIGFtIG5vdCBzdXJlIEkgd2FudCB0byBwYXRjaCBsb3dlcl8zMl9iaXRzKCkgYW5kIHVw
cGVyXzMyX2JpdHMoKSBmb3INCj4gdGhpcy4NCj4gDQo+IFRoZXkgZG9udCB3b3JrIG9uIHBvaW50
ZXJzLCBidXQgb24gIm51bWJlcnMiLCBhY2NvcmRpbmcgdG8ga2VybmVsZG9jDQo+IEFuZHJldyB3
cm90ZSB5ZWFycyBhZ28uIGdjYyBhZ3JlZXMgOg0KPiANCj4gbmV0L2lwdjQvaW5ldF9kaWFnLmM6
IEluIGZ1bmN0aW9uIOKAmGluZXRfY3NrX2RpYWdfZmlsbOKAmToNCj4gbmV0L2lwdjQvaW5ldF9k
aWFnLmM6MTE5OiB3YXJuaW5nOiBjYXN0IGZyb20gcG9pbnRlciB0byBpbnRlZ2VyIG9mIGRpZmZl
cmVudCBzaXplDQo+IG5ldC9pcHY0L2luZXRfZGlhZy5jOjEyMDogZXJyb3I6IGludmFsaWQgb3Bl
cmFuZHMgdG8gYmluYXJ5ID4+DQo+IG1ha2VbMV06ICoqKiBbbmV0L2lwdjQvaW5ldF9kaWFnLm9d
IEVycm9yIDENCg0KQWxzbyB5b3UgY2FuJ3QgZG8gdGhpcywgdGhlICJjb29raWUiIGlzIHVzZWQg
YnkgdGhlIGtlcm5lbCBmdXR1cmUNCmxvb2t1cHMgdG8gZmluZCBzb2NrZXRzLg0KDQpUaGUga2Vy
bmVsIHBvaW50ZXIgaXMgcGFydCBvZiB0aGUgQVBJLCBzbyBzb3JyeSB5b3UgY2FuJ3QgImhpZGUi
DQprZXJuZWwgcG9pbnRlcnMgaW4gdGhpcyBjYXNlIHdpdGhvdXQgcmVhbGx5IGJyZWFraW5nIHVz
ZXIgdmlzaWJsZQ0KdGhpbmdzLg0K
