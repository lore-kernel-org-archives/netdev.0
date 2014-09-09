From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] bonding: get rid of bond->lock
Date: Tue, 09 Sep 2014 11:57:55 -0700 (PDT)
Message-ID: <20140909.115755.1617761218805940442.davem@davemloft.net>
References: <1410011971-24922-1-git-send-email-nikolay@redhat.com>
	<20140909.115139.1465933020340882843.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, vfalico@gmail.com, j.vosburgh@gmail.com,
	andy@greyhouse.net
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59641 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751004AbaIIS54 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 14:57:56 -0400
In-Reply-To: <20140909.115139.1465933020340882843.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRGF2aWQgTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0Pg0KRGF0ZTogVHVlLCAwOSBT
ZXAgMjAxNCAxMTo1MTozOSAtMDcwMCAoUERUKQ0KDQo+IFlvdSBhcmUgYSBicmF2ZSBwZXJzb24g
cGxheWluZyB3aXRoIGJvbmQgbG9ja2luZywgSSBtdXN0IHNheSA6KQ0KPiANCj4gU2VyaWVzIGFw
cGxpZWQsIHRoYW5rcy4NCg0KU29ycnkgSSBoYWQgdG8gcmV2ZXJ0LCB0aGVyZSBpcyBjb2RlIHJl
ZmVyZW5jaW5nIHRoZSBib25kLT5sb2NrIGluDQp0aGUgY3hnYjQgZHJpdmVyIDotLw0KDQpkcml2
ZXJzL25ldC9ldGhlcm5ldC9jaGVsc2lvL2N4Z2I0L2N4Z2I0X21haW4uYzogSW4gZnVuY3Rpb24g
oWN4Z2I0X2luZXQ2YWRkcl9oYW5kbGVyojoNCmRyaXZlcnMvbmV0L2V0aGVybmV0L2NoZWxzaW8v
Y3hnYjQvY3hnYjRfbWFpbi5jOjQzOTM6MzogZXJyb3I6IKFzdHJ1Y3QgYm9uZGluZ6IgaGFzIG5v
IG1lbWJlciBuYW1lZCChbG9ja6INCmRyaXZlcnMvbmV0L2V0aGVybmV0L2NoZWxzaW8vY3hnYjQv
Y3hnYjRfbWFpbi5jOjQ0MDc6MzogZXJyb3I6IKFzdHJ1Y3QgYm9uZGluZ6IgaGFzIG5vIG1lbWJl
ciBuYW1lZCChbG9ja6INCg0KUGxlYXNlIHRlc3QgYnVpbGQgd2l0aCBhbGxtb2Rjb25maWcuDQo=
