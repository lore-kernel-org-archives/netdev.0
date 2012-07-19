From: David Miller <davem@davemloft.net>
Subject: [PATCH] net: Fix warnings in dst_ops.h
Date: Thu, 19 Jul 2012 10:43:22 -0700 (PDT)
Message-ID: <20120719.104322.441167767135286212.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46687 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752204Ab2GSRnX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 13:43:23 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 36241584497
	for <netdev@vger.kernel.org>; Thu, 19 Jul 2012 10:43:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQppbmNsdWRlL25ldC9kc3Rfb3BzLmg6Mjg6MjA6IHdhcm5pbmc6IKFzdHJ1Y3Qgc29ja6IgZGVj
bGFyZWQgaW5zaWRlIHBhcmFtZXRlciBsaXN0DQoNClNpZ25lZC1vZmYtYnk6IERhdmlkIFMuIE1p
bGxlciA8ZGF2ZW1AZGF2ZW1sb2Z0Lm5ldD4NCi0tLQ0KIGluY2x1ZGUvbmV0L2RzdF9vcHMuaCB8
ICAgIDEgKw0KIDEgZmlsZSBjaGFuZ2VkLCAxIGluc2VydGlvbigrKQ0KDQpkaWZmIC0tZ2l0IGEv
aW5jbHVkZS9uZXQvZHN0X29wcy5oIGIvaW5jbHVkZS9uZXQvZHN0X29wcy5oDQppbmRleCBkMDc5
ZmM2Li4yZjI2ZGZiIDEwMDY0NA0KLS0tIGEvaW5jbHVkZS9uZXQvZHN0X29wcy5oDQorKysgYi9p
bmNsdWRlL25ldC9kc3Rfb3BzLmgNCkBAIC04LDYgKzgsNyBAQCBzdHJ1Y3QgZHN0X2VudHJ5Ow0K
IHN0cnVjdCBrbWVtX2NhY2hlcDsNCiBzdHJ1Y3QgbmV0X2RldmljZTsNCiBzdHJ1Y3Qgc2tfYnVm
ZjsNCitzdHJ1Y3Qgc29jazsNCiANCiBzdHJ1Y3QgZHN0X29wcyB7DQogCXVuc2lnbmVkIHNob3J0
CQlmYW1pbHk7DQotLSANCjEuNy4xMC40DQoNCg==
