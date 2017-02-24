From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers: net: xgene: Simplify xgene_enet_setup_mss()
 to kill warning
Date: Fri, 24 Feb 2017 14:29:32 -0500 (EST)
Message-ID: <20170224.142932.902090866869403269.davem@davemloft.net>
References: <1487932203-31799-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: isubramanian@apm.com, kchudgar@apm.com, arnd@arndb.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: geert@linux-m68k.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39728 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751390AbdBXT35 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2017 14:29:57 -0500
In-Reply-To: <1487932203-31799-1-git-send-email-geert@linux-m68k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogR2VlcnQgVXl0dGVyaG9ldmVuIDxnZWVydEBsaW51eC1tNjhrLm9yZz4NCkRhdGU6IEZy
aSwgMjQgRmViIDIwMTcgMTE6MzA6MDMgKzAxMDANCg0KPiBXaXRoIGdjYy00LjEuMiBhbmQgLU9z
Og0KPiANCj4gICAgIGRyaXZlcnMvbmV0L2V0aGVybmV0L2FwbS94Z2VuZS94Z2VuZV9lbmV0X21h
aW4uYzogSW4gZnVuY3Rpb24goXhnZW5lX2VuZXRfc3RhcnRfeG1pdKI6DQo+ICAgICBkcml2ZXJz
L25ldC9ldGhlcm5ldC9hcG0veGdlbmUveGdlbmVfZW5ldF9tYWluLmM6Mjk3OiB3YXJuaW5nOiCh
bXNzX2luZGV4oiBtYXkgYmUgdXNlZCB1bmluaXRpYWxpemVkIGluIHRoaXMgZnVuY3Rpb24NCj4g
DQo+IFVzaW5nIGEgc2VwYXJhdGUgdmFyaWFibGUgdG8gdHJhY2sgc3VjY2VzcyBtYXkgY29uZnVz
ZSB0aGUgY29tcGlsZXIuDQo+IFByZWluaXRpYWxpemUgbXNzX2luZGV4IHdpdGggLUVCVVNZIGFu
ZCBjaGVjayBmb3IgbmVnYXRpdmUgZXJyb3IgdmFsdWVzDQo+IGluc3RlYWQgdG8ga2lsbCB0aGUg
d2FybmluZy4NCj4gDQo+IFNpZ25lZC1vZmYtYnk6IEdlZXJ0IFV5dHRlcmhvZXZlbiA8Z2VlcnRA
bGludXgtbTY4ay5vcmc+DQoNCkFwcGxpZWQsIHRoYW5rIHlvdS4NCg==
