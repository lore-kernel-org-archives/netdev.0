From: Jon Maloy <jon.maloy@ericsson.com>
Subject: RE: "tipc: fix socket timer deadlock" to stable?
Date: Mon, 13 Mar 2017 12:18:20 +0000
Message-ID: <A2BAEFC30C8FD34388F02C9B3121859D3D7173F1@eusaamb103.ericsson.se>
References: <42aebc97-bd71-a9f8-490b-42d8e81283c6@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "David S. Miller" <davem@davemloft.net>, GUNA <gbalasun@gmail.com>,
        "Ying Xue" <ying.xue@windriver.com>
To: Tommi Rantala <tommi.t.rantala@nokia.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usplmg21.ericsson.net ([198.24.6.65]:62285 "EHLO
        usplmg21.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752017AbdCMMd0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 08:33:26 -0400
In-Reply-To: <42aebc97-bd71-a9f8-490b-42d8e81283c6@nokia.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBUb21taSBSYW50YWxhIFttYWls
dG86dG9tbWkudC5yYW50YWxhQG5va2lhLmNvbV0NCj4gU2VudDogTW9uZGF5LCBNYXJjaCAxMywg
MjAxNyAxMTo0MyBBTQ0KPiBUbzogbmV0ZGV2QHZnZXIua2VybmVsLm9yZzsgSm9uIE1hbG95IDxq
b24ubWFsb3lAZXJpY3Nzb24uY29tPg0KPiBDYzogRGF2aWQgUy4gTWlsbGVyIDxkYXZlbUBkYXZl
bWxvZnQubmV0PjsgR1VOQSA8Z2JhbGFzdW5AZ21haWwuY29tPjsNCj4gWWluZyBYdWUgPHlpbmcu
eHVlQHdpbmRyaXZlci5jb20+DQo+IFN1YmplY3Q6ICJ0aXBjOiBmaXggc29ja2V0IHRpbWVyIGRl
YWRsb2NrIiB0byBzdGFibGU/DQo+IA0KPiBIZWxsbywNCj4gDQo+IFdlJ3JlIHNlZWluZyB0aGlz
IHRpcGMgZGVhZGxvY2sgaW4gNC40LnksIHRoYXQgd2FzIGZpeGVkIGluIHRoZSBtYWlubGluZSBj
b21taXQNCj4gZjFkMDQ4ZjI0ZTY2YmE4NWQzZGFiZjNkMDc2Y2VmYTVmMmI1NDZiMCAidGlwYzog
Zml4IHNvY2tldCB0aW1lcg0KPiBkZWFkbG9jayIuDQo+IA0KPiBDb3VsZC9zaG91bGQgdGhpcyBw
YXRjaCBhbHNvIGJlIGluY2x1ZGVkIGluIHRoZSBzdGFibGUga2VybmVsIHRyZWVzPw0KDQpJIHRo
aW5rIGl0IHNob3VsZC4gSWYgYWN0aW9uIGlzIHJlcXVpcmVkIGJ5IG1lIGhlcmUgKD8pIEkgd2ls
bCByZXBvc3QgdGhlIGNvbW1pdCBmb3IgNC40Lg0KDQovLy9qb24NCg0KPiANCj4gSSBqdXN0IGNo
ZWNrZWQgdGhhdCB0aGUgcGF0Y2ggYXBwbGllcyBvbiB0b3Agb2YgNC40LjUzLCBvbmx5IHRoZSBs
aW5lIG51bWJlcnMNCj4gYXJlIGRpZmZlcmVudCBjb21wYXJlZCB0byB0aGUgdXBzdHJlYW0gY29t
bWl0Lg0KPiANCj4gLVRvbW1pDQo=
