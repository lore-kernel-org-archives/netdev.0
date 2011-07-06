From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: sched: constify tcf_proto and tc_action
Date: Tue, 05 Jul 2011 22:56:33 -0700 (PDT)
Message-ID: <20110705.225633.2168272736556352902.davem@davemloft.net>
References: <1309883807.2271.30.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1309926765.2545.53.camel@edumazet-laptop>
	<20110705.223635.2008814218347412648.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42412 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751684Ab1GFF4f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2011 01:56:35 -0400
In-Reply-To: <20110705.223635.2008814218347412648.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRGF2aWQgTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0Pg0KRGF0ZTogVHVlLCAwNSBK
dWwgMjAxMSAyMjozNjozNSAtMDcwMCAoUERUKQ0KDQo+IEZyb206IEVyaWMgRHVtYXpldCA8ZXJp
Yy5kdW1hemV0QGdtYWlsLmNvbT4NCj4gRGF0ZTogV2VkLCAwNiBKdWwgMjAxMSAwNjozMjo0NSAr
MDIwMA0KPiANCj4+IFNpZ25lZC1vZmYtYnk6IEVyaWMgRHVtYXpldCA8ZXJpYy5kdW1hemV0QGdt
YWlsLmNvbT4NCj4gDQo+IEFwcGxpZWQuDQoNCm5ldC9zY2hlZC9jbHNfY2dyb3VwLmM6Mjc5OjI6
IHdhcm5pbmc6IGluaXRpYWxpemF0aW9uIGZyb20gaW5jb21wYXRpYmxlIHBvaW50ZXIgdHlwZSBb
ZW5hYmxlZCBieSBkZWZhdWx0XQ0KbmV0L3NjaGVkL2Nsc19jZ3JvdXAuYzoyNzk6Mjogd2Fybmlu
ZzogKG5lYXIgaW5pdGlhbGl6YXRpb24gZm9yIKFjbHNfY2dyb3VwX29wcy5jbGFzc2lmeaIpIFtl
bmFibGVkIGJ5IGRlZmF1bHRdDQo=
