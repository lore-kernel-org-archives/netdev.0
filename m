From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v2] net: ipv6: use common fib_default_rule_pref
Date: Tue, 08 Sep 2015 22:38:09 -0700 (PDT)
Message-ID: <20150908.223809.1598957585735076244.davem@davemloft.net>
References: <20150905.220040.768580139044156666.davem@davemloft.net>
	<1441534858-6452-1-git-send-email-phil@nwl.cc>
	<20150908.223705.1178974104676916256.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, tgraf@suug.ch
To: phil@nwl.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57632 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751944AbbIIFiJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 01:38:09 -0400
In-Reply-To: <20150908.223705.1178974104676916256.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRGF2aWQgTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0Pg0KRGF0ZTogVHVlLCAwOCBT
ZXAgMjAxNSAyMjozNzowNSAtMDcwMCAoUERUKQ0KDQo+IEFwcGxpZWQsIHRoYW5rcy4NCg0KQWN0
dWFsbHksIHJldmVydGVkLCB0aGlzIGRvZXNuJ3QgZXZlbiBjb21waWxlLg0KDQpuZXQvY29yZS9m
aWJfcnVsZXMuYzo0NzoxMjogZXJyb3I6IHN0YXRpYyBkZWNsYXJhdGlvbiBvZiChZmliX2RlZmF1
bHRfcnVsZV9wcmVmoiBmb2xsb3dzIG5vbi1zdGF0aWMgZGVjbGFyYXRpb24NCiBzdGF0aWMgdTMy
IGZpYl9kZWZhdWx0X3J1bGVfcHJlZihzdHJ1Y3QgZmliX3J1bGVzX29wcyAqb3BzKQ0KICAgICAg
ICAgICAgXg0KSW4gZmlsZSBpbmNsdWRlZCBmcm9tIG5ldC9jb3JlL2ZpYl9ydWxlcy5jOjE4OjA6
DQppbmNsdWRlL25ldC9maWJfcnVsZXMuaDoxMjA6NTogbm90ZTogcHJldmlvdXMgZGVjbGFyYXRp
b24gb2YgoWZpYl9kZWZhdWx0X3J1bGVfcHJlZqIgd2FzIGhlcmUNCiB1MzIgZmliX2RlZmF1bHRf
cnVsZV9wcmVmKHN0cnVjdCBmaWJfcnVsZXNfb3BzICpvcHMpOw0KICAgICBeDQo=
