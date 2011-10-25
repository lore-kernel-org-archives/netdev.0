From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: use IS_ENABLED() macro to cleanup code
Date: Tue, 25 Oct 2011 19:30:37 -0400 (EDT)
Message-ID: <20111025.193037.1312584002692004360.davem@davemloft.net>
References: <1319526752.3834.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54265 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753799Ab1JYXal (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2011 19:30:41 -0400
In-Reply-To: <1319526752.3834.12.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0IDxlcmljLmR1bWF6ZXRAZ21haWwuY29tPg0KRGF0ZTogVHVlLCAy
NSBPY3QgMjAxMSAwOToxMjozMiArMDIwMA0KDQo+IFJlbW92ZSBzb21lIHVnbHkgI2lmZGVmLCB1
c2luZyBJU19FTkFCTEVEKENPTkZJR194eHgpIG1hY3JvDQo+IA0KPiBJU19FTkFCTEVEKENPTkZJ
R194eHgpIGV2YWx1YXRlcyB0byAxIGlmIENPTkZJR194eHggaXMgc2V0IHRvICd5JyBvciAnbScN
Cj4gDQo+IFNpZ25lZC1vZmYtYnk6IEVyaWMgRHVtYXpldCA8ZXJpYy5kdW1hemV0QGdtYWlsLmNv
bT4NCg0KSSBjYW4gdW5kZXJzdGFuZCB0aGUgZGVzaXJlIHRvIGRvIHRoaXMsIGJ1dCBpdCBpcyBn
b2luZyB0byBydW4NCmFmb3VsIGluIGNhc2VzIHdoZXJlIHRoZSBkZWZpbml0aW9ucyBvZiBkYXRh
c3RydWN0dXJlcyBpbiBoZWFkZXINCmZpbGVzIGFyZSBwcm90ZWN0ZWQgYnkgcmVhbCBDUFAgaWZk
ZWYgZ3VhcmRzIHJhdGhlciB0aGFuIHRoZXNlDQpydW4tdGltZSB2YXJpYW50cy4NCg0KU28geW91
IGJ1aWxkIHRlc3RlZCB0aGlzIHdpdGggSVBWNiBkaXNhYmxlZCwgcmlnaHQ/DQoNCkRpZG4ndCB0
aGluayBzby4uLg0KDQpuZXQvaXB2NC9pcF9zb2NrZ2x1ZS5jOiBJbiBmdW5jdGlvbiChZG9faXBf
c2V0c29ja29wdKI6DQpuZXQvaXB2NC9pcF9zb2NrZ2x1ZS5jOjUyMzoyOTogZXJyb3I6IKFMT09Q
QkFDSzRfSVBWNqIgdW5kZWNsYXJlZCAoZmlyc3QgdXNlIGluIHRoaXMgZnVuY3Rpb24pDQpuZXQv
aXB2NC9pcF9zb2NrZ2x1ZS5jOjUyMzoyOTogbm90ZTogZWFjaCB1bmRlY2xhcmVkIGlkZW50aWZp
ZXIgaXMgcmVwb3J0ZWQgb25seSBvbmNlIGZvciBlYWNoIGZ1bmN0aW9uIGl0IGFwcGVhcnMgaW4N
Cg0KVGhpcyBmYWlscyBiZWNhdXNlIGlwX3NvY2tnbHVlLmMgZ3VhcmRzIHRoZSBuZXQvdHJhbnNw
X3Y2LmggaGVhZGVyDQppbmNsdXNpb24gd2l0aCBhIHJlYWwgQ1BQIGd1YXJkLg0K
