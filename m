From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 6/7] bonding: update version
Date: Tue, 29 Jan 2008 18:07:48 -0800
Message-ID: <12016588733235-git-send-email-fubar@us.ibm.com>
References: <12016588691476-git-send-email-fubar@us.ibm.com>
 <12016588701127-git-send-email-fubar@us.ibm.com>
 <12016588714065-git-send-email-fubar@us.ibm.com>
 <12016588712034-git-send-email-fubar@us.ibm.com>
 <1201658872418-git-send-email-fubar@us.ibm.com>
 <12016588733343-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>, Jay Vosburgh <fubar@us.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:41138 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753349AbYA3CIA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2008 21:08:00 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m0U27tlw007535
	for <netdev@vger.kernel.org>; Tue, 29 Jan 2008 21:07:55 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0U27sOj096148
	for <netdev@vger.kernel.org>; Tue, 29 Jan 2008 19:07:54 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0U27sd4015891
	for <netdev@vger.kernel.org>; Tue, 29 Jan 2008 19:07:54 -0700
In-Reply-To: <12016588733343-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Update bonding to version 3.2.4.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bonding.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 6d83be4..67ccad6 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -22,8 +22,8 @@
 #include "bond_3ad.h"
 #include "bond_alb.h"
 
-#define DRV_VERSION	"3.2.3"
-#define DRV_RELDATE	"December 6, 2007"
+#define DRV_VERSION	"3.2.4"
+#define DRV_RELDATE	"January 28, 2008"
 #define DRV_NAME	"bonding"
 #define DRV_DESCRIPTION	"Ethernet Channel Bonding Driver"
 
-- 
1.5.3.4.206.g58ba4-dirty

