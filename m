From: Olof Johansson <olof@lixom.net>
Subject: [PATCH] [8/11] pasemi_mac: update todo list
Date: Tue, 2 Oct 2007 16:27:28 -0500
Message-ID: <20071002212728.GI2282@lixom.net>
References: <20071002212421.GA2282@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:46732 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755876AbXJBVXZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2007 17:23:25 -0400
Content-Disposition: inline
In-Reply-To: <20071002212421.GA2282@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pasemi_mac: update todo list

Remove some stale todo items that have been taken care of. Add a couple
of upcoming ones.

Signed-off-by: Olof Johansson <olof@lixom.net>

Index: 2.6.23/drivers/net/pasemi_mac.c
===================================================================
--- 2.6.23.orig/drivers/net/pasemi_mac.c
+++ 2.6.23/drivers/net/pasemi_mac.c
@@ -46,12 +46,10 @@
 
 /* TODO list
  *
- * - Get rid of pci_{read,write}_config(), map registers with ioremap
- *   for performance
- * - PHY support
  * - Multicast support
  * - Large MTU support
- * - Other performance improvements
+ * - SW LRO
+ * - Multiqueue RX/TX
  */
 
 
