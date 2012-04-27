From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: cleanups in sock_setsockopt()
Date: Fri, 27 Apr 2012 01:48:48 -0400 (EDT)
Message-ID: <20120427.014848.764959411706970704.davem@davemloft.net>
References: <1335505319.2775.72.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38698 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754237Ab2D0Fsx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2012 01:48:53 -0400
In-Reply-To: <1335505319.2775.72.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0IDxlcmljLmR1bWF6ZXRAZ21haWwuY29tPg0KRGF0ZTogRnJpLCAy
NyBBcHIgMjAxMiAwNzo0MTo1OSArMDIwMA0KDQo+IEZyb206IEVyaWMgRHVtYXpldCA8ZWR1bWF6
ZXRAZ29vZ2xlLmNvbT4NCj4gDQo+IFVzZSBtaW4oKS9tYXgoKSBtYWNyb3MsIHJlZm9ybWF0IHR3
byBjb21tZW50cywgdXNlICEhdGVzdF9iaXQoKSB0bw0KPiBtYXRjaCAhIXNvY2tfZmxhZygpDQo+
IA0KPiBTaWduZWQtb2ZmLWJ5OiBFcmljIER1bWF6ZXQgPGVkdW1hemV0QGdvb2dsZS5jb20+DQoN
CkludHJvZHVjZXMgd2FybmluZ3M6DQoNCm5ldC9jb3JlL3NvY2suYzogSW4gZnVuY3Rpb24goXNv
Y2tfc2V0c29ja29wdKI6DQpuZXQvY29yZS9zb2NrLmM6NTg0Ojk6IHdhcm5pbmc6IGNvbXBhcmlz
b24gb2YgZGlzdGluY3QgcG9pbnRlciB0eXBlcyBsYWNrcyBhIGNhc3QgW2VuYWJsZWQgYnkgZGVm
YXVsdF0NCm5ldC9jb3JlL3NvY2suYzo2MDU6OTogd2FybmluZzogY29tcGFyaXNvbiBvZiBkaXN0
aW5jdCBwb2ludGVyIHR5cGVzIGxhY2tzIGEgY2FzdCBbZW5hYmxlZCBieSBkZWZhdWx0XQ0KbmV0
L2NvcmUvc29jay5jOjYyMzoxOTogd2FybmluZzogY29tcGFyaXNvbiBvZiBkaXN0aW5jdCBwb2lu
dGVyIHR5cGVzIGxhY2tzIGEgY2FzdCBbZW5hYmxlZCBieSBkZWZhdWx0XQ0KDQphbmQgdGhhdCBt
YWtlcyBzZW5zZSBzaW5jZSBpbnQgaXMgc2lnbmVkIGFuZCBfX3UzMiBpcyBub3QuDQoNCllvdXIg
Y29tcGlsZXIgZGlkbid0IHNwaXQgdGhhdCBvdXQgdG9vPw0K
