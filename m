From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 0/2] xen-net{front,back}: respect user provided
 max_queues
Date: Wed, 09 Sep 2015 22:05:53 -0700 (PDT)
Message-ID: <20150909.220553.642261089490536395.davem@davemloft.net>
References: <1441794186-26991-1-git-send-email-wei.liu2@citrix.com>
	<20150909.215322.1247922588988536450.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: xen-devel@lists.xenproject.org, netdev@vger.kernel.org
To: wei.liu2@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37344 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750813AbbIJFFy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2015 01:05:54 -0400
In-Reply-To: <20150909.215322.1247922588988536450.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRGF2aWQgTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0Pg0KRGF0ZTogV2VkLCAwOSBT
ZXAgMjAxNSAyMTo1MzoyMiAtMDcwMCAoUERUKQ0KDQo+IEZyb206IFdlaSBMaXUgPHdlaS5saXUy
QGNpdHJpeC5jb20+DQo+IERhdGU6IFdlZCwgOSBTZXAgMjAxNSAxMToyMzowNCArMDEwMA0KPiAN
Cj4+IFdlaSBMaXUgKDIpOg0KPj4gICB4ZW4tbmV0YmFjazogcmVzcGVjdCB1c2VyIHByb3ZpZGVk
IG1heF9xdWV1ZXMNCj4+ICAgeGVuLW5ldGZyb250OiByZXNwZWN0IHVzZXIgcHJvdmlkZWQgbWF4
X3F1ZXVlcw0KPiANCj4gQm90aCBhcHBsaWVkLCB0aGFua3MuDQoNCllvLCB0aGlzIGRvZXNuJ3Qg
ZXZlbiBjb21waWxlIQ0KDQpkcml2ZXJzL25ldC94ZW4tbmV0ZnJvbnQuYzogSW4gZnVuY3Rpb24g
oW5ldGlmX2luaXSiOg0KZHJpdmVycy9uZXQveGVuLW5ldGZyb250LmM6MjEzODo2OiBlcnJvcjog
oXhlbnZpZl9tYXhfcXVldWVzoiB1bmRlY2xhcmVkIChmaXJzdCB1c2UgaW4gdGhpcyBmdW5jdGlv
bikNCiAgaWYgKHhlbnZpZl9tYXhfcXVldWVzID09IDApDQogICAgICBeDQpkcml2ZXJzL25ldC94
ZW4tbmV0ZnJvbnQuYzoyMTM4OjY6IG5vdGU6IGVhY2ggdW5kZWNsYXJlZCBpZGVudGlmaWVyIGlz
IHJlcG9ydGVkIG9ubHkgb25jZSBmb3IgZWFjaCBmdW5jdGlvbiBpdCBhcHBlYXJzIGluDQoNCg==
