From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] IPV6 : get rid of __HAVE_ARCH_ADDR_SET
Date: Tue, 01 May 2007 06:00:09 +0200
Message-ID: <4636BB49.8050307@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070605050006020107020002"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:60381 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946507AbXEAEAX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2007 00:00:23 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070605050006020107020002
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

__HAVE_ARCH_ADDR_SET seems unused these days, just get rid of it.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

--------------070605050006020107020002
Content-Type: text/plain;
 name="get_rid_of_HAVE_ARCH_ADDR_SET.patch"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="get_rid_of_HAVE_ARCH_ADDR_SET.patch"

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbmV0L2lwdjYuaCBiL2luY2x1ZGUvbmV0L2lwdjYuaApp
bmRleCBmNzBhZmVmLi4yY2UzOTQxIDEwMDY0NAotLS0gYS9pbmNsdWRlL25ldC9pcHY2LmgK
KysrIGIvaW5jbHVkZS9uZXQvaXB2Ni5oCkBAIC0zMjgsNyArMzI4LDYgQEAgc3RhdGljIGlu
bGluZSB2b2lkIGlwdjZfYWRkcl9wcmVmaXgoc3RydQogCQltZW1zZXQocGZ4LT5zNl9hZGRy
ICsgbywgMCwgMTYgLSBvKTsKIH0KIAotI2lmbmRlZiBfX0hBVkVfQVJDSF9BRERSX1NFVAog
c3RhdGljIGlubGluZSB2b2lkIGlwdjZfYWRkcl9zZXQoc3RydWN0IGluNl9hZGRyICphZGRy
LCAKIAkJCQkgICAgIF9fYmUzMiB3MSwgX19iZTMyIHcyLAogCQkJCSAgICAgX19iZTMyIHcz
LCBfX2JlMzIgdzQpCkBAIC0zMzgsNyArMzM3LDYgQEAgc3RhdGljIGlubGluZSB2b2lkIGlw
djZfYWRkcl9zZXQoc3RydWN0IAogCWFkZHItPnM2X2FkZHIzMlsyXSA9IHczOwogCWFkZHIt
PnM2X2FkZHIzMlszXSA9IHc0OwogfQotI2VuZGlmCiAKIHN0YXRpYyBpbmxpbmUgaW50IGlw
djZfYWRkcl9lcXVhbChjb25zdCBzdHJ1Y3QgaW42X2FkZHIgKmExLAogCQkJCSAgY29uc3Qg
c3RydWN0IGluNl9hZGRyICphMikK
--------------070605050006020107020002--
