From: <aelior@cavium.com>
Subject: [PATCH net] MAINTAINERS: Remove Yuval Mintz from maintainers list
Date: Tue, 19 Sep 2017 12:54:34 +0300
Message-ID: <20170919095434.1386-1-aelior@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <everest-linux-l2@cavium.com>
To: <davem@davemloft.net>, <aelior@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0062.outbound.protection.outlook.com ([104.47.38.62]:19424
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750952AbdISJyn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 19 Sep 2017 05:54:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ariel Elior <aelior@cavium.com>

Remove Yuval from maintaining the bnx2x & qed* modules as he is no longer
working for the company. Thanks Yuval for your huge contributions and
tireless efforts over the many years and various companies.

Ariel
Signed-off-by: Ariel Elior <aelior@cavium.com>
---
 MAINTAINERS | 2 --
 1 file changed, 2 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 567343b..5d24dbf 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2801,7 +2801,6 @@ S:	Supported
 F:	drivers/scsi/bnx2i/
 
 BROADCOM BNX2X 10 GIGABIT ETHERNET DRIVER
-M:	Yuval Mintz <Yuval.Mintz@cavium.com>
 M:	Ariel Elior <ariel.elior@cavium.com>
 M:	everest-linux-l2@cavium.com
 L:	netdev@vger.kernel.org
@@ -10827,7 +10826,6 @@ S:	Supported
 F:	drivers/scsi/qedi/
 
 QLOGIC QL4xxx ETHERNET DRIVER
-M:	Yuval Mintz <Yuval.Mintz@cavium.com>
 M:	Ariel Elior <Ariel.Elior@cavium.com>
 M:	everest-linux-l2@cavium.com
 L:	netdev@vger.kernel.org
-- 
2.9.4
