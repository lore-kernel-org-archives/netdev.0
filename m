From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv6: Fix incompatible pointer type warning
Date: Tue, 04 Jun 2013 17:14:56 -0700 (PDT)
Message-ID: <20130604.171456.2052649822776872955.davem@davemloft.net>
References: <1370262068-16658-1-git-send-email-emilgoode@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, lorenzo@google.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: emilgoode@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60520 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752191Ab3FEAO6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 20:14:58 -0400
In-Reply-To: <1370262068-16658-1-git-send-email-emilgoode@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRW1pbCBHb29kZSA8ZW1pbGdvb2RlQGdtYWlsLmNvbT4NCkRhdGU6IE1vbiwgIDMgSnVu
IDIwMTMgMTQ6MjE6MDggKzAyMDANCg0KPiBUaGlzIGZpeGVzIHRoZSBzcGFyc2Ugd2FybmluZyBi
ZWxvdyBhYm91dCBhc3NpZ25tZW50IGZyb20NCj4gaW5jb21wYXRpYmxlIHBvaW50ZXIgdHlwZS4N
Cj4gDQo+IEluIHRoZSBmb2xsb3dpbmcgY29tbWl0IHRoZSB0aGlyZCBhcmd1bWVudCBpbiBmdW5j
dGlvbiBpcHY2X2Noa19hZGRyDQo+IHdhcyBjaGFuZ2VkIHRvIGNvbnN0IGFuZCBzdHJ1Y3QgbmZf
aXB2Nl9vcHMgd2FzIGludHJvZHVjZWQgd2l0aA0KPiB0aGUgdGhpcmQgYXJndW1lbnQgb2YgLmNo
a19hZGRyIGJlZWluZyBjb25zdC4NCj4gDQo+IDJhNzg1MWJmZmIwMDhmZjQ4ODJlZWU2NzNkYTc0
NzE4OTk3YjQyNjUNCj4gKCJuZXRmaWx0ZXI6IGFkZCBuZl9pcHY2X29wcyBob29rIHRvIGZpeCB4
dF9hZGRydHlwZSB3aXRoIElQdjYiKQ0KPiANCj4gVGhlIGJlbG93IGNvbW1pdCBpbnRyb2R1Y2Vk
IHRoZSB3YXJuaW5nIGFzIHRoZSB0aGlyZCBhcmd1bWVudCBvZg0KPiBkdW1teV9pcHY2X2Noa19h
ZGRyIGFuZCAuaXB2Nl9jaGtfYWRkciBpbiBzdHJ1Y3QgcGluZ3Y2X29wcyBpcw0KPiBtaXNzaW5n
IGEgY29uc3QuDQo+IA0KPiA2ZDBiZmUyMjYxMTYwMmYzNjYxN2JjN2FhMmZmYTFiYmIyZjU0YzY3
DQo+ICgibmV0OiBpcHY2OiBBZGQgSVB2NiBzdXBwb3J0IHRvIHRoZSBwaW5nIHNvY2tldC4iKQ0K
PiANCj4gU3BhcnNlIG91dHB1dDoNCj4gDQo+IG5ldC9pcHY2L3BpbmcuYzogSW4gZnVuY3Rpb24g
oXBpbmd2Nl9pbml0ojoNCj4gbmV0L2lwdjYvcGluZy5jOjg3OjI3OiB3YXJuaW5nOg0KPiAJYXNz
aWdubWVudCBmcm9tIGluY29tcGF0aWJsZSBwb2ludGVyIHR5cGUgW2VuYWJsZWQgYnkgZGVmYXVs
dF0NCj4gDQo+IFNpZ25lZC1vZmYtYnk6IEVtaWwgR29vZGUgPGVtaWxnb29kZUBnbWFpbC5jb20+
DQoNClRoaXMgb25seSBoYXBwZW5zIHdoZW4geW91IGNvbWJpbmUgbmV0IHdpdGggbmV0LW5leHQs
IHRoZXJlZm9yZSB5b3VyDQpwYXRjaCBpc24ndCBhY3R1YWxseSByZWxldmVudCB0byBhbnkgcmVh
bCBHSVQgdHJlZS4NCg0KUGxlYXNlIG1ha2UgdGhpcyB2ZXJ5IGNsZWFyIGluIHRoZSBmdXR1cmUu
DQo=
