From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: sched: constify tcf_proto and
 tc_action
Date: Tue, 05 Jul 2011 18:33:23 -0700 (PDT)
Message-ID: <20110705.183323.553222320326544913.davem@davemloft.net>
References: <1309883807.2271.30.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20110705.183234.1710750208514203200.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43372 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755120Ab1GFBd0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 21:33:26 -0400
In-Reply-To: <20110705.183234.1710750208514203200.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRGF2aWQgTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0Pg0KRGF0ZTogVHVlLCAwNSBK
dWwgMjAxMSAxODozMjozNCAtMDcwMCAoUERUKQ0KDQo+IEZyb206IEVyaWMgRHVtYXpldCA8ZXJp
Yy5kdW1hemV0QGdtYWlsLmNvbT4NCj4gRGF0ZTogVHVlLCAwNSBKdWwgMjAxMSAxODozNjo0NyAr
MDIwMA0KPiANCj4+IFNpZ25lZC1vZmYtYnk6IEVyaWMgRHVtYXpldCA8ZXJpYy5kdW1hemV0QGdt
YWlsLmNvbT4NCj4gDQo+IEFwcGxpZWQsIHRoYW5rcyBFcmljLg0KDQpBY3R1YWxseSwgSSdtIHJl
dmVydGluZzoNCg0KbmV0L3NjaGVkL2FjdF9pcHQuYzoyOTQ6Mjogd2FybmluZzogaW5pdGlhbGl6
YXRpb24gZnJvbSBpbmNvbXBhdGlibGUgcG9pbnRlciB0eXBlIFtlbmFibGVkIGJ5IGRlZmF1bHRd
DQpuZXQvc2NoZWQvYWN0X2lwdC5jOjI5NDoyOiB3YXJuaW5nOiAobmVhciBpbml0aWFsaXphdGlv
biBmb3IgoWFjdF9pcHRfb3BzLmFjdKIpIFtlbmFibGVkIGJ5IGRlZmF1bHRdDQpuZXQvc2NoZWQv
YWN0X2NzdW0uYzo1NzI6Mjogd2FybmluZzogaW5pdGlhbGl6YXRpb24gZnJvbSBpbmNvbXBhdGli
bGUgcG9pbnRlciB0eXBlIFtlbmFibGVkIGJ5IGRlZmF1bHRdDQpuZXQvc2NoZWQvYWN0X2NzdW0u
Yzo1NzI6Mjogd2FybmluZzogKG5lYXIgaW5pdGlhbGl6YXRpb24gZm9yIKFhY3RfY3N1bV9vcHMu
YWN0oikgW2VuYWJsZWQgYnkgZGVmYXVsdF0NCg==
