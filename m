From: <aelior@cavium.com>
Subject: [PATCH net] MAINTAINERS: Remove Yuval Mintz from maintainers list
Date: Mon, 11 Sep 2017 17:05:13 +0300
Message-ID: <20170911140513.24387-1-aelior@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <everest-linux-l2@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0087.outbound.protection.outlook.com ([104.47.42.87]:27808
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751820AbdIKOFU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 11 Sep 2017 10:05:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ariel Elior <aelior@cavium.com>

Remove Yuval from maintaining the bnx2x & qed* modules as he is no longer
working for the company. Thanks Yuval for your huge contributions and
tireless efforts over the many years and various companies.

Ariel
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
