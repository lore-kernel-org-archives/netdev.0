From: "Amit S. Kale" <amitkale@netxen.com>
Subject: [PATCH 1/8] NetXen: Adding new device ids.
Date: Mon, 18 Dec 2006 05:50:59 -0800
Message-ID: <200612181350.kBIDoxQF012135@dut39.unminc.com>
Cc: amitkale@netxen.com, brazilnut@us.ibm.com, jeff@garzik.org,
	netxenproj@linsyssoft.com, rob@netxen.com, sanjeev@netxen.com,
	wendyx@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:4908 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754060AbWLROWy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Dec 2006 09:22:54 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Amit S. Kale <amitkale@netxen.com>

netxen_nic_main.c |    2 ++
 1 files changed, 2 insertions(+)


diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 575b71b..d8b1daf 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -90,6 +90,8 @@ static struct pci_device_id netxen_pci_t
 	{PCI_DEVICE(0x4040, 0x0003)},
 	{PCI_DEVICE(0x4040, 0x0004)},
 	{PCI_DEVICE(0x4040, 0x0005)},
+	{PCI_DEVICE(0x4040, 0x0024)},
+	{PCI_DEVICE(0x4040, 0x0025)},
 	{0,}
 };
 
