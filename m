From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Remove remaining remnants of pm_qos from
 netdevice.h
Date: Mon, 11 May 2015 13:26:11 -0400 (EDT)
Message-ID: <20150511.132611.701878238281798138.davem@davemloft.net>
References: <1431210103-18683-1-git-send-email-dsahern@gmail.com>
	<20150511.131106.1902675173206646881.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, tgraf@suug.ch
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35778 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751102AbbEKR0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 13:26:14 -0400
In-Reply-To: <20150511.131106.1902675173206646881.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRGF2aWQgTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0Pg0KRGF0ZTogTW9uLCAxMSBN
YXkgMjAxNSAxMzoxMTowNiAtMDQwMCAoRURUKQ0KDQo+IEZyb206IERhdmlkIEFoZXJuIDxkc2Fo
ZXJuQGdtYWlsLmNvbT4NCj4gRGF0ZTogU2F0LCAgOSBNYXkgMjAxNSAxNjoyMTo0MyAtMDYwMA0K
PiANCj4+IENvbW1pdCBlMmM2NTQ0ODI5ZiByZW1vdmVkIHBtX3FvcyBmcm9tIHN0cnVjdCBuZXRf
ZGV2aWNlIGJ1dCBsZWZ0IHRoZQ0KPj4gY29tbWVudCBhYm92ZSBoZWFkZXIgZmlsZS4gUmVtb3Zl
IHRob3NlLg0KPj4gDQo+PiBTaWduZWQtb2ZmLWJ5OiBEYXZpZCBBaGVybiA8ZHNhaGVybkBnbWFp
bC5jb20+DQo+IA0KPiBBcHBsaWVkLCB0aGFua3MgRGF2aWQuDQoNCkFjdHVhbGx5IEkgaGFkIHRv
IHJldmVydCBhcyB0aGlzIGJyZWFrcyB0aGUgYnVpbGQuDQoNCllvdSB3aWxsIG5lZWQgdG8gc3Vi
bWl0IGFub3RoZXIgcGF0Y2ggd2l0aCB0aGlzIG9uZSwgb25lIHRoYXQgYWRkcyBhbg0KaW5jbHVk
ZSBvZiA8bGludXgvcG1fcW9zLmg+IHRvIGRyaXZlcnMvbmV0L2V0aGVybmV0L2ludGVsL2UxMDAw
ZS9lMTAwMC5oDQoNCkluIGZpbGUgaW5jbHVkZWQgZnJvbSBkcml2ZXJzL25ldC9ldGhlcm5ldC9p
bnRlbC9lMTAwMGUvODI1NzEuYzozODowOg0KZHJpdmVycy9uZXQvZXRoZXJuZXQvaW50ZWwvZTEw
MDBlL2UxMDAwLmg6MzQ2OjI0OiBlcnJvcjogZmllbGQgoXBtX3Fvc19yZXGiIGhhcyBpbmNvbXBs
ZXRlIHR5cGUNCiAgc3RydWN0IHBtX3Fvc19yZXF1ZXN0IHBtX3Fvc19yZXE7DQogICAgICAgICAg
ICAgICAgICAgICAgICBeDQo=
