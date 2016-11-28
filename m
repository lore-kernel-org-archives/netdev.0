From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] amd-xgbe: Fix unused suspend handlers build warning
Date: Mon, 28 Nov 2016 12:19:59 -0500 (EST)
Message-ID: <20161128.121959.1034195605598985230.davem@davemloft.net>
References: <20161126205352.19577-1-bp@alien8.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: linux-kernel@vger.kernel.org, thomas.lendacky@amd.com,
        netdev@vger.kernel.org
To: bp@alien8.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34134 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754631AbcK1RUl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 12:20:41 -0500
In-Reply-To: <20161126205352.19577-1-bp@alien8.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogQm9yaXNsYXYgUGV0a292IDxicEBhbGllbjguZGU+DQpEYXRlOiBTYXQsIDI2IE5vdiAy
MDE2IDIxOjUzOjUyICswMTAwDQoNCj4gRnJvbTogQm9yaXNsYXYgUGV0a292IDxicEBzdXNlLmRl
Pg0KPiANCj4gRml4Og0KPiANCj4gICBkcml2ZXJzL25ldC9ldGhlcm5ldC9hbWQveGdiZS94Z2Jl
LW1haW4uYzo4MzU6MTI6IHdhcm5pbmc6IKF4Z2JlX3N1c3BlbmSiIGRlZmluZWQNCj4gICAgIGJ1
dCBub3QgdXNlZCBbLVd1bnVzZWQtZnVuY3Rpb25dDQo+ICAgZHJpdmVycy9uZXQvZXRoZXJuZXQv
YW1kL3hnYmUveGdiZS1tYWluLmM6ODU1OjEyOiB3YXJuaW5nOiCheGdiZV9yZXN1bWWiIGRlZmlu
ZWQNCj4gICAgIGJ1dCBub3QgdXNlZCBbLVd1bnVzZWQtZnVuY3Rpb25dDQo+IA0KPiBJIHNlZSBp
dCBkdXJpbmcgcmFuZGNvbmZpZyBidWlsZHMgaGVyZS4NCj4gDQo+IFNpZ25lZC1vZmYtYnk6IEJv
cmlzbGF2IFBldGtvdiA8YnBAc3VzZS5kZT4NCg0KQXBwbGllZCwgdGhhbmtzLg0K
