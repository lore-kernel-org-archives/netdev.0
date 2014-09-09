From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] bonding: get rid of bond->lock
Date: Tue, 09 Sep 2014 14:41:19 -0700 (PDT)
Message-ID: <20140909.144119.147008717948932535.davem@davemloft.net>
References: <20140909.115139.1465933020340882843.davem@davemloft.net>
	<20140909.115755.1617761218805940442.davem@davemloft.net>
	<540F59B2.5080406@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, vfalico@gmail.com, j.vosburgh@gmail.com,
	andy@greyhouse.net
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32856 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750910AbaIIVlU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 17:41:20 -0400
In-Reply-To: <540F59B2.5080406@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogTmlrb2xheSBBbGVrc2FuZHJvdiA8bmlrb2xheUByZWRoYXQuY29tPg0KRGF0ZTogVHVl
LCAwOSBTZXAgMjAxNCAyMTo0OTowNiArMDIwMA0KDQo+IE9uIDA5LzA5LzIwMTQgMDg6NTcgUE0s
IERhdmlkIE1pbGxlciB3cm90ZToNCj4+IGRyaXZlcnMvbmV0L2V0aGVybmV0L2NoZWxzaW8vY3hn
YjQvY3hnYjRfbWFpbi5jOiBJbiBmdW5jdGlvbiChY3hnYjRfaW5ldDZhZGRyX2hhbmRsZXKiOg0K
Pj4gZHJpdmVycy9uZXQvZXRoZXJuZXQvY2hlbHNpby9jeGdiNC9jeGdiNF9tYWluLmM6NDM5Mzoz
OiBlcnJvcjogoXN0cnVjdCBib25kaW5noiBoYXMgbm8gbWVtYmVyIG5hbWVkIKFsb2Nrog0KPj4g
ZHJpdmVycy9uZXQvZXRoZXJuZXQvY2hlbHNpby9jeGdiNC9jeGdiNF9tYWluLmM6NDQwNzozOiBl
cnJvcjogoXN0cnVjdCBib25kaW5noiBoYXMgbm8gbWVtYmVyIG5hbWVkIKFsb2Nrog0KPj4gDQo+
PiBQbGVhc2UgdGVzdCBidWlsZCB3aXRoIGFsbG1vZGNvbmZpZy4NCj4+IA0KPiBXb3csIG15IGJh
ZCEgU29ycnkgYWJvdXQgdGhhdCwgSSBkaWRuJ3QgZXhwZWN0IGl0Lg0KDQpJIGhhdmUgdG8gc2F5
IEkgZGlkbid0IGV4cGVjdCB0aGlzIGVpdGhlciA6KQ0K
