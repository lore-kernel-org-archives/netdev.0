From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: use a 64bit load/store in output path
Date: Thu, 01 Dec 2011 01:48:13 -0500 (EST)
Message-ID: <20111201.014813.1241057161065435427.davem@davemloft.net>
References: <1322715653.2577.25.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59133 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751063Ab1LAGsS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 01:48:18 -0500
In-Reply-To: <1322715653.2577.25.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0IDxlcmljLmR1bWF6ZXRAZ21haWwuY29tPg0KRGF0ZTogVGh1LCAw
MSBEZWMgMjAxMSAwNjowMDo1MyArMDEwMA0KDQo+IGdjYyBjb21waWxlciBpcyBzbWFydCBlbm91
Z2ggdG8gdXNlIGEgc2luZ2xlIGxvYWQvc3RvcmUgaWYgd2UNCj4gbWVtY3B5KGRwdHIsIHNwdHIs
IDgpIG9uIHg4Nl82NCwgcmVnYXJkbGVzcyBvZg0KPiBDT05GSUdfQ0NfT1BUSU1JWkVfRk9SX1NJ
WkUNCj4gICAgIA0KPiBJbiBJUCBoZWFkZXIsIGRhZGRyIGltbWVkaWF0ZWx5IGZvbGxvd3Mgc2Fk
ZHIsIHRoaXMgd29udCBjaGFuZ2UgaW4gdGhlDQo+IGZ1dHVyZS4gV2Ugb25seSBuZWVkIHRvIG1h
a2Ugc3VyZSBvdXIgZmxvd2k0IChzYWRkcixkYWRkcikgZmllbGRzIHdvbnQNCj4gYnJlYWsgdGhl
IHJ1bGUuDQo+IA0KPiBTaWduZWQtb2ZmLWJ5OiBFcmljIER1bWF6ZXQgPGVyaWMuZHVtYXpldEBn
bWFpbC5jb20+DQoNCkhtbW0sIHRoaXMgdHJpZ2dlcnMgYSBzdHJhbmdlIG5ldyBidWlsZCB3YXJu
aW5nOg0KDQpuZXQvZGNjcC9pcHY0LmM6IEluIGZ1bmN0aW9uIKFkY2NwX3Y0X3JvdXRlX3NrYqI6
DQpuZXQvZGNjcC9pcHY0LmM6NDgxOjM6IHdhcm5pbmc6IGluaXRpYWxpemVkIGZpZWxkIHdpdGgg
c2lkZS1lZmZlY3RzIG92ZXJ3cml0dGVuIFtlbmFibGVkIGJ5IGRlZmF1bHRdDQpuZXQvZGNjcC9p
cHY0LmM6NDgxOjM6IHdhcm5pbmc6IChuZWFyIGluaXRpYWxpemF0aW9uIGZvciChZmw0oikgW2Vu
YWJsZWQgYnkgZGVmYXVsdF0NCg==
