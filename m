From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 4/4] bonding: update version
Date: Fri, 21 Mar 2008 22:29:36 -0700
Message-ID: <12061637781615-git-send-email-fubar@us.ibm.com>
References: <12061637763004-git-send-email-fubar@us.ibm.com>
 <1206163777364-git-send-email-fubar@us.ibm.com>
 <12061637773219-git-send-email-fubar@us.ibm.com>
 <12061637781447-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>, Jay Vosburgh <fubar@us.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:54211 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752839AbYCVF3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Mar 2008 01:29:45 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m2M5TdZi022541
	for <netdev@vger.kernel.org>; Sat, 22 Mar 2008 01:29:39 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2M5Tdmo213318
	for <netdev@vger.kernel.org>; Fri, 21 Mar 2008 23:29:39 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2M5TdSa030510
	for <netdev@vger.kernel.org>; Fri, 21 Mar 2008 23:29:39 -0600
In-Reply-To: <12061637781447-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Update version to 3.2.5.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bonding.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 67ccad6..a3c74e2 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -22,8 +22,8 @@
 #include "bond_3ad.h"
 #include "bond_alb.h"
 
-#define DRV_VERSION	"3.2.4"
-#define DRV_RELDATE	"January 28, 2008"
+#define DRV_VERSION	"3.2.5"
+#define DRV_RELDATE	"March 21, 2008"
 #define DRV_NAME	"bonding"
 #define DRV_DESCRIPTION	"Ethernet Channel Bonding Driver"
 
-- 
1.5.2.4

