From: dhananjay@netxen.com
Subject: [patch 2/6] netxen: update driver version
Date: Thu, 20 Dec 2007 18:36:58 -0800
Message-ID: <20071221024308.252607174@netxen.com>
References: <20071221023656.409657310@netxen.com>
Cc: jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.209.101.202] ([64.209.101.202]:36118 "EHLO dut46.unminc.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754103AbXLUCvQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2007 21:51:16 -0500
Content-Disposition: inline; filename=version.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bumping up driver version to 3.4.18, several fixes have gone in since version 3.4.2.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Index: netdev-2.6/drivers/net/netxen/netxen_nic.h
===================================================================
--- netdev-2.6.orig/drivers/net/netxen/netxen_nic.h
+++ netdev-2.6/drivers/net/netxen/netxen_nic.h
@@ -65,8 +65,8 @@
 
 #define _NETXEN_NIC_LINUX_MAJOR 3
 #define _NETXEN_NIC_LINUX_MINOR 4
-#define _NETXEN_NIC_LINUX_SUBVERSION 2
-#define NETXEN_NIC_LINUX_VERSIONID  "3.4.2"
+#define _NETXEN_NIC_LINUX_SUBVERSION 18
+#define NETXEN_NIC_LINUX_VERSIONID  "3.4.18"
 
 #define NETXEN_NUM_FLASH_SECTORS (64)
 #define NETXEN_FLASH_SECTOR_SIZE (64 * 1024)

-- 
