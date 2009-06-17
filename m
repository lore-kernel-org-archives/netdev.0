From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] phy_device: fix parameter name in kernel-doc
Date: Tue, 16 Jun 2009 19:56:33 -0700
Message-ID: <4A385B61.4050106@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:38351 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751995AbZFQC4g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2009 22:56:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix kernel-doc parameter name in phy_device.c.

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/net/phy/phy_device.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-2.6.30-git10.orig/drivers/net/phy/phy_device.c
+++ linux-2.6.30-git10/drivers/net/phy/phy_device.c
@@ -244,7 +244,7 @@ EXPORT_SYMBOL(get_phy_device);
 
 /**
  * phy_device_register - Register the phy device on the MDIO bus
- * @phy_device: phy_device structure to be added to the MDIO bus
+ * @phydev: phy_device structure to be added to the MDIO bus
  */
 int phy_device_register(struct phy_device *phydev)
 {
