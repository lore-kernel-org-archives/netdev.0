From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] sfc:On MCDI timeout, issue an FLR (and mark
 MCDI to fail-fast)
Date: Tue, 15 Apr 2014 15:12:05 -0400 (EDT)
Message-ID: <20140415.151205.2089587932941110000.davem@davemloft.net>
References: <534D3073.4020906@solarflare.com>
	<20140415.151102.1823905467453048765.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	rstonehouse@solarflare.com
To: sshah@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40005 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751111AbaDOTMG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2014 15:12:06 -0400
In-Reply-To: <20140415.151102.1823905467453048765.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRGF2aWQgTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0Pg0KRGF0ZTogVHVlLCAxNSBB
cHIgMjAxNCAxNToxMTowMiAtMDQwMCAoRURUKQ0KDQo+IEFwcGxpZWQsIHRoYW5rcy4NCg0KQWN0
dWFsbHksIEkgcmV2ZXJ0ZWQsIHRoaXMgY2hhbmdlIGludHJvZHVjZWQgdGhlIGZvbGxvd2luZyB3
YXJuaW5nOg0KDQovaG9tZS9kYXZlbS9zcmMvR0lUL25ldC9rZXJuZWwvTWFrZWZpbGU6MTQ5OiAq
KiogTm8gWC41MDkgY2VydGlmaWNhdGVzIGZvdW5kICoqKg0KZHJpdmVycy9uZXQvZXRoZXJuZXQv
c2ZjL21jZGkuYzo5ODk6MTM6IHdhcm5pbmc6IKFlZnhfbWNkaV9md2FsZXJ0X2V2ZW50oiBkZWZp
bmVkIGJ1dCBub3QgdXNlZCBbLVd1bnVzZWQtZnVuY3Rpb25dDQoNCkZpeCB0aGlzIHVwIGFuZCBy
ZXN1Ym1pdCwgdGhhbmtzLg0K
