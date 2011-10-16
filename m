From: Kevin Wilson <wkevils@gmail.com>
Subject: [PATCH net-next-2.6] [IPV6] cleanup: remove unnecessary include.
Date: Sun, 16 Oct 2011 17:21:57 +0200
Message-ID: <CAGXs5wWNwy-dWaXMVp62FiaXxiKnDNNE3PX3DtqPVs9VCY+kMA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=20cf307ac78315f86304af6c0d97
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:42084 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753526Ab1JPPV6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Oct 2011 11:21:58 -0400
Received: by vcge1 with SMTP id e1so1490032vcg.19
        for <netdev@vger.kernel.org>; Sun, 16 Oct 2011 08:21:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--20cf307ac78315f86304af6c0d97
Content-Type: text/plain; charset=ISO-8859-1

Hi,

This cleanup patch removes unnecessary include from net/ipv6/ip6_fib.c.

Regards,
   wkevils@gmail.com


Signed-off-by: Kevin Wilson <wkevils@gmail.com>

--20cf307ac78315f86304af6c0d97
Content-Type: text/plain; charset=US-ASCII; name="patch.txt"
Content-Disposition: attachment; filename="patch.txt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gtu6of6a0

ZGlmZiAtLWdpdCBhL25ldC9pcHY2L2lwNl9maWIuYyBiL25ldC9pcHY2L2lwNl9maWIuYwppbmRl
eCAzMjBkOTFkLi45MzcxOGYzIDEwMDY0NAotLS0gYS9uZXQvaXB2Ni9pcDZfZmliLmMKKysrIGIv
bmV0L2lwdjYvaXA2X2ZpYi5jCkBAIC0yOCwxMCArMjgsNiBAQAogI2luY2x1ZGUgPGxpbnV4L2xp
c3QuaD4KICNpbmNsdWRlIDxsaW51eC9zbGFiLmg+CiAKLSNpZmRlZiAJQ09ORklHX1BST0NfRlMK
LSNpbmNsdWRlIDxsaW51eC9wcm9jX2ZzLmg+Ci0jZW5kaWYKLQogI2luY2x1ZGUgPG5ldC9pcHY2
Lmg+CiAjaW5jbHVkZSA8bmV0L25kaXNjLmg+CiAjaW5jbHVkZSA8bmV0L2FkZHJjb25mLmg+Cg==
--20cf307ac78315f86304af6c0d97--
