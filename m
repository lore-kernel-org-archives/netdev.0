From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] xen: netback: fix printf format string warning
Date: Mon, 01 Jun 2015 12:03:43 -0700 (PDT)
Message-ID: <20150601.120343.1122621914202084967.davem@davemloft.net>
References: <1433154604-27997-1-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	wei.liu2@citrix.com
To: ian.campbell@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51910 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751233AbbFATDo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 15:03:44 -0400
In-Reply-To: <1433154604-27997-1-git-send-email-ian.campbell@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogSWFuIENhbXBiZWxsIDxpYW4uY2FtcGJlbGxAY2l0cml4LmNvbT4NCkRhdGU6IE1vbiwg
MSBKdW4gMjAxNSAxMTozMDowNCArMDEwMA0KDQo+IGRyaXZlcnMvbmV0L3hlbi1uZXRiYWNrL25l
dGJhY2suYzogSW4gZnVuY3Rpb24goXhlbnZpZl90eF9idWlsZF9nb3BzojoNCj4gZHJpdmVycy9u
ZXQveGVuLW5ldGJhY2svbmV0YmFjay5jOjEyNTM6ODogd2FybmluZzogZm9ybWF0IKElbHWiIGV4
cGVjdHMgYXJndW1lbnQgb2YgdHlwZSChbG9uZyB1bnNpZ25lZCBpbnSiLCBidXQgYXJndW1lbnQg
NSBoYXMgdHlwZSChaW50oiBbLVdmb3JtYXQ9XQ0KPiAgICAgICAgICh0eHJlcS5vZmZzZXQmflBB
R0VfTUFTSykgKyB0eHJlcS5zaXplKTsNCj4gICAgICAgICBeDQo+IA0KPiBQQUdFX01BU0sncyB0
eXBlIGNhbiB2YXJ5IGJ5IGFyY2gsIHNvIGEgY2FzdCBpcyBuZWVkZWQuDQo+IA0KPiBTaWduZWQt
b2ZmLWJ5OiBJYW4gQ2FtcGJlbGwgPGlhbi5jYW1wYmVsbEBjaXRyaXguY29tPg0KPiAtLS0tDQo+
IHYyOiBDYXN0IHRvIHVuc2lnbmVkIGxvbmcsIHNpbmNlIFBBR0VfTUFTSyBjYW4gdmFyeSBieSBh
cmNoLg0KDQpBcHBsaWVkLg0K
