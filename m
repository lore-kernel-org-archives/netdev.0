From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] strparser: Propagate correct error code in strp_recv()
Date: Wed, 12 Oct 2016 01:52:32 -0400 (EDT)
Message-ID: <20161012.015232.757833208470209652.davem@davemloft.net>
References: <1475761309-13481-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: tom@herbertland.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: geert@linux-m68k.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36808 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752423AbcJLGCv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 02:02:51 -0400
In-Reply-To: <1475761309-13481-1-git-send-email-geert@linux-m68k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogR2VlcnQgVXl0dGVyaG9ldmVuIDxnZWVydEBsaW51eC1tNjhrLm9yZz4NCkRhdGU6IFRo
dSwgIDYgT2N0IDIwMTYgMTU6NDE6NDkgKzAyMDANCg0KPiBXaXRoIG02OGstbGludXgtZ251LWdj
Yy00LjE6DQo+IA0KPiAgICAgbmV0L3N0cnBhcnNlci9zdHJwYXJzZXIuYzogSW4gZnVuY3Rpb24g
oXN0cnBfcmVjdqI6DQo+ICAgICBuZXQvc3RycGFyc2VyL3N0cnBhcnNlci5jOjk4OiB3YXJuaW5n
OiChZXJyoiBtYXkgYmUgdXNlZCB1bmluaXRpYWxpemVkIGluIHRoaXMgZnVuY3Rpb24NCj4gDQo+
IFBhc3MgImxlbiIgKHdoaWNoIGlzIGFuIGVycm9yIGNvZGUgd2hlbiBuZWdhdGl2ZSkgaW5zdGVh
ZCBvZiB0aGUNCj4gdW5pbml0aWFsaXplZCAiZXJyIiB2YXJpYWJsZSB0byBmaXggdGhpcy4NCj4g
DQo+IEZpeGVzOiA0M2EwYzY3NTFhMzIyODQ3ICgic3RycGFyc2VyOiBTdHJlYW0gcGFyc2VyIGZv
ciBtZXNzYWdlcyIpDQo+IFNpZ25lZC1vZmYtYnk6IEdlZXJ0IFV5dHRlcmhvZXZlbiA8Z2VlcnRA
bGludXgtbTY4ay5vcmc+DQoNCkFwcGxpZWQgYW5kIHF1ZXVlZCB1cCBmb3IgLXN0YWJsZSwgdGhh
bmtzLg0K
