From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: fix compiler warning in ipv6_exthdrs_len
Date: Sat, 14 Dec 2013 02:02:11 -0500 (EST)
Message-ID: <20131214.020211.969354536190248209.davem@davemloft.net>
References: <1386824025-27413-1-git-send-email-hkchu@google.com>
	<20131214062929.GA23563@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: hkchu@google.com, edumazet@google.com, herbert@gondor.apana.org.au,
	ogerlitz@mellanox.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48924 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752109Ab3LNHCN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Dec 2013 02:02:13 -0500
In-Reply-To: <20131214062929.GA23563@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogSGFubmVzIEZyZWRlcmljIFNvd2EgPGhhbm5lc0BzdHJlc3NpbmR1a3Rpb24ub3JnPg0K
RGF0ZTogU2F0LCAxNCBEZWMgMjAxMyAwNzoyOToyOSArMDEwMA0KDQo+IENvbW1pdCAyOTk2MDNl
ODM3MGE5M2RkNWQ4ZThkODAwZjBkZmYxY2UyYzUzZDM2ICgibmV0LWdybzogUHJlcGFyZSBHUk8N
Cj4gc3RhY2sgZm9yIHRoZSB1cGNvbWluZyB0dW5uZWxpbmcgc3VwcG9ydCIpIHVzZWQgYW4gdW5p
bml0aWFsaXplZCB2YXJpYWJsZQ0KPiB3aGljaCBsZWFkcyB0byB0aGUgZm9sbG93aW5nIGNvbXBp
bGVyIHdhcm5pbmc6DQo+IA0KPiBuZXQvaXB2Ni9pcDZfb2ZmbG9hZC5jOiBJbiBmdW5jdGlvbiCh
aXB2Nl9ncm9fY29tcGxldGWiOg0KPiBuZXQvaXB2Ni9pcDZfb2ZmbG9hZC5jOjE3ODoyNDogd2Fy
bmluZzogoW9wdGxlbqIgbWF5IGJlIHVzZWQgdW5pbml0aWFsaXplZCBpbiB0aGlzIGZ1bmN0aW9u
IFstV21heWJlLXVuaW5pdGlhbGl6ZWRdDQo+ICAgICBvcHRoID0gKHZvaWQgKilvcHRoICsgb3B0
bGVuOw0KPiAgICAgICAgICAgICAgICAgICAgICAgICBeDQo+IG5ldC9pcHY2L2lwNl9vZmZsb2Fk
LmM6MTY0OjIyOiBub3RlOiChb3B0bGVuoiB3YXMgZGVjbGFyZWQgaGVyZQ0KPiAgIGludCBsZW4g
PSAwLCBwcm90bywgb3B0bGVuOw0KPiAgICAgICAgICAgICAgICAgICAgICAgXg0KPiBGaXggaXQg
dXAuDQo+IA0KPiBDYzogSmVycnkgQ2h1IDxoa2NodUBnb29nbGUuY29tPg0KPiBTaWduZWQtb2Zm
LWJ5OiBIYW5uZXMgRnJlZGVyaWMgU293YSA8aGFubmVzQHN0cmVzc2luZHVrdGlvbi5vcmc+DQoN
CkFwcGxpZWQuDQo=
