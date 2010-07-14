From: Rami Rosen <ramirose@gmail.com>
Subject: [PATCH net-next-2.6] xfrm: cleanup of xfrm_input.c.
Date: Wed, 14 Jul 2010 11:18:41 +0300
Message-ID: <AANLkTik6qHgbCVwZfMGXpso4p2DTC9w6U9agdFVl1ZbN@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001636832e5e321a6f048b54a240
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:54835 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752702Ab0GNISo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jul 2010 04:18:44 -0400
Received: by wwi17 with SMTP id 17so1758958wwi.1
        for <netdev@vger.kernel.org>; Wed, 14 Jul 2010 01:18:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001636832e5e321a6f048b54a240
Content-Type: text/plain; charset=ISO-8859-1

Hi,
 The patch removes unneeded inclusion of header files
(linux/module.h, linux/netdevice.h, net/dst.h and net/ip.h)
 in net/xfrm/xfrm_input.c

Regards,
Rami Rosen

Signed-off-by: Rami Rosen <ramirose@gmail.com>

--001636832e5e321a6f048b54a240
Content-Type: text/plain; charset=US-ASCII; name="patch.txt"
Content-Disposition: attachment; filename="patch.txt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gblwe5nl0

ZGlmZiAtLWdpdCBhL25ldC94ZnJtL3hmcm1faW5wdXQuYyBiL25ldC94ZnJtL3hmcm1faW5wdXQu
YwppbmRleCA0NWYxYzk4Li42NjJkM2ZlIDEwMDY0NAotLS0gYS9uZXQveGZybS94ZnJtX2lucHV0
LmMKKysrIGIvbmV0L3hmcm0veGZybV9pbnB1dC5jCkBAIC04LDEwICs4LDYgQEAKICAqLwogCiAj
aW5jbHVkZSA8bGludXgvc2xhYi5oPgotI2luY2x1ZGUgPGxpbnV4L21vZHVsZS5oPgotI2luY2x1
ZGUgPGxpbnV4L25ldGRldmljZS5oPgotI2luY2x1ZGUgPG5ldC9kc3QuaD4KLSNpbmNsdWRlIDxu
ZXQvaXAuaD4KICNpbmNsdWRlIDxuZXQveGZybS5oPgogCiBzdGF0aWMgc3RydWN0IGttZW1fY2Fj
aGUgKnNlY3BhdGhfY2FjaGVwIF9fcmVhZF9tb3N0bHk7Cg==
--001636832e5e321a6f048b54a240--
