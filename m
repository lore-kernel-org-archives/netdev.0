From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Improve Atheros ethernet driver not to do order 4
 GFP_ATOMIC allocation
Date: Tue, 01 Dec 2015 15:35:17 -0500 (EST)
Message-ID: <20151201.153517.224543138214404348.davem@davemloft.net>
References: <20151127082010.GA2500@dhcp22.suse.cz>
	<20151128145113.GB4135@amd>
	<20151130132129.GB21950@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: base64
Cc: pavel@ucw.cz, akpm@osdl.org, linux-kernel@vger.kernel.org,
	jcliburn@gmail.com, chris.snook@gmail.com, netdev@vger.kernel.org,
	rjw@rjwysocki.net, linux-mm@kvack.org, nic-devel@qualcomm.com,
	ronangeles@gmail.com, ebiederm@xmission.com
To: mhocko@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151130132129.GB21950@dhcp22.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogTWljaGFsIEhvY2tvIDxtaG9ja29Aa2VybmVsLm9yZz4NCkRhdGU6IE1vbiwgMzAgTm92
IDIwMTUgMTQ6MjE6MjkgKzAxMDANCg0KPiBPbiBTYXQgMjgtMTEtMTUgMTU6NTE6MTMsIFBhdmVs
IE1hY2hlayB3cm90ZToNCj4+IA0KPj4gYXRsMWMgZHJpdmVyIGlzIGRvaW5nIG9yZGVyLTQgYWxs
b2NhdGlvbiB3aXRoIEdGUF9BVE9NSUMNCj4+IHByaW9yaXR5LiBUaGF0IG9mdGVuIGJyZWFrcyAg
bmV0d29ya2luZyBhZnRlciByZXN1bWUuIFN3aXRjaCB0bw0KPj4gR0ZQX0tFUk5FTC4gU3RpbGwg
bm90IGlkZWFsLCBidXQgc2hvdWxkIGJlIHNpZ25pZmljYW50bHkgYmV0dGVyLg0KPiANCj4gSXQg
aXMgbm90IGNsZWFyIHdoeSBHRlBfS0VSTkVMIGNhbiByZXBsYWNlIEdGUF9BVE9NSUMgc2FmZWx5
IG5laXRoZXINCj4gZnJvbSB0aGUgY2hhbmdlbG9nIG5vciBmcm9tIHRoZSBwYXRjaCBjb250ZXh0
Lg0KDQpFYXJsaWVyIGluIHRoZSBmdW5jdGlvbiB3ZSBkbyBhIEdGUF9LRVJORUwga21hbGxvYyBz
bzogDQoNCsKvXF8o44OEKV8vwq8NCg0KSXQgc2hvdWxkIGJlIGZpbmUuDQo=
