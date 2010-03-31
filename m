From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 1/3] ipv6 mcast: Introduce
 include/net/mld.h for MLD definitions.
Date: Tue, 30 Mar 2010 23:27:13 -0700 (PDT)
Message-ID: <20100330.232713.236848239.davem@davemloft.net>
References: <201003291101.o2TB1MWQ006587@94.43.138.210.xn.2iij.net>
	<20100330.232344.177012600.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48928
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753587Ab0CaG1L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 02:27:11 -0400
In-Reply-To: <20100330.232344.177012600.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRGF2aWQgTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0Pg0KRGF0ZTogVHVlLCAzMCBN
YXIgMjAxMCAyMzoyMzo0NCAtMDcwMCAoUERUKQ0KDQo+IEZyb206IFlPU0hJRlVKSSBIaWRlYWtp
IDx5b3NoZnVqaUBsaW51eC1pcHY2Lm9yZz4NCj4gRGF0ZTogTW9uLCAyOSBNYXIgMjAxMCAyMDow
MToyMiArMDkwMA0KPiANCj4+IFNpZ25lZC1vZmYtYnk6IFlPU0hJRlVKSSBIaWRlYWtpIDx5b3No
ZnVqaUBsaW51eC1pcHY2Lm9yZz4NCj4gDQo+IEFwcGxpZWQsIHRoYW5rcy4NCg0KTmV2ZXJtaW5k
LCByZXZlcnRlZCwgYnJlYWtzIHRoZSBidWlsZDoNCg0KbmV0L2lwdjYvbWNhc3QuYzogSW4gZnVu
Y3Rpb24goWlnbXA2X2V2ZW50X3F1ZXJ5ojoNCm5ldC9pcHY2L21jYXN0LmM6MTEzNDogZXJyb3I6
IGltcGxpY2l0IGRlY2xhcmF0aW9uIG9mIGZ1bmN0aW9uIKFtbGRfbXNnog0KbmV0L2lwdjYvbWNh
c3QuYzoxMTM0OiB3YXJuaW5nOiBhc3NpZ25tZW50IG1ha2VzIHBvaW50ZXIgZnJvbSBpbnRlZ2Vy
IHdpdGhvdXQgYSBjYXN0DQpuZXQvaXB2Ni9tY2FzdC5jOiBJbiBmdW5jdGlvbiChaWdtcDZfZXZl
bnRfcmVwb3J0ojoNCm5ldC9pcHY2L21jYXN0LmM6MTI1NDogd2FybmluZzogYXNzaWdubWVudCBt
YWtlcyBwb2ludGVyIGZyb20gaW50ZWdlciB3aXRob3V0IGEgY2FzdA0KbWFrZVsyXTogKioqIFtu
ZXQvaXB2Ni9tY2FzdC5vXSBFcnJvciAxDQptYWtlWzFdOiAqKiogW25ldC9pcHY2XSBFcnJvciAy
DQptYWtlOiAqKiogW25ldF0gRXJyb3IgMg0KbWFrZTogKioqIFdhaXRpbmcgZm9yIHVuZmluaXNo
ZWQgam9icy4uLi4NCiAgQ0MgW01dICBkcml2ZXJzL25ldC9lMTAwMGUvbGliLm8NCiAgTEQgW01d
ICBkcml2ZXJzL25ldC9lMTAwMGUvZTEwMDBlLm8NCg==
