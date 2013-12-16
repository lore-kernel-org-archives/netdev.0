From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net-ipv6: Fix alleged compiler warning in
 ipv6_exthdrs_len()
Date: Mon, 16 Dec 2013 00:27:09 -0500 (EST)
Message-ID: <20131216.002709.2053125006947324246.davem@davemloft.net>
References: <1387162087-5072-1-git-send-email-hkchu@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org
To: hkchu@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33896 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750866Ab3LPF1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 00:27:12 -0500
In-Reply-To: <1387162087-5072-1-git-send-email-hkchu@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogIkguSy4gSmVycnkgQ2h1IiA8aGtjaHVAZ29vZ2xlLmNvbT4NCkRhdGU6IFN1biwgMTUg
RGVjIDIwMTMgMTg6NDg6MDcgLTA4MDANCg0KPiBGcm9tOiBKZXJyeSBDaHUgPGhrY2h1QGdvb2ds
ZS5jb20+DQo+IA0KPiBJdCB3YXMgcmVwb3J0ZWQgdGhhdCBDb21taXQgMjk5NjAzZTgzNzBhOTNk
ZDVkOGU4ZDgwMGYwZGZmMWNlMmM1M2QzNg0KPiAoIm5ldC1ncm86IFByZXBhcmUgR1JPIHN0YWNr
IGZvciB0aGUgdXBjb21pbmcgdHVubmVsaW5nIHN1cHBvcnQiKQ0KPiB0cmlnZ2VyZWQgYSBjb21w
aWxlciB3YXJuaW5nIGluIGlwdjZfZXh0aGRyc19sZW4oKToNCj4gDQo+IG5ldC9pcHY2L2lwNl9v
ZmZsb2FkLmM6IEluIGZ1bmN0aW9uIKFpcHY2X2dyb19jb21wbGV0ZaI6DQo+IG5ldC9pcHY2L2lw
Nl9vZmZsb2FkLmM6MTc4OjI0OiB3YXJuaW5nOiChb3B0bGVuoiBtYXkgYmUgdXNlZCB1bmluaXRp
YWxpemVkIGluIHRoaXMgZnVuY3Rpb24gWy1XbWF5YmUtdQ0KPiAgICAgb3B0aCA9ICh2b2lkICop
b3B0aCArIG9wdGxlbjsNCj4gICAgIAkJCV4NCj4gICAgIG5ldC9pcHY2L2lwNl9vZmZsb2FkLmM6
MTY0OjIyOiBub3RlOiChb3B0bGVuoiB3YXMgZGVjbGFyZWQgaGVyZQ0KPiAgICAgaW50IGxlbiA9
IDAsIHByb3RvLCBvcHRsZW47DQo+ICAgICAgICAgICAgICAgICAgICAgICAgIF4NCj4gTm90ZSB0
aGF0IHRoZXJlIHdhcyBubyByZWFsIGJ1ZyBoZXJlIC0gb3B0bGVuIHdhcyBuZXZlciB1bmluaXRp
YWxpemVkDQo+IGJlZm9yZSB1c2UuIChXYXMgdGhlIHZlcnNpb24gb2YgZ2NjIEkgdXNlZCBzbWFy
dGVyIHRvIG5vdCBjb21wbGFpbj8pDQo+IA0KPiBSZXBvcnRlZC1ieTogSGFubmVzIEZyZWRlcmlj
IFNvd2EgPGhhbm5lc0BzdHJlc3NpbmR1a3Rpb24ub3JnPg0KPiBTaWduZWQtb2ZmLWJ5OiBILksu
IEplcnJ5IENodSA8aGtjaHVAZ29vZ2xlLmNvbT4NCg0KQXBwbGllZCwgdGhhbmsgeW91Lg0K
