From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 4/4]: bonding: update version
Date: Fri, 19 Jan 2007 18:15:56 -0800
Message-ID: <200701200215.l0K2Fu22021999@death.nxdomain.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>, Patrick McHardy <kaber@trash.net>,
	mitch.a.williams@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:47448 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932880AbXATCQE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jan 2007 21:16:04 -0500
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e34.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id l0K2Fw9C010886
	for <netdev@vger.kernel.org>; Fri, 19 Jan 2007 21:15:58 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l0K2Fvkp498214
	for <netdev@vger.kernel.org>; Fri, 19 Jan 2007 19:15:57 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l0K2Fvbw029937
	for <netdev@vger.kernel.org>; Fri, 19 Jan 2007 19:15:57 -0700
To: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	Update version number to reflect recent changes.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>


diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index dc434fb..6123b90 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -22,8 +22,8 @@ #include <linux/kobject.h>
 #include "bond_3ad.h"
 #include "bond_alb.h"
 
-#define DRV_VERSION	"3.1.1"
-#define DRV_RELDATE	"September 26, 2006"
+#define DRV_VERSION	"3.1.2"
+#define DRV_RELDATE	"January 20, 2007"
 #define DRV_NAME	"bonding"
 #define DRV_DESCRIPTION	"Ethernet Channel Bonding Driver"
 
