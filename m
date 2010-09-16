From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] Phonet: remove dangling pipe if an
 endpoint is closed early
Date: Wed, 15 Sep 2010 21:35:18 -0700 (PDT)
Message-ID: <20100915.213518.137835427.davem@davemloft.net>
References: <1284589193-26089-1-git-send-email-remi@remlab.net>
	<20100915.213258.212397416.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, remi.denis-courmont@nokia.com
To: remi@remlab.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50887
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751404Ab0IPEfA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Sep 2010 00:35:00 -0400
In-Reply-To: <20100915.213258.212397416.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRGF2aWQgTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0Pg0KRGF0ZTogV2VkLCAxNSBT
ZXAgMjAxMCAyMTozMjo1OCAtMDcwMCAoUERUKQ0KDQo+IEFwcGxpZWQuDQoNCkJ0dywgSSBoYWQg
dG8gYXBwbHkgdGhlIGZvbGxvd2luZyB3YXJuaW5nIGZpeCBhZ2FpbnN0IHlvdXIgb3RoZXINCnNl
dCBvZiBjaGFuZ2VzLg0KDQotLS0tLS0tLS0tLS0tLS0tLS0tLQ0KcGhvbmV0OiBGaXggYnVpbGQg
d2FybmluZy4NCg0KbmV0L3Bob25ldC9zb2NrZXQuYzogSW4gZnVuY3Rpb24goXBuX3Jlc19zZXFf
c2hvd6I6DQpuZXQvcGhvbmV0L3NvY2tldC5jOjcyNjogd2FybmluZzogZm9ybWF0IKElMDJYoiBl
eHBlY3RzIHR5cGUgoXVuc2lnbmVkIGludKIsIGJ1dCBhcmd1bWVudCAzIGhhcyB0eXBlIKFsb25n
IGludKINCg0KU2lnbmVkLW9mZi1ieTogRGF2aWQgUy4gTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQu
bmV0Pg0KLS0tDQogbmV0L3Bob25ldC9zb2NrZXQuYyB8ICAgIDMgKystDQogMSBmaWxlcyBjaGFu
Z2VkLCAyIGluc2VydGlvbnMoKyksIDEgZGVsZXRpb25zKC0pDQoNCmRpZmYgLS1naXQgYS9uZXQv
cGhvbmV0L3NvY2tldC5jIGIvbmV0L3Bob25ldC9zb2NrZXQuYw0KaW5kZXggNmJmNmUzYy4uYWNh
OGZiYSAxMDA2NDQNCi0tLSBhL25ldC9waG9uZXQvc29ja2V0LmMNCisrKyBiL25ldC9waG9uZXQv
c29ja2V0LmMNCkBAIC03MjMsNyArNzIzLDggQEAgc3RhdGljIGludCBwbl9yZXNfc2VxX3Nob3co
c3RydWN0IHNlcV9maWxlICpzZXEsIHZvaWQgKnYpDQogCQlzdHJ1Y3Qgc29jayAqc2sgPSAqcHNr
Ow0KIA0KIAkJc2VxX3ByaW50ZihzZXEsICIlMDJYICU1ZCAlbHUlbiIsDQotCQkJcHNrIC0gcG5y
ZXMuc2ssIHNvY2tfaV91aWQoc2spLCBzb2NrX2lfaW5vKHNrKSwgJmxlbik7DQorCQkJICAgKGlu
dCkgKHBzayAtIHBucmVzLnNrKSwgc29ja19pX3VpZChzayksDQorCQkJICAgc29ja19pX2lubyhz
ayksICZsZW4pOw0KIAl9DQogCXNlcV9wcmludGYoc2VxLCAiJSpzXG4iLCA2MyAtIGxlbiwgIiIp
Ow0KIAlyZXR1cm4gMDsNCi0tIA0KMS43LjIuMg0KDQoNCg==
