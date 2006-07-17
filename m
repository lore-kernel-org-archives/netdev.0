From: Stephen Hemminger <shemminger@osdl.org>
Subject: Subject: [PATCH] sky2: add another PCI ID
Date: Mon, 17 Jul 2006 15:38:32 -0400
Message-ID: <20060717153832.17ce0e4f@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:5352 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750734AbWGQTij (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2006 15:38:39 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yet another PCI ID for 88E8056

Signed-off-by: Stephen Hemminger <sch@sch-laptop.localdomain>

---

 drivers/net/sky2.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

df48ef5419855dc19bbf3176552128143e431c69
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index d98f28c..217b96f 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -121,6 +121,7 @@ static const struct pci_device_id sky2_i
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4361) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4362) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4363) },
+	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4364) },
 	{ 0 }
 };
 
-- 
1.1.3
