From: Sekhar Nori <nsekhar@ti.com>
Subject: [PATCH] MAINTAINERS: update entry for TI's CPSW driver
Date: Wed, 19 Apr 2017 14:08:24 +0530
Message-ID: <8c950dd8642b7b8d778da36ea944674c9cab587c.1492590838.git.nsekhar@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Grygorii Strashko <grygorii.strashko@ti.com>,
        Linux OMAP Mailing List <linux-omap@vger.kernel.org>,
        Linux netdev Mailing List <netdev@vger.kernel.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fllnx210.ext.ti.com ([198.47.19.17]:26214 "EHLO
        fllnx210.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760789AbdDSIia (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 04:38:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mugunthan V N, who was reviewing TI's CPSW driver patches is
not working for TI anymore and wont be reviewing patches for
that driver.

Drop Mugunthan as the maintiainer for this driver.

Grygorii continues to be a reviewer. Dave Miller applies the
patches directly and adding a maintainer is actually
misleading since get_maintainer.pl script stops suggesting
that Dave Miller be copied.

Signed-off-by: Sekhar Nori <nsekhar@ti.com>
---
 MAINTAINERS | 1 -
 1 file changed, 1 deletion(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 860dacbb5be3..c6d89f004e25 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -12684,7 +12684,6 @@ F:	drivers/clk/ti/
 F:	include/linux/clk/ti.h
 
 TI ETHERNET SWITCH DRIVER (CPSW)
-M:	Mugunthan V N <mugunthanvnm@ti.com>
 R:	Grygorii Strashko <grygorii.strashko@ti.com>
 L:	linux-omap@vger.kernel.org
 L:	netdev@vger.kernel.org
-- 
2.9.0
