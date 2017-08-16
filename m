From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [patch net-next 0/3] net/sched: Improve getting objects by
 indexes
Date: Wed, 16 Aug 2017 14:28:50 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD0056FBB@AcuExch.aculab.com>
References: <1502849538-14284-1-git-send-email-chrism@mellanox.com>
 <144b87a3-bbe4-a194-ed83-e54840d7c7c2@amd.com>
 <20170816081631.GC1868@nanopsycho>
 <e3cb8f8e-7808-48b4-d90d-67f30ab39687@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Chris Mi <chrism@mellanox.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?utf-8?B?J0NocmlzdGlhbiBLw7ZuaWcn?= <christian.koenig@amd.com>,
        "Jiri Pirko" <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.194]:55081 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751461AbdHPO2y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 10:28:54 -0400
In-Reply-To: <e3cb8f8e-7808-48b4-d90d-67f30ab39687@amd.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogQ2hyaXN0aWFuIEvDtm5pZw0KPiBTZW50OiAxNiBBdWd1c3QgMjAxNyAwOTozMg0KPiBB
bSAxNi4wOC4yMDE3IHVtIDEwOjE2IHNjaHJpZWIgSmlyaSBQaXJrbzoNCj4gPiBXZWQsIEF1ZyAx
NiwgMjAxNyBhdCAwOTo0OTowN0FNIENFU1QsIGNocmlzdGlhbi5rb2VuaWdAYW1kLmNvbSB3cm90
ZToNCj4gPj4gQW0gMTYuMDguMjAxNyB1bSAwNDoxMiBzY2hyaWViIENocmlzIE1pOg0KLi4uDQo+
ID4+PiAtCXJldCA9IGlkcl9hbGxvYygmYnNnX21pbm9yX2lkciwgYmNkLCAwLCBCU0dfTUFYX0RF
VlMsIEdGUF9LRVJORUwpOw0KPiA+Pj4gLQlpZiAocmV0IDwgMCkgew0KPiA+Pj4gKwlyZXQgPSBp
ZHJfYWxsb2MoJmJzZ19taW5vcl9pZHIsIGJjZCwgJmlkcl9pbmRleCwgMCwgQlNHX01BWF9ERVZT
LA0KPiA+Pj4gKwkJCUdGUF9LRVJORUwpOw0KPiA+Pj4gKwlpZiAocmV0KSB7DQo+ID4+PiAgICAJ
CWlmIChyZXQgPT0gLUVOT1NQQykgew0KPiA+Pj4gICAgCQkJcHJpbnRrKEtFUk5fRVJSICJic2c6
IHRvbyBtYW55IGJzZyBkZXZpY2VzXG4iKTsNCj4gPj4+ICAgIAkJCXJldCA9IC1FSU5WQUw7DQo+
ID4+IFRoZSBjb25kaXRpb24gImlmIChyZXQpIiB3aWxsIG5vdyBhbHdheXMgYmUgdHJ1ZSBhZnRl
ciB0aGUgZmlyc3QgYWxsb2NhdGlvbg0KPiA+PiBhbmQgc28gd2UgYWx3YXlzIHJ1biBpbnRvIHRo
ZSBlcnJvciBoYW5kbGluZyBhZnRlciB0aGF0Lg0KPiA+IE9uIHN1Y2Nlc3MsIGlkcl9hbGxvYyBy
ZXR1cm5zIDAuDQo+IA0KPiBBaCwgSSBzZWUuIFlvdSBjaGFuZ2UgdGhlIGlkcl9hbGxvYyB0byBy
ZXR1cm4gdGhlIHJlc3VsdGluZyBpbmRleCBhcw0KPiBzZXBhcmF0ZSBwYXJhbWV0ZXIuDQoNClJl
dHVybmluZyB2YWx1ZXMgYnkgcmVmZXJlbmNlIHR5cGljYWxseSBnZW5lcmF0ZXMgY29uc2lkZXJh
Ymx5IHdvcnNlIGNvZGUNCnRoYXQgdXNpbmcgdGhlIGZ1bmN0aW9uIHJldHVybiB2YWx1ZS4NCkl0
IGlzbid0IGp1c3QgdGhlIGV4dHJhIHBhcmFtZXRlciwgaXQgY2FuIGNvbnN0cmFpbiB0aGUgZ2Vu
ZXJhdGVkIGNvZGUNCmluIG90aGVyIHdheXMuDQpUaGF0IGlzIHdoeSBFUlJfUFRSKCkgYW5kIGZy
aWVuZHMgZXhpc3QuDQpJTUhPIFlvdSBuZWVkIGEgcmVhbGx5IGdvb2QgcmVhc29uIHRvIG1ha2Ug
dGhpcyBjaGFuZ2UuDQoNCglEYXZpZA0KDQoNCg==
