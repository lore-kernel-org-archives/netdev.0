From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH] bonding: update version number
Date: Tue, 26 Sep 2006 10:55:00 -0700
Message-ID: <200609261755.k8QHt0Zt006014@death.nxdomain.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:1189 "EHLO e31.co.us.ibm.com")
	by vger.kernel.org with ESMTP id S932221AbWIZRzM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2006 13:55:12 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k8QHt5R2029239
	for <netdev@vger.kernel.org>; Tue, 26 Sep 2006 13:55:05 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8QHt25u229666
	for <netdev@vger.kernel.org>; Tue, 26 Sep 2006 11:55:02 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8QHt100007194
	for <netdev@vger.kernel.org>; Tue, 26 Sep 2006 11:55:01 -0600
To: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	I neglected to properly update the version number in the recent
patch series; this sets it to something reasonable.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>


diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index db16fee..dc434fb 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -22,8 +22,8 @@ #include <linux/kobject.h>
 #include "bond_3ad.h"
 #include "bond_alb.h"
 
-#define DRV_VERSION	"3.1.0-test"
-#define DRV_RELDATE	"September 9, 2006"
+#define DRV_VERSION	"3.1.1"
+#define DRV_RELDATE	"September 26, 2006"
 #define DRV_NAME	"bonding"
 #define DRV_DESCRIPTION	"Ethernet Channel Bonding Driver"
 
