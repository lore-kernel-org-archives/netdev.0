From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] rtnetlink: fix frame size warning in
 rtnl_fill_ifinfo
Date: Tue, 17 Nov 2015 15:27:02 -0500 (EST)
Message-ID: <20151117.152702.306913708555395298.davem@davemloft.net>
References: <1447766212-26339-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, edumazet@google.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59941 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751705AbbKQU1D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 15:27:03 -0500
In-Reply-To: <1447766212-26339-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogSGFubmVzIEZyZWRlcmljIFNvd2EgPGhhbm5lc0BzdHJlc3NpbmR1a3Rpb24ub3JnPg0K
RGF0ZTogVHVlLCAxNyBOb3YgMjAxNSAxNDoxNjo1MiArMDEwMA0KDQo+IEZpeCB0aGUgZm9sbG93
aW5nIHdhcm5pbmc6DQo+IA0KPiAgIENDICAgICAgbmV0L2NvcmUvcnRuZXRsaW5rLm8NCj4gbmV0
L2NvcmUvcnRuZXRsaW5rLmM6IEluIGZ1bmN0aW9uIKFydG5sX2ZpbGxfaWZpbmZvojoNCj4gbmV0
L2NvcmUvcnRuZXRsaW5rLmM6MTMwODoxOiB3YXJuaW5nOiB0aGUgZnJhbWUgc2l6ZSBvZiAyODY0
IGJ5dGVzIGlzIGxhcmdlciB0aGFuIDIwNDggYnl0ZXMgWy1XZnJhbWUtbGFyZ2VyLXRoYW49XQ0K
PiAgfQ0KPiAgXg0KPiBieSBzcGxpdHRpbmcgdXAgdGhlIGh1Z2UgcnRubF9maWxsX2lmaW5mbyBp
bnRvIHNvbWUgc21hbGxlciBvbmVzLCBzbyB3ZQ0KPiBkb24ndCBoYXZlIHRoZSBodWdlIGZyYW1l
IGFsbG9jYXRpb25zIGF0IHRoZSBzYW1lIHRpbWUuDQo+IA0KPiBDYzogRXJpYyBEdW1hemV0IDxl
ZHVtYXpldEBnb29nbGUuY29tPg0KPiBTaWduZWQtb2ZmLWJ5OiBIYW5uZXMgRnJlZGVyaWMgU293
YSA8aGFubmVzQHN0cmVzc2luZHVrdGlvbi5vcmc+DQoNCkFwcGxpZWQuDQo=
