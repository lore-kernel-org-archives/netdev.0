From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: sched: constify tcf_proto and tc_action
Date: Tue, 05 Jul 2011 22:59:21 -0700 (PDT)
Message-ID: <20110705.225921.2065481038863776818.davem@davemloft.net>
References: <1309926765.2545.53.camel@edumazet-laptop>
	<20110705.223635.2008814218347412648.davem@davemloft.net>
	<20110705.225633.2168272736556352902.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57284 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751093Ab1GFF7X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2011 01:59:23 -0400
In-Reply-To: <20110705.225633.2168272736556352902.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRGF2aWQgTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0Pg0KRGF0ZTogVHVlLCAwNSBK
dWwgMjAxMSAyMjo1NjozMyAtMDcwMCAoUERUKQ0KDQo+IEZyb206IERhdmlkIE1pbGxlciA8ZGF2
ZW1AZGF2ZW1sb2Z0Lm5ldD4NCj4gRGF0ZTogVHVlLCAwNSBKdWwgMjAxMSAyMjozNjozNSAtMDcw
MCAoUERUKQ0KPiANCj4+IEZyb206IEVyaWMgRHVtYXpldCA8ZXJpYy5kdW1hemV0QGdtYWlsLmNv
bT4NCj4+IERhdGU6IFdlZCwgMDYgSnVsIDIwMTEgMDY6MzI6NDUgKzAyMDANCj4+IA0KPj4+IFNp
Z25lZC1vZmYtYnk6IEVyaWMgRHVtYXpldCA8ZXJpYy5kdW1hemV0QGdtYWlsLmNvbT4NCj4+IA0K
Pj4gQXBwbGllZC4NCj4gDQo+IG5ldC9zY2hlZC9jbHNfY2dyb3VwLmM6Mjc5OjI6IHdhcm5pbmc6
IGluaXRpYWxpemF0aW9uIGZyb20gaW5jb21wYXRpYmxlIHBvaW50ZXIgdHlwZSBbZW5hYmxlZCBi
eSBkZWZhdWx0XQ0KPiBuZXQvc2NoZWQvY2xzX2Nncm91cC5jOjI3OToyOiB3YXJuaW5nOiAobmVh
ciBpbml0aWFsaXphdGlvbiBmb3IgoWNsc19jZ3JvdXBfb3BzLmNsYXNzaWZ5oikgW2VuYWJsZWQg
YnkgZGVmYXVsdF0NCg0KQlRXLCBpcyBpcyByZWFsbHkgc28gaGFyZCBmb3IgcGVvcGxlIHRvIGRv
ICJhbGxtb2Rjb25maWciDQpidWlsZHM/DQoNCllvdSBjYW4gdGFrZSB5b3VyIGNoYW5jZXMgdGhl
IGZpcnN0IHRpbWUsIGJ1dCBpZiB5b3UgbmVlZCB0byByZXNwaW4NCmJlY2F1c2Ugb2Ygd2Fybmlu
Z3MgYW5kIGJyZWFrYWdlLCB0aGUgb251cyBpcyBvbiB5b3UgdG8gYWN0dWFsbHkgZG8gYQ0KcmVh
bCBjb21wbGV0ZSBidWlsZCByZWdyZXNzaW9uIHRlc3Qgb24geW91ciBjaGFuZ2VzLg0KDQpJIHNo
b3VsZG4ndCBiZSB0aGUgb25lIGhpdHRpbmcgdGhpcyBzdHVmZiwgeW91IGZvbGtzIHNob3VsZC4N
Cg==
