From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 1/2] forcedeth new device ids
Date: Tue, 23 Oct 2007 17:08:57 -0400
Message-ID: <471E62E9.80307@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050505060801060303060907"
To: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
	Manfred Spraul <manfred@colorfullife.com>,
	nedev <netdev@vger.kernel.org>, stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate04.nvidia.com ([216.228.112.152]:4854 "EHLO
	hqemgate04.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757851AbXJXSac (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2007 14:30:32 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050505060801060303060907
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch adds new device ids for mcp77 devices.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>

--------------050505060801060303060907
Content-Type: text/plain;
 name="patch-device-ids-mcp77"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-device-ids-mcp77"

--- old/include/linux/pci_ids.h	2007-10-23 16:49:46.000000000 -0400
+++ new/include/linux/pci_ids.h	2007-10-23 16:50:50.000000000 -0400
@@ -1236,6 +1236,10 @@
 #define PCI_DEVICE_ID_NVIDIA_NFORCE_MCP67_IDE       0x0560
 #define PCI_DEVICE_ID_NVIDIA_NFORCE_MCP73_IDE       0x056C
 #define PCI_DEVICE_ID_NVIDIA_NFORCE_MCP77_IDE       0x0759
+#define PCI_DEVICE_ID_NVIDIA_NVENET_32              0x0760
+#define PCI_DEVICE_ID_NVIDIA_NVENET_33              0x0761
+#define PCI_DEVICE_ID_NVIDIA_NVENET_34              0x0762
+#define PCI_DEVICE_ID_NVIDIA_NVENET_35              0x0763
 
 #define PCI_VENDOR_ID_IMS		0x10e0
 #define PCI_DEVICE_ID_IMS_TT128		0x9128

--------------050505060801060303060907--
