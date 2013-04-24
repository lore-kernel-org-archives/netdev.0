From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] netlink: fix compilation after memory
 mapped patches
Date: Wed, 24 Apr 2013 14:27:22 -0400 (EDT)
Message-ID: <20130424.142722.647145900485285061.davem@davemloft.net>
References: <877gjtuqy2.fsf@xmission.com>
	<1366792583-10534-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: ebiederm@xmission.com, netdev@vger.kernel.org, kaber@trash.net,
	bhutchings@solarflare.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41613 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756591Ab3DXS10 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 14:27:26 -0400
In-Reply-To: <1366792583-10534-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogTmljb2xhcyBEaWNodGVsIDxuaWNvbGFzLmRpY2h0ZWxANndpbmQuY29tPg0KRGF0ZTog
V2VkLCAyNCBBcHIgMjAxMyAxMDozNjoyMyArMDIwMA0KDQo+IERlcGVuZGluZyBvZiB0aGUga2Vy
bmVsIGNvbmZpZ3VyYXRpb24gKENPTkZJR19VSURHSURfU1RSSUNUX1RZUEVfQ0hFQ0tTKSwgd2Ug
Y2FuDQo+IGdldCB0aGUgZm9sbG93aW5nIGVycm9yczoNCj4gDQo+IG5ldC9uZXRsaW5rL2FmX25l
dGxpbmsuYzogSW4gZnVuY3Rpb24goW5ldGxpbmtfcXVldWVfbW1hcGVkX3NrYqI6DQo+IG5ldC9u
ZXRsaW5rL2FmX25ldGxpbmsuYzo2NjM6MTQ6IGVycm9yOiBpbmNvbXBhdGlibGUgdHlwZXMgd2hl
biBhc3NpZ25pbmcgdG8gdHlwZSChX191MzKiIGZyb20gdHlwZSCha3VpZF90og0KPiBuZXQvbmV0
bGluay9hZl9uZXRsaW5rLmM6NjY0OjE0OiBlcnJvcjogaW5jb21wYXRpYmxlIHR5cGVzIHdoZW4g
YXNzaWduaW5nIHRvIHR5cGUgoV9fdTMyoiBmcm9tIHR5cGUgoWtnaWRfdKINCj4gbmV0L25ldGxp
bmsvYWZfbmV0bGluay5jOiBJbiBmdW5jdGlvbiChbmV0bGlua19yaW5nX3NldF9jb3BpZWSiOg0K
PiBuZXQvbmV0bGluay9hZl9uZXRsaW5rLmM6NjkzOjE0OiBlcnJvcjogaW5jb21wYXRpYmxlIHR5
cGVzIHdoZW4gYXNzaWduaW5nIHRvIHR5cGUgoV9fdTMyoiBmcm9tIHR5cGUgoWt1aWRfdKINCj4g
bmV0L25ldGxpbmsvYWZfbmV0bGluay5jOjY5NDoxNDogZXJyb3I6IGluY29tcGF0aWJsZSB0eXBl
cyB3aGVuIGFzc2lnbmluZyB0byB0eXBlIKFfX3UzMqIgZnJvbSB0eXBlIKFrZ2lkX3SiDQo+IA0K
PiBXZSBtdXN0IHVzZSB0aGUgaGVscGVycyB0byBnZXQgdGhlIHVpZCBhbmQgZ2lkLCBhbmQgYWxz
byB0YWtlIGNhcmUgb2YgdXNlcl9ucy4NCj4gDQo+IEZpeCBzdWdnZXN0ZWQgYnkgRXJpYyBXLiBC
aWVkZXJtYW4gPGViaWVkZXJtQHhtaXNzaW9uLmNvbT4uDQo+IA0KPiBTaWduZWQtb2ZmLWJ5OiBO
aWNvbGFzIERpY2h0ZWwgPG5pY29sYXMuZGljaHRlbEA2d2luZC5jb20+DQoNCkFwcGxpZWQsIHRo
YW5rcyENCg==
